@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

echo ============== 脚本调试信息 ==============
echo 执行时间：%date% %time%
echo.

:: 1. 检测当前连接的WiFi
echo 【1. 检测WiFi连接】
set "CURRENT_SSID="
for /f "tokens=2 delims=: " %%a in ('netsh wlan show interfaces 2^>nul ^| findstr /i "SSID"') do (
    set "CURRENT_SSID=%%a"
    set "CURRENT_SSID=!CURRENT_SSID: =!"
    echo 检测到WiFi名称：!CURRENT_SSID!
)
if "!CURRENT_SSID!"=="" echo 未检测到任何WiFi连接
echo.

:: 2. 判断是否在校园网
echo 【2. 校园网判定】
set "IN_CAMPUS=false"
if "!CURRENT_SSID!"=="HFIT.portal" (
    set "IN_CAMPUS=true"
    echo ✅ 匹配到校园WiFi，判定为校园网
) else (
    echo 不是目标校园WiFi，尝试ping校园网关
    ping -n 1 -w 500 10.10.2.15
    if !errorlevel! equ 0 (
        set "IN_CAMPUS=true"
        echo ✅ 网关ping通，判定为校园网
    ) else (
        echo ❌ 网关ping不通，不在校园网，脚本退出
        pause
        exit
    )
)
echo.

:: 3. 检测是否已联网
echo 【3. 联网状态检测】
ping -n 1 -w 500 www.baidu.com
if !errorlevel! equ 0 (
    echo ✅ 已正常联网，无需弹窗，脚本退出
    pause
    exit
) else (
    echo ❌ 未联网，准备弹出登录页
)
echo.

:: 4. 执行弹窗
echo 【4. 弹出登录页】
start "" "http://10.10.2.15"
echo ✅ 登录页已弹出！脚本执行完成
echo ==========================================

pause
exit