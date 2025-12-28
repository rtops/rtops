# ========================================
# Android Object Detector - Auto Setup (PowerShell)
# ========================================

Write-Host ""
Write-Host "========================================"
Write-Host "  Android Object Detector Setup"
Write-Host "========================================"
Write-Host ""
Write-Host "Detta script kommer att:"
Write-Host "1. Kopiera projektet från WSL till Windows"
Write-Host "2. Öppna projektet i Windows Explorer"
Write-Host "3. Försöka öppna Android Studio (om tillgängligt)"
Write-Host ""

Read-Host "Tryck Enter för att fortsätta"

Write-Host ""
Write-Host "[1/4] Skapar projektmapp i Windows..." -ForegroundColor Cyan
$projectPath = "C:\AndroidProjects\rtops"
New-Item -ItemType Directory -Path "C:\AndroidProjects" -Force | Out-Null
Write-Host "OK!" -ForegroundColor Green

Write-Host ""
Write-Host "[2/4] Kopierar projekt från WSL..." -ForegroundColor Cyan
Write-Host "Detta kan ta 1-2 minuter..."

$wslPaths = @(
    "\\wsl.localhost\Ubuntu\home\user\rtops",
    "\\wsl$\Ubuntu\home\user\rtops",
    "\\wsl$\Ubuntu-24.04\home\user\rtops"
)

$copied = $false
foreach ($wslPath in $wslPaths) {
    Write-Host "Försöker: $wslPath" -ForegroundColor Yellow
    if (Test-Path $wslPath) {
        try {
            Copy-Item -Path $wslPath -Destination "C:\AndroidProjects\" -Recurse -Force -ErrorAction Stop
            $copied = $true
            Write-Host "OK! Projektet kopierat!" -ForegroundColor Green
            break
        } catch {
            Write-Host "Misslyckades, försöker nästa..." -ForegroundColor Yellow
        }
    }
}

if (-not $copied) {
    Write-Host ""
    Write-Host "VARNING: Automatisk kopiering misslyckades!" -ForegroundColor Red
    Write-Host ""
    Write-Host "Manuella steg:" -ForegroundColor Yellow
    Write-Host "1. Öppna File Explorer"
    Write-Host "2. Gå till en av dessa:"
    foreach ($path in $wslPaths) {
        Write-Host "   - $path"
    }
    Write-Host "3. Kopiera hela rtops-mappen till C:\AndroidProjects\"
    Write-Host ""
    Read-Host "Tryck Enter när du är klar"
}

Write-Host ""
Write-Host "[3/4] Öppnar projektmappen..." -ForegroundColor Cyan
Start-Process explorer.exe -ArgumentList "C:\AndroidProjects\rtops"
Write-Host "OK!" -ForegroundColor Green

Write-Host ""
Write-Host "[4/4] Letar efter Android Studio..." -ForegroundColor Cyan

$studioPaths = @(
    "$env:ProgramFiles\Android\Android Studio\bin\studio64.exe",
    "${env:ProgramFiles(x86)}\Android\Android Studio\bin\studio64.exe",
    "$env:LOCALAPPDATA\Programs\Android Studio\bin\studio64.exe"
)

$studioFound = $false
foreach ($studioPath in $studioPaths) {
    if (Test-Path $studioPath) {
        Write-Host "Android Studio hittad!" -ForegroundColor Green
        Write-Host "Startar Android Studio..." -ForegroundColor Cyan
        Start-Process $studioPath -ArgumentList $projectPath
        $studioFound = $true
        break
    }
}

if (-not $studioFound) {
    Write-Host "Android Studio hittades inte automatiskt." -ForegroundColor Yellow
    Write-Host "Öppna Android Studio manuellt." -ForegroundColor Yellow
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "  Nästa steg:" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "1. I Android Studio som öppnades (eller öppna det manuellt):"
Write-Host "   - Om det inte öppnade projektet: File → Open"
Write-Host "   - Välj: C:\AndroidProjects\rtops"
Write-Host "2. Klicka: Trust Project"
Write-Host "3. Vänta på Gradle sync (2-5 minuter, se progress bar)"
Write-Host "4. Klicka: Build → Build Bundle(s) / APK(s) → Build APK(s)"
Write-Host ""
Write-Host "APK:n kommer skapas i:" -ForegroundColor Yellow
Write-Host "C:\AndroidProjects\rtops\app\build\outputs\apk\debug\app-debug.apk"
Write-Host ""
Write-Host "========================================" -ForegroundColor Green

Read-Host "Tryck Enter för att avsluta"
