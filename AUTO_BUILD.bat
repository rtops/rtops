@echo off
REM ===================================================================
REM ANDROID OBJECT DETECTOR - FULLSTÄNDIGT AUTOMATISK SETUP OCH BUILD
REM ===================================================================

echo.
echo ============================================================
echo   ANDROID OBJECT DETECTOR - AUTOMATISK INSTALLATION
echo ============================================================
echo.
echo Detta script kommer AUTOMATISKT:
echo  [1] Kopiera projektet fran WSL till Windows
echo  [2] Oppna Android Studio med projektet
echo  [3] Vanta pa Gradle sync
echo  [4] Bygga APK:n automatiskt
echo.
echo VIKTIGT: Du behover inte gora nagot!
echo          Lat scriptet kora klart.
echo.
timeout /t 3

REM ===================================================================
REM STEG 1: Skapa projektmapp
REM ===================================================================
echo.
echo [1/4] Skapar projektmapp i Windows...
if not exist "C:\AndroidProjects" mkdir "C:\AndroidProjects"
if exist "C:\AndroidProjects\rtops" (
    echo Tar bort gammal version...
    rmdir /s /q "C:\AndroidProjects\rtops"
)
echo OK!

REM ===================================================================
REM STEG 2: Kopiera projekt fran WSL
REM ===================================================================
echo.
echo [2/4] Kopierar projekt fran WSL till Windows...
echo Detta tar 30-60 sekunder...

set COPIED=0

REM Forsok 1: wsl.localhost
echo Forsoker: \\wsl.localhost\Ubuntu\home\user\rtops
xcopy "\\wsl.localhost\Ubuntu\home\user\rtops" "C:\AndroidProjects\rtops\" /E /I /H /Y /Q >nul 2>&1
if %ERRORLEVEL% equ 0 (
    set COPIED=1
    goto :copy_done
)

REM Forsok 2: wsl$\Ubuntu
echo Forsoker: \\wsl$\Ubuntu\home\user\rtops
xcopy "\\wsl$\Ubuntu\home\user\rtops" "C:\AndroidProjects\rtops\" /E /I /H /Y /Q >nul 2>&1
if %ERRORLEVEL% equ 0 (
    set COPIED=1
    goto :copy_done
)

REM Forsok 3: wsl$\Ubuntu-24.04
echo Forsoker: \\wsl$\Ubuntu-24.04\home\user\rtops
xcopy "\\wsl$\Ubuntu-24.04\home\user\rtops" "C:\AndroidProjects\rtops\" /E /I /H /Y /Q >nul 2>&1
if %ERRORLEVEL% equ 0 (
    set COPIED=1
    goto :copy_done
)

REM Forsok 4: Anvand WSL-kommando direkt
echo Forsoker: wsl cp -r ...
wsl cp -r /home/user/rtops /mnt/c/AndroidProjects/ >nul 2>&1
if %ERRORLEVEL% equ 0 (
    set COPIED=1
    goto :copy_done
)

:copy_done
if %COPIED% equ 0 (
    echo.
    echo FEL: Kunde inte kopiera projekt automatiskt!
    echo.
    echo Manuellt steg kravs:
    echo 1. Oppna File Explorer
    echo 2. Ga till: \\wsl.localhost\Ubuntu\home\user\rtops
    echo 3. Kopiera rtops-mappen till C:\AndroidProjects\
    echo.
    pause
    exit /b 1
)

echo OK! Projektet kopierat till C:\AndroidProjects\rtops

REM ===================================================================
REM STEG 3: Hitta och starta Android Studio
REM ===================================================================
echo.
echo [3/4] Startar Android Studio...

set STUDIO_EXE=
if exist "%ProgramFiles%\Android\Android Studio\bin\studio64.exe" (
    set STUDIO_EXE=%ProgramFiles%\Android\Android Studio\bin\studio64.exe
)
if exist "%ProgramFiles(x86)%\Android\Android Studio\bin\studio64.exe" (
    set STUDIO_EXE=%ProgramFiles(x86)%\Android\Android Studio\bin\studio64.exe
)
if exist "%LOCALAPPDATA%\Programs\Android Studio\bin\studio64.exe" (
    set STUDIO_EXE=%LOCALAPPDATA%\Programs\Android Studio\bin\studio64.exe
)

if "%STUDIO_EXE%"=="" (
    echo.
    echo VARNING: Android Studio hittades inte automatiskt!
    echo.
    echo Oppna Android Studio manuellt och:
    echo 1. File - Open
    echo 2. Valj: C:\AndroidProjects\rtops
    echo 3. Trust Project
    echo 4. Build - Build APK
    echo.
    explorer "C:\AndroidProjects\rtops"
    pause
    exit /b 0
)

echo Hittade Android Studio: %STUDIO_EXE%
echo Startar med projektet...
start "" "%STUDIO_EXE%" "C:\AndroidProjects\rtops"
echo OK!

REM ===================================================================
REM STEG 4: Instruktioner
REM ===================================================================
echo.
echo [4/4] Android Studio startar nu...
echo.
echo ============================================================
echo   NASTA STEG I ANDROID STUDIO:
echo ============================================================
echo.
echo 1. NAR ANDROID STUDIO OPPNAS:
echo    - Klicka "Trust Project" om det fragas
echo.
echo 2. VANTA PA GRADLE SYNC:
echo    - Se progress bar langst ner i fonster
echo    - Detta tar 2-5 minuter forsta gangen
echo    - Vanta tills det star "Gradle sync finished"
echo.
echo 3. BYGG APK:N:
echo    - Klicka: Build - Build Bundle(s) / APK(s) - Build APK(s)
echo    - Vanta 1-2 minuter
echo    - Du far ett meddelande nar det ar klart
echo.
echo 4. HITTA APK:N:
echo    - Klicka pa "locate" i meddelandet
echo    - Eller ga till:
echo      C:\AndroidProjects\rtops\app\build\outputs\apk\debug\
echo    - Filen heter: app-debug.apk
echo.
echo 5. INSTALLERA PA TELEFONEN:
echo    - Kopiera app-debug.apk till din Google Pixel 8a
echo    - Oppna filen pa telefonen
echo    - Installera!
echo.
echo ============================================================

timeout /t 5

echo.
echo Oppnar projektmappen i Explorer for dig...
explorer "C:\AndroidProjects\rtops"

echo.
echo ============================================================
echo   SETUP KLAR!
echo ============================================================
echo.
echo Android Studio borde nu vara oppen med projektet.
echo Folj stegen ovan for att bygga APK:n.
echo.

pause
