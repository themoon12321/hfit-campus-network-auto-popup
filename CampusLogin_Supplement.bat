@echo off
setlocal enabledelayedexpansion

:: ====================== CONFIG ======================
:: Main switch: true=enable, false=disable all
set "ENABLE_AUTO_POP=true"
:: Campus portal URL
set "PORTAL_URL=http://10.10.2.15"
:: Target campus WiFi SSID
set "TARGET_WIFI=HFIT.portal"
:: Login success cooldown (minutes)
set "SUCCESS_COOLDOWN_MIN=5"
:: Single pop-up cooldown (seconds)
set "POP_COOLDOWN_SEC=30"
:: Max wait time for network (seconds)
set "MAX_WAIT_SEC=20"
:: ====================================================

:: Exit if main switch is off
if /i "%ENABLE_AUTO_POP%"=="false" exit

:: Loop to check network every 1 second
set "loop_count=0"
:CHECK_LOOP

:: 1. Check current connected WiFi SSID
set "CURRENT_SSID="
for /f "tokens=2 delims=: " %%a in ('netsh wlan show interfaces 2^>nul ^| findstr /i "SSID"') do (
    set "CURRENT_SSID=%%a"
    set "CURRENT_SSID=!CURRENT_SSID: =!"
)

:: 2. Check if in campus network
set "IN_CAMPUS=false"
if "!CURRENT_SSID!"=="%TARGET_WIFI%" set "IN_CAMPUS=true"
:: If not on WiFi, check if campus gateway is reachable (wired network)
if "!IN_CAMPUS!"=="false" (
    ping -n 1 -w 500 10.10.2.15 >nul 2>&1
    if !errorlevel! equ 0 set "IN_CAMPUS=true"
)

:: Not in campus network: wait for next check, exit after timeout
if "!IN_CAMPUS!"=="false" goto WAIT_NEXT

:: 3. Exit if already connected to internet (no need to pop)
ping -n 1 -w 500 www.baidu.com >nul 2>&1
if !errorlevel! equ 0 exit

:: 4. Cooldown check to avoid repeated pop-ups
set "SUCCESS_LOCK=%temp%\hfit_login_ok.tmp"
set "POP_LOCK=%temp%\hfit_last_pop.tmp"

:: Login success cooldown
if exist "%SUCCESS_LOCK%" (
    for %%f in ("%SUCCESS_LOCK%") do set "lock_time=%%~tf"
    for /f "tokens=1-5 delims=/: " %%d in ("%lock_time%") do set "lock_mark=%%d%%e%%f%%g%%h"
    for /f "tokens=1-5 delims=/: " %%d in ("%date% %time%") do set "now_mark=%%d%%e%%f%%g%%h"
    if "!lock_mark!"=="!now_mark!" goto WAIT_NEXT
)

:: Pop-up cooldown
if exist "%POP_LOCK%" (
    for %%f in ("%POP_LOCK%") do set "pop_time=%%~tf"
    for /f "tokens=1-5 delims=/: " %%d in ("%pop_time%") do set "pop_mark=%%d%%e%%f%%g%%h"
    for /f "tokens=1-5 delims=/: " %%d in ("%date% %time%") do set "now_mark=%%d%%e%%f%%g%%h"
    if "!pop_mark!"=="!now_mark!" goto WAIT_NEXT
)

:: 5. All checks passed, pop up portal page
start "" "%PORTAL_URL%"
echo. > "%POP_LOCK%"

:: 6. Update success lock after login
timeout /t 3 /nobreak >nul
ping -n 1 -w 500 www.baidu.com >nul 2>&1
if !errorlevel! equ 0 echo. > "%SUCCESS_LOCK%"

exit

:: Wait for next check, exit when timeout
:WAIT_NEXT
set /a loop_count+=1
if %loop_count% geq %MAX_WAIT_SEC% exit
timeout /t 1 /nobreak >nul
goto CHECK_LOOP