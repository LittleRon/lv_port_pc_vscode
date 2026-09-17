@echo off
REM ============================================================
REM  LVGL Demo - Windows Build Script (Batch wrapper)
REM  Double-click to run, or execute in CMD/PowerShell.
REM  This wrapper calls build.ps1 with execution policy bypassed.
REM ============================================================

powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0build.ps1"

echo.
pause
