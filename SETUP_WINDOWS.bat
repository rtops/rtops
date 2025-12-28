@echo off
REM ========================================
REM Android Object Detector - Auto Setup
REM ========================================

echo.
echo ========================================
echo   Android Object Detector Setup
echo ========================================
echo.
echo Detta script kommer att:
echo 1. Kopiera projektet fran WSL till Windows
echo 2. Oppna projektet i Windows Explorer
echo 3. Ge instruktioner for Android Studio
echo.

pause

echo.
echo [1/3] Skapar projektmapp i Windows...
if not exist "C:\AndroidProjects" mkdir "C:\AndroidProjects"
echo OK!

echo.
echo [2/3] Kopierar projekt fran WSL...
echo Detta kan ta 1-2 minuter...

REM Forsok med olika WSL-sokvaegar
echo Forsoker: \\wsl.localhost\Ubuntu\home\user\rtops
xcopy "\\wsl.localhost\Ubuntu\home\user\rtops" "C:\AndroidProjects\rtops" /E /I /H /Y >nul 2>&1

if %ERRORLEVEL% neq 0 (
    echo Forsoker: \\wsl$\Ubuntu\home\user\rtops
    xcopy "\\wsl$\Ubuntu\home\user\rtops" "C:\AndroidProjects\rtops" /E /I /H /Y >nul 2>&1
)

if %ERRORLEVEL% neq 0 (
    echo Forsoker: \\wsl$\Ubuntu-24.04\home\user\rtops
    xcopy "\\wsl$\Ubuntu-24.04\home\user\rtops" "C:\AndroidProjects\rtops" /E /I /H /Y >nul 2>&1
)

if %ERRORLEVEL% neq 0 (
    echo.
    echo VARNING: Automatisk kopiering misslyckades!
    echo.
    echo Manuella steg:
    echo 1. Oppna File Explorer
    echo 2. Ga till: \\wsl.localhost\Ubuntu\home\user\rtops
    echo    (eller \\wsl$\Ubuntu\home\user\rtops)
    echo 3. Kopiera hela rtops-mappen till C:\AndroidProjects\
    echo.
    pause
    exit /b 1
)

echo OK! Projektet kopierat till C:\AndroidProjects\rtops

echo.
echo [3/3] Oppnar projektmappen...
explorer "C:\AndroidProjects\rtops"
echo OK!

echo.
echo ========================================
echo   Nasta steg:
echo ========================================
echo.
echo 1. Oppna Android Studio
echo 2. Klicka: File - Open
echo 3. Valj: C:\AndroidProjects\rtops
echo 4. Klicka: Trust Project
echo 5. Vanta pa Gradle sync (2-5 minuter)
echo 6. Klicka: Build - Build Bundle(s) / APK(s) - Build APK(s)
echo.
echo APK:n kommer skapas i:
echo C:\AndroidProjects\rtops\app\build\outputs\apk\debug\app-debug.apk
echo.
echo ========================================

pause
