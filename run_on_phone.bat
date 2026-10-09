@echo off
setlocal enabledelayedexpansion
title JuiceFlow Factory Manager - Android Deployment

echo ==============================================================================
echo        JUICEFLOW FACTORY MANAGER -- AUTOMATED ANDROID DEPLOYMENT
echo ==============================================================================
echo.

:: 1. Locate ADB
echo [1/4] Locating Android SDK and ADB...
set "ADB_BIN="

where adb >nul 2>nul
if %ERRORLEVEL% EQU 0 (
    set "ADB_BIN=adb"
    echo [OK] Found ADB in system PATH.
    goto :ADB_FOUND
)

if exist "%LOCALAPPDATA%\Android\Sdk\platform-tools\adb.exe" (
    set "ADB_BIN=%LOCALAPPDATA%\Android\Sdk\platform-tools\adb.exe"
    echo [OK] Found ADB at: %LOCALAPPDATA%\Android\Sdk\platform-tools\adb.exe
    goto :ADB_FOUND
)

if exist "C:\Users\%USERNAME%\AppData\Local\Android\Sdk\platform-tools\adb.exe" (
    set "ADB_BIN=C:\Users\%USERNAME%\AppData\Local\Android\Sdk\platform-tools\adb.exe"
    echo [OK] Found ADB at: C:\Users\%USERNAME%\AppData\Local\Android\Sdk\platform-tools\adb.exe
    goto :ADB_FOUND
)

echo [ERROR] ADB not found! Please check Android SDK location.
goto :END

:ADB_FOUND
echo.

:CHECK_DEVICE
echo [2/4] Checking connected Android devices...
"%ADB_BIN%" start-server >nul 2>nul

set DEVICE_COUNT=0
set DEVICE_UNAUTHORIZED=0
set DEVICE_OFFLINE=0
set "CONNECTED_DEVICE="

for /f "skip=1 tokens=1,2" %%A in ('"%ADB_BIN%" devices') do (
    if "%%B"=="device" (
        set /a DEVICE_COUNT+=1
        set "CONNECTED_DEVICE=%%A"
    )
    if "%%B"=="unauthorized" (
        set /a DEVICE_UNAUTHORIZED+=1
    )
    if "%%B"=="offline" (
        set /a DEVICE_OFFLINE+=1
    )
)

if %DEVICE_UNAUTHORIZED% GTR 0 (
    echo [WARNING] Device found but UNAUTHORIZED!
    echo Please UNLOCK your phone screen and tap "Always allow from this computer".
    echo.
)

if %DEVICE_OFFLINE% GTR 0 (
    echo [WARNING] Device found but reported as OFFLINE!
    echo Please UNLOCK your phone screen and reconnect the USB cable.
    echo.
)

if %DEVICE_COUNT% GTR 0 goto :DEVICE_READY

echo [WARNING] No authorized Android device detected.
echo.
echo Please ensure:
echo   1. Your phone is connected via USB cable.
echo   2. Phone screen is UNLOCKED.
echo   3. USB Debugging and "Install via USB" are turned ON.
echo   4. You tapped "Allow" on the phone screen prompt.
echo.
echo Press Enter to retry device detection, or Q to quit.
set /p RETRY_CHOICE="Choice: "
if /i "!RETRY_CHOICE!"=="Q" goto :END

echo Retrying...
"%ADB_BIN%" kill-server >nul 2>nul
"%ADB_BIN%" start-server >nul 2>nul
goto :CHECK_DEVICE

:DEVICE_READY
echo [OK] Connected Phone: %CONNECTED_DEVICE%
echo.

:: 3. Check or Build APK
set "APK_PATH=build\app\outputs\flutter-apk\app-debug.apk"
echo [3/4] Checking Application Package...

if exist "%APK_PATH%" (
    echo [OK] Ready APK found: %APK_PATH%
    echo.
    echo Choose an option:
    echo   [1] Fast Install ^& Launch (Instant - uses existing build)
    echo   [2] Recompile APK ^& Install (Takes 1-2 minutes)
    echo.
    set /p BUILD_CHOICE="Select (Default: 1): "
    if "!BUILD_CHOICE!"=="2" goto :DO_BUILD
    goto :DO_INSTALL
)

:DO_BUILD
echo.
echo Compiling Flutter Debug APK (flutter build apk --debug)...
call flutter build apk --debug
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Build failed! Check errors above.
    goto :END
)

:DO_INSTALL
echo.
:: 4. Install & Launch
echo [4/4] Installing JuiceFlow on your phone (%CONNECTED_DEVICE%)...
echo Note: Please keep phone screen UNLOCKED.
"%ADB_BIN%" -s %CONNECTED_DEVICE% install -r -d -t "%APK_PATH%"
if %ERRORLEVEL% NEQ 0 (
    echo.
    echo ==============================================================================
    echo [ERROR] Installation failed!
    echo Troubleshooting for Vivo / iQOO / Xiaomi / Oppo:
    echo   1. Turn ON "Install via USB" in Developer Options.
    echo   2. Keep screen unlocked while installing.
    echo   3. If Play Protect prompt shows, tap "Install anyway".
    echo ==============================================================================
    goto :END
)

echo [OK] JuiceFlow successfully installed!
echo.
echo Launching application on your phone screen...
set "PACKAGE_NAME=com.juiceflow.app.juice_flow"
"%ADB_BIN%" -s %CONNECTED_DEVICE% shell monkey -p %PACKAGE_NAME% -c android.intent.category.LAUNCHER 1 >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    "%ADB_BIN%" -s %CONNECTED_DEVICE% shell am start -n %PACKAGE_NAME%/.MainActivity >nul 2>nul
)

echo.
echo ==============================================================================
echo [SUCCESS] JuiceFlow Factory Manager is now RUNNING on your phone!
echo ==============================================================================
echo.

:END
echo Press any key to close this window...
pause >nul
