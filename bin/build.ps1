# ============================================================
# LVGL Demo - Windows Build Script (PowerShell)
# Usage:
#   1. Right-click the file -> "Run with PowerShell"
#   2. Or in terminal:  powershell -ExecutionPolicy Bypass -File .\build.ps1
# ============================================================

# Stop on first error
$ErrorActionPreference = "Stop"

# Project root (where CMakeLists.txt lives)
$ProjectRoot = "E:\Projects\lvgl_demo\lv_port_pc_vscode"

Write-Host "========== [1/3] Clearing build cache ==========" -ForegroundColor Cyan
if (Test-Path -Path "$ProjectRoot\build") {
    Remove-Item -Recurse -Force "$ProjectRoot\build"
    Write-Host "Build directory removed." -ForegroundColor Green
} else {
    Write-Host "Build directory does not exist, skipping." -ForegroundColor Yellow
}

Write-Host "========== [2/3] Configuring Primary Weapon ==========" -ForegroundColor Cyan
# Prepend MinGW64 bin to PATH (only for this script session)
$env:Path = 'E:\Projects\lvgl_demo\mingw64\bin;' + $env:Path

cmake -S $ProjectRoot -B "$ProjectRoot\build" -G "MinGW Makefiles" `
    -DCMAKE_BUILD_TYPE=Release `
    -DCMAKE_C_COMPILER=gcc `
    -DCMAKE_CXX_COMPILER=g++ `
    -DLV_USE_DRAW_SDL=ON
if ($LASTEXITCODE -ne 0) {
    Write-Host "CMake configuration failed!" -ForegroundColor Red
    exit $LASTEXITCODE
}
Write-Host "CMake configuration succeeded." -ForegroundColor Green

Write-Host "========== [3/3] Building target: main ==========" -ForegroundColor Cyan
cmake --build "$ProjectRoot\build" --target main -- -j 8
if ($LASTEXITCODE -ne 0) {
    Write-Host "Build failed!" -ForegroundColor Red
    exit $LASTEXITCODE
}

Write-Host "========== Build completed successfully! ==========" -ForegroundColor Green
