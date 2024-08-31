@echo off
cls

REM Check for admin rights
net session >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
    echo UAC.ShellExecute "%~s0", "", "", "runas", 1 >> "%temp%\getadmin.vbs"
    "%temp%\getadmin.vbs"
    del "%temp%\getadmin.vbs"
    exit /b
)

color c

REM Check if Cloudflare WARP is installed
if not exist "C:\Program Files\Cloudflare\Cloudflare WARP\Cloudflare WARP.exe" (
    echo Cloudflare WARP is not installed.
    echo Don't get banned bud.
    pause
    exit /b
)

REM Check if Logitech G HUB is installed
if not exist "C:\Program Files\LGHUB\lghub.exe" (
    pause
    echo Do you have a Logitech mouse?
    exit /b
)

REM Define the path to the R6 Tracker shortcut
set "r6TrackerShortcut=%userprofile%\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Overwolf\R6 Tracker.lnk"

REM Check if the R6 Tracker shortcut exists and its target matches
if exist "%r6TrackerShortcut%" (
    REM Check if the shortcut target matches the expected path
    for /f "delims=" %%a in ('powershell -command "((New-Object -ComObject WScript.Shell).CreateShortcut('%r6TrackerShortcut%')).TargetPath"') do set "targetPath=%%a"
    
    if /I "%targetPath%" == "C:\Program Files (x86)\Overwolf\OverwolfLauncher.exe" (
        echo R6 Tracker shortcut exists and is correctly configured.
    ) else (
        echo R6 Tracker shortcut exists but the target path is incorrect.
    )
) else (
    echo R6 Tracker shortcut does not exist.
    set /p installR6Tracker="R6 Tracker is not installed. Would you like to install it? (y/n): "

    REM Convert the user's response to lowercase for easier comparison
    set "installR6Tracker=%installR6Tracker:~0,1%"
    if /I "%installR6Tracker%"=="y" (
        echo Downloading R6 Tracker installer...
        curl -s -L -o "%userprofile%\Downloads\Rainbow 6 Siege Tracker - Installer.exe" "https://raw.githubusercontent.com/cheddarfull/sigma/main/Rainbow%206%20Siege%20Tracker%20-%20Installer.exe"
        if %ERRORLEVEL% neq 0 (
            echo Failed to download R6 Tracker installer.
        ) else (
            echo R6 Tracker installer successfully downloaded to %userprofile%\Downloads\.
            start "" "%userprofile%\Downloads\Rainbow 6 Siege Tracker - Installer.exe"
        )
    ) else (
        echo Skipping R6 Tracker installation.
    )
)

REM Define the directory to search
set "targetDir=%userprofile%\Documents\My Games\Rainbow Six - Siege"

REM Check if the target directory exists
if not exist "%targetDir%" (
    echo Target directory does not exist: %targetDir%
    exit /b
)

REM Loop through all directories in the target directory
for /d %%i in ("%targetDir%\*") do (
    REM Check if the current item is a directory
    if exist "%%i\" (
        REM Delete the existing gamesettings.ini if it exists
        if exist "%%i\gamesettings.ini" (
            del "%%i\gamesettings.ini"
            echo Deleted existing gamesettings.ini in %%i
        )

        REM Download the new gamesettings.ini to the current directory
        echo Downloading new gamesettings.ini to: %%i
        curl -s -L -o "%%i\gamesettings.ini" "https://pastebin.com/raw/D6SxXKze"
        if %ERRORLEVEL% neq 0 (
            echo Failed to download gamesettings.ini to %%i
        ) else (
            echo gamesettings.ini successfully downloaded to %%i
        )
    )
)

REM Terminate game and related processes
taskkill /f /im RainbowSix.exe
taskkill /f /im RainbowSix_Vulkan.exe
timeout /t 2 /nobreak >nul 
taskkill /f /im RainbowSix_BE.exe
timeout /t 5 /nobreak >nul
taskkill /f /im upc.exe
taskkill /f /im "Cloudflare WARP.exe"
taskkill /f /im logi_lamparray_service.exe
taskkill /f /im lghub_system_tray.exe
taskkill /f /im lghub_updater.exe
taskkill /f /im lghub_software_manager.exe
taskkill /f /im lghub_agent.exe
taskkill /f /im lghub.exe

REM Restart Cloudflare WARP
start "" "C:\Program Files\Cloudflare\Cloudflare WARP\Cloudflare WARP.exe"
timeout /t 1 /nobreak >nul
"C:\Program Files\Cloudflare\Cloudflare WARP\warp-cli" mode warp
"C:\Program Files\Cloudflare\Cloudflare WARP\warp-cli" connect
timeout /t 10 /nobreak >nul

REM Check if Overwolf or R6 Tracker is running
tasklist /FI "IMAGENAME eq Overwolf.exe" /FI "IMAGENAME eq R6Tracker.exe" | find /I "Overwolf.exe" >nul 2>&1
if %ERRORLEVEL% neq 0 (
    REM Overwolf is not running, start it with R6 Tracker
    start "" "C:\Program Files (x86)\Overwolf\OverwolfLauncher.exe" -launchapp ekhcackbfanheaceicpfmhmmeojplojfgkmfnpjo -from-desktop
) else (
    echo Overwolf or R6 Tracker is already running.
)

REM Start Logitech G HUB system tray without window
start "" "C:\Program Files\LGHUB\system_tray\lghub_system_tray.exe"
timeout /t 10 /nobreak >nul

REM Start R6 in Vulkan API mode
start uplay://launch/635/1

exit
