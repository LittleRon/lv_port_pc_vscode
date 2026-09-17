# LVGL 项目推荐清单

> 数据核对时间：2026-09-12（星标数与最后提交时间均来自 GitHub API 实时查询）

---

## 一、当前工程结构解析：`E:\lvgl_demo\lv_port_pc_vscode`

### 1. 版本状态

| 项 | 值 |
|---|---|
| 主仓库 | `lvgl/lv_port_pc_vscode`，HEAD = `ca68590`（分支 `release/v9.2` 系列守护仓库） |
| LVGL 子模块 | `v9.5.0-432-gc65e112ab` → **领先 v9.5.0 官方 tag 432 个提交，是 master 主线** |
| FreeRTOS 子模块 | `FreeRTOS/FreeRTOS-Kernel`（已完整下载 860 个文件） |
| SDL2 | 本地自带源码 `SDL2-2.32.10/`（439 文件），`CMakeLists.txt` 里 `set(SDL2_DIR ${PROJECT_SOURCE_DIR}/SDL2-2.32.10/cmake)` 直连仓库内版本 |
| 构建状态 | **已成功构建**：`build/` 有 222 个 `.obj`，产物 `bin/main.exe`（2.66 MB）+ `SDL2.dll` |

### 2. 目录职责

```
lv_port_pc_vscode/
├── CMakeLists.txt              # 全部构建逻辑在这里，唯一要改的文件
├── lv_conf.h                   # 73KB，LVGL 全部功能开关
├── lv_conf.defaults            # 守护脚本用，别手改
├── manifest.json               # LVGL 官方 project-creator 模板描述
├── simulator.code-workspace    # VSCode 工作区（含gdb调试配置）
├── src/
│   ├── main.c                  # ★ 主入口（非 FreeRTOS 分支）
│   ├── freertos_main.c         # USE_FREERTOS=ON 时的入口
│   ├── freertos/
│   │   └── freertos_posix_port.c
│   ├── hal/
│   │   ├── hal.h               # sdl_hal_init() 声明
│   │   └── hal.c               # SDL 显示/触摸/鼠标/键盘 + tick 供给
│   └── mouse_cursor_icon.c     # 光标图标资源
├── config/FreeRTOSConfig.h
├── bin/                        # 构建产物
├── build/                      # CMake + MinGW Makefiles 中间产物
├── lvgl/                       # 库本体（子模块）
├── FreeRTOS/                   # 内核（子模块）
└── SDL2-2.32.10/               # 本地 SDL2 源码
```

### 3. `lv_conf.h` 关键配置（实测值）

```c
LV_USE_OS          LV_OS_NONE      // 未启用 RTOS（要用 FreeRTOS 需 ffmpeg 式改造 + -DUSE_FREERTOS=ON）
LV_COLOR_DEPTH     32              // PC 模拟用 32 位，下板必须改 16
LV_DEF_REFR_PERIOD 33              // 30 FPS
LV_USE_LOG         1
LV_USE_PERF_MONITOR 0              // 性能监视器关着，调 UI 帧率建议打开
LV_USE_DEMO_WIDGETS / BENCHMARK / MUSIC / STRESS   1   // 官方 demo 全开
LV_USE_DEMO_EBIKE  0               // 关着（资源占用大）
LV_USE_FREETYPE    0               // 矢量字体未开
LV_USE_LIBPNG / DRAW_SDL   0
字体：Montserrat 12/14/16/18 开，10 关
```

### 4. 值得注意的三点

1. **这是"PC 模拟器"，不是业务工程**。`src/main.c` 第 72 行就是 `lv_demo_widgets()` —— 换 UI 只需替换这一行。
2. **`LVGL_PRO_PROJECT_DIR` 是官方预留的 UI 挂载点**。`CMakeLists.txt` 135-152 行会把外部 UI 工程 `add_subdirectory` 成 `lib-ui` 并自动链接。做自己的 UI 时走这条路，不要往 `src/` 里堆。
3. **缺独立的 UI 层目录**。现在没有 `ui/`，也没有 `assets/`，图片字体都得自己建目录 + 改 CMake。
4. **主循环是裸轮询**：`while(1) { t = lv_timer_handler(); Sleep(t); }`。PC 上够用，但如果后续接 ELM327 串口/BLE 读取线程，需要给 LVGL 加互斥（`lv_mutex` / 或把 ELM327 数据推进放到 `lv_timer` 回调里）。

---

## 二、高质量 UI 的 LVGL 项目（按参考价值分档）

### A. 官方基础设施

| # | 项目 | ★ | 语言 | 最后更新 | 看点 |
|---|---|---:|---|---|---|
| 1 | [lvgl/lvgl](https://github.com/lvgl/lvgl) | 24661 | C | 2026-09-11 | 库本体，每天有提交 |
| 2 | [lvgl/lv_port_pc_visual_studio](https://github.com/lvgl/lv_port_pc_visual_studio) | 781 | C | 2026-03-02 | **Windows 上比你现在用的 VSCode 版更合适**，原生 MSVC 工程 + semi-hosting 调试 |
| 3 | [lvgl/lvgl_pro](https://github.com/lvgl/lvgl_pro) | 657 | C | 2026-09-10 | LVGL Pro 工作流：Figma 导入 → XML 编写 → 即时预览 → CI 测试 → 导出纯 C。**正好对应你工程的 `LVGL_PRO_PROJECT_DIR`** |
| 4 | [lvgl/lv_port_linux](https://github.com/lvgl/lv_port_linux) | 468 | C | 2026-09-10 | 桌面 Linux 移植（Wayland / DRM / EGL / fbdev），适合车机/Linux 目标 |
| 5 | [lvgl/lv_demos](https://github.com/lvgl/lv_demos) | 567 | C | 2025-10-17 | 官方 demo 合集，widgets/music/benchmark/ebike |

### B. UI 设计与封装的标杆（重点看这批）

| # | 项目 | ★ | 语言 | 最后更新 | 为什么值得看 |
|---|---|---:|---|---|---|
| 6 | [FASTSHIFT/X-TRACK](https://github.com/FASTSHIFT/X-TRACK) | 6288 | C | 2025-11-08 | **UI 质量天花板**。1.3" IPS 上跑 60 FPS 动画，MVP + 分层 UI 架构写得极干净，离线地图 + 轨迹记录。做仪表盘必看 |
| 7 | [ZSWatch/ZSWatch](https://github.com/ZSWatch/ZSWatch) | 3356 | C | 2026-09-11 | Zephyr RTOS 开源智能手表，硬件 + 固件全开源，仍在活跃更新 |
| 8 | [No-Chicken/OV-Watch](https://github.com/No-Chicken/OV-Watch) | 2480 | C | 2026-05-26 | STM32 + FreeRTOS + LVGL 手表，中文友好，动画/表盘/菜单结构完整 |
| 9 | [OMOTE-Community/OMOTE-Firmware](https://github.com/OMOTE-Community/OMOTE-Firmware) | 1780 | C++ | 2026-02-06 | 万能遥控器固件，UI 完成度接近商业产品，BLE/红外/WiFi 全有 |
| 10 | [eez-open/studio](https://github.com/eez-open/studio) | 1814 | JS | 2026-09-09 | EEZ Studio，低代码 GUI 工具，支持导出 LVGL 代码；和 LVGL Pro 是竞争方案 |
| 11 | [HASwitchPlate/openHASP](https://github.com/HASwitchPlate/openHASP) | 1018 | C++ | 2026-09-01 | ESP32 智能家居开关面板，JSON 驱动的 UI 框架思路很有参考价值 |
| 12 | [koosoli/ESPHomeDesigner](https://github.com/koosoli/ESPHomeDesigner) | 1081 | JS | 2026-09-08 | ESPHome 显示屏的**拖拽式可视化编辑器**，2026 年活跃 |
| 13 | [SmallPond/X-Knob](https://github.com/SmallPond/X-Knob) | 878 | C | 2024-04-14 | LVGL 智能旋钮，含触觉反馈 + MQTT + Surface Dial。小圆形屏交互设计的经典 |
| 14 | [21cncstudio/project_aura](https://github.com/21cncstudio/project_aura) | 747 | C | 2026-09-07 | ESP32-S3 空气质量站，配色和排版非常现代，含 3D 打印外壳 |
| 15 | [rzeldent/esp32-smartdisplay](https://github.com/rzeldent/esp32-smartdisplay) | 697 | C | 2026-08-25 | CYD（便宜黄板）全系列驱动库。**如果要下板，这个能省掉移植的活** |
| 16 | [physicsexpert/Exlink_Tool](https://github.com/physicsexpert/Exlink_Tool) | 609 | — | 2025-01-11 | 国产开源"多功能调试器"，UI 精致，ESP32-S3/RP2040 |
| 17 | [fbiego/esp32-c3-mini](https://github.com/fbiego/esp32-c3-mini) | 534 | C | 2026-09-10 | ESP32-C3 + 240×240 圆形屏完整 UI（Chronos 生态），2026 年仍在更新 |
| 18 | [sukesh-ak/ESP32-TUX](https://github.com/sukesh-ak/ESP32-TUX) | 275 | C | 2024-02-27 | "LVGL 触控 UX 模板"，起手 SDK，代码结构比官方 demo 更适合做新项目脚手架 |
| 19 | [aptumfr/awesome-lvgl](https://github.com/aptumfr/awesome-lvgl) | 16 | — | 2026-03-07 | 星少但**是 curated 索引**，按类别收录了上百个 LVGL 项目，找灵感先翻它 |

### C. 非 C 语言路线（如果想避开 C 手写）

| # | 项目 | ★ | 语言 | 说明 |
|---|---|---:|---|---|
| 20 | [lvgl/lv_binding_rust](https://github.com/lvgl/lv_binding_rust) | 941 | Rust | Rust binding，2025 年后停更，注意 API 只跟到 v8 |
| 21 | [lvgl/lv_binding_micropython](https://github.com/lvgl/lv_binding_micropython) | 354 | C | MicroPython binding，2026-09 仍在更新，做原型很快 |

---

## 三、汽车 OBD / ELM327 相关 LVGL 项目

**先说实话**：这个赛道在 GitHub 上**整体星标偏低**，最高的是 471★，绝大多数是个位数的个人项目。但正因为如此，能塞车跑起来的项目工程含量都不低。下面按"能不能直接抄"排序。

### 第一梯队（强烈建议 clone 细读）

| # | 项目 | ★ | 语言 | 最后更新 | 关键能力 |
|---|---|---:|---|---|---|
| 1 | [VaAndCob/ESP32-Bluetooth-OBD2-Gauge](https://github.com/VaAndCob/ESP32-Bluetooth-OBD2-Gauge) | **471** | C | 2025-10-24 | **本赛道星标第一**。ESP32 CYD 2.8" + 蓝牙 ELM327，LVGL + LovyanGFX。多页面仪表、PID 轮询、主题切换。许可证标了 NOASSERTION，**商用前先问作者** |
| 2 | [VaAndCob/ESP32-Serial-OBD2-Gauge-Catalyst](https://github.com/VaAndCob/ESP32-Serial-OBD2-Gauge-Catalyst) | 12 | — | 2026-03-07 | 同作者的**串口 UART 版 ELM327**（非蓝牙）。功能更全：多页（仪表 / 性能曲线图 / 配置 / 故障码）、`pid_custom.csv` 自定义 PID、DTC 读清码、SD 卡更新故障码库、LDR 自动调光、MPU6050、音频反馈、3D 外壳文件。代码 MIT-like 但**明确禁止商用** |
| 3 | [antoxa2584x/esp32-c3-obd-gauge](https://github.com/antoxa2584x/esp32-c3-obd-gauge) | 11 | C++ | 2026-07-24 | **WiFi 型 ELM327**（V1.5，TCP 192.168.0.10:35000）。1.28" 圆形 GC9A01 + CST816 触摸。最大看点：`ObdClient` 是**非阻塞状态机**，单核上 WiFi 和 LVGL 互不阻塞 —— 这是做实时仪表的关键写法。README 里把 `lv_conf.h` 放错位置、触摸芯片自动休眠等坑都写清楚了 |
| 4 | [cheeseprince/obd-gauge-cluster](https://github.com/cheeseprince/obd-gauge-cluster) | 3 | C++ | 2026-09-08 | 星少但**工程化最好的一个**，MIT。ESP32-S3，支持 Mode-22 / UDS 增强 PID（读原厂隐藏数据），按 VIN 自动匹配车型配置，签名 OTA。2026-09 刚更新 |

### 第二梯队（有独特价值）

| # | 项目 | ★ | 语言 | 最后更新 | 关键能力 |
|---|---|---:|---|---|---|
| 5 | [fbiego/car-hud](https://github.com/fbiego/car-hud) | 35 | C | 2026-01-01 | **BLE ELM327 Mini + LVGL Pro** + Viewe SmartRing 屏，ISO 15765-4 CAN。用最新 LVGL Pro 工具链写的，代码是 2026 年的写法。MIT |
| 6 | [ligius-/ev-obd2-dash](https://github.com/ligius-/ev-obd2-dash) | 5 | C | 2025-05-27 | **电动车专用** BT OBD2（福特 Mustang Mach-E），7 次/秒刷新功率。UI 用 EEZ Studio 0.23 生成。Apache-2.0 |
| 7 | [plking111/Automotive-Instrument-Cluster](https://github.com/plking111/Automotive-Instrument-Cluster) | 25 | C | 2026-08-15 | 中文项目，一套练手但我推荐看：**bootloader + OTA 升级 / CAN 总线设计 / LVGL UI** 三件套齐全，覆盖面比纯仪表项目宽 |
| 8 | [patrickelectric/car-round-display](https://github.com/patrickelectric/car-round-display) | 2 | C | 2025-05-14 | ESP32 圆形屏涡轮压力表，代码量小，适合当天跑通 |

### 第三梯队（做某一件事时回来查）

| # | 项目 | ★ | 最后更新 | 用途 |
|---|---|---:|---|---|
| 9 | [RomanBabakin/esp32-obd-ver1](https://github.com/RomanBabakin/esp32-obd-ver1) | 0 | 2025-05-25 | 不走 ELM327，**直接用 ESP32 内置 CAN 控制器读 OBD2**（`esp32_obd2.h`），配 SquareLine Studio UI + MPU6050 G 力计。想绕开 ELM327 就看它 |
| 10 | [Jerome91410/ECUMaster-dashboard-ESP32-3.5inch](https://github.com/Jerome91410/ECUMaster-dashboard-ESP32-3.5inch) | 5 | 2026-01-26 | ECUMaster Black 竞技 ECU 蓝牙直连，LVGL v9.3，3.5" 屏。**组件化写法很好**：每个表头一个 c 文件提供 draw/set/destroy 三函数 |
| 11 | [Sebastian-Gebus/volvo-p3-dashboard](https://github.com/Sebastian-Gebus/volvo-p3-dashboard) | 1 | 2026-07-19 | ESP32-S3 + LilyGo T-Display AMOLED，读沃尔沃私有 CAN 数据 |
| 12 | [seobohdanov/FocusDash_ESP32](https://github.com/seobohdanov/FocusDash_ESP32) | 1 | 2026-07-27 | ESP32-S3 蓝牙 OBD-II 网关 + LVGL 仪表，PlatformIO |
| 13 | [avery/LVGL-CarDashboard? 见 moli721](https://github.com/moli721/RK3568-LVGL-CarDashboard) | 2 | 2026-01-20 | **中文**：RK3568 + LVGL v8.3 车机，玻璃拟态 UI，含音乐播放器/相册，纯 UI 参考 |
| 14 | [zhangwei43721/LVGL-CarDashboard](https://github.com/zhangwei43721/LVGL-CarDashboard) | 5 | 2025-09-20 | **中文**：LVGL 跨平台汽车仪表盘**模拟器**（不上硬件），跟你现在这个 PC 工程目标一致 |

### OBD 开发必备周边

| 项目 | ★ | 最后更新 | 用途 |
|---|---|---:|---|
| [Ircama/ELM327-emulator](https://github.com/Ircama/ELM327-emulator) | 675 | Python | **强烈推荐**：Python 写的 ELM327 模拟器，支持多 ECU 模拟。**不用车、不用真 OBD 硬件就能在你的工程里打通整个链路** |
| [aptumfr/awesome-lvgl](https://github.com/aptumfr/awesome-lvgl) | 16 | 2026-03-07 | 里面有专门的 automotive / dashboards 分类，本篇之外的项目可以从这里续挖 |

---

## 四、针对你这个工程的行动建议

1. **先别急着接硬件**。`Ircama/ELM327-emulator` 在本地起一个虚拟 ECU，你的 PC 模拟器用串口或蓝牙连它，整条 UI 链路就能脱离真车开发调试。
2. **UI 架构抄 X-TRACK**（MVP 分层 + 独立 od Layer），交互编排抄 antoxa2584x 的非阻塞状态机。
3. **工具链选择**：想快 → EEZ Studio 或 LVGL Pro（对应你工程的 `LVGL_PRO_PROJECT_DIR`）；想完全掌控 → 手写 C，参考 ESP32-TUX 的目录结构。
4. **别忘 `lv_conf.h` 的 `LV_COLOR_DEPTH`**。PC 上 32 位爽，下到 ESP32 的 SPI 屏必须改 16，否则帧率腰斩。
5. **开 `LV_USE_PERF_MONITOR`**（现在关着），做仪表盘时盯着 FPS 和内存占用是刚需。
