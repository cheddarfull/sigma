@echo off
color 05
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
    echo UAC.ShellExecute "%~s0", "", "", "runas", 1 >> "%temp%\getadmin.vbs"
    "%temp%\getadmin.vbs"
    del "%temp%\getadmin.vbs"
    exit /b
)

cd c:\windows\system32
cls

DISM.exe /Online /Cleanup-Image /Scanhealth
DISM.exe /Online /Cleanup-Image /Restorehealth
SFC /SCANNOW
cls
echo System Restart Required 
echo Would You Like To Restart Now? (y/n)
set /p ans=="y/n"
if /i %ans%==y goto shutdown
if /i %ans%==n goto later
:later
echo Dont Forget to Restart your PC Later!
timeout /t 10 >nul
pause
exit
:shutdown
shutdown -r -t 00
exit