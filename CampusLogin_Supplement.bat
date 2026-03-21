@echo off
setlocal enabledelayedexpansion

set "ENABLE_AUTO_POP=true"
set "PORTAL_URL=http://10.10.2.15"
set "TARGET_WIFI=HFIT.portal"
set "SUCCESS_COOLDOWN_MIN=5"
set "POP_COOLDOWN_SEC=30")
set "MAX_WAIT_SEC=20"

if /i "%ENABLE_AUTO_POP%"=="false" exit

set "loop_count=0"
:CHECK_LOOP

set "CURRENT_SSID="
for /f "tokens=2 delims=: " %%a in ('netsh wlan show interfaces 2^>nul ^| findstr /i "SSID"') do (
    set "CURRENT_SSID=%%a"
    set "CURRENT_SSID=!CURRENT_SSID: =!"
)

set "IN_CAMPUS=false"
if "!CURRENT_SSID!"=="%TARGET_WIFI%" set "IN_CAMPUS=true"
if "!IN_CAMPUS!"=="false" (
    ping -n 1 -w 500 10.10.2.15 >nul 2>&1
    if !errorlevel! equ 0 set "IN_CAMPUS=true"
)

if "!IN_CAMPUS!"=="false" goto WAIT_NEXT

ping -n 1 -w 500 www.baidu.com >nul 2>&1
if !errorlevel! equ 0 exit

set "SUCCESS_LOCK=%temp%\hfit_login_ok.tmp"
set "POP_LOCK=%temp%\hfit_last_pop.tmp"

if exist "%SUCCESS_LOCK%" (
    for %%f in ("%SUCCESS_LOCK%") do set "lock_time=%%~tf"
    for /f "tokens=1-5 delims=/: " %%d in ("%lock_time%") do set "lock_mark=%%d%%e%%f%%g%%h"
    for /f "tokens=1-5 delims=/: " %%d in ("%date% %time%") do set "now_mark=%%d%%e%%f%%g%%h"
    if "!lock_mark!"=="!now_mark!" goto WAIT_NEXT
)

if exist "%POP_LOCK%" (
    for %%f in ("%POP_LOCK%") do set "pop_time=%%~tf"
    for /f "tokens=1-5 delims=/: " %%d in ("%pop_time%") do set "pop_mark=%%d%%e%%f%%g%%h"
    for /f "tokens=1-5 delims=/: " %%d in ("%date% %time%") do set "now_mark=%%d%%e%%f%%g%%h"
    if "!pop_mark!"=="!now_mark!" goto WAIT_NEXT
)

start "" "%PORTAL_URL%"
echo. > "%POP_LOCK%"

timeout /t 3 /nobreak >nul
ping -n 1 -w 500 www.baidu.com >nul 2>&1
if !errorlevel! equ 0 echo. > "%SUCCESS_LOCK%"

exit

:WAIT_NEXT
set /a loop_count+=1
if %loop_count% geq %MAX_WAIT_SEC% exit
timeout /t 1 /nobreak >nul
goto CHECK_LOOP
