@echo off
title 自动化编译与部署
echo 正在启动 PowerShell 脚本...
powershell -ExecutionPolicy Bypass -File "%~dp0auto_build.ps1"
if %errorlevel% neq 0 (
    echo 脚本执行出错，请查看上方错误信息。
    pause
)
exit /b