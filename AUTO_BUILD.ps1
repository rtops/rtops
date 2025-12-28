# ===================================================================
# ANDROID OBJECT DETECTOR - FULLSTÄNDIGT AUTOMATISK SETUP OCH BUILD
# ===================================================================

$ErrorActionPreference = "Continue"

Write-Host ""
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "  ANDROID OBJECT DETECTOR - AUTOMATISK INSTALLATION" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Detta script kommer AUTOMATISKT:" -ForegroundColor Yellow
Write-Host " [1] Kopiera projektet från WSL till Windows"
Write-Host " [2] Öppna Android Studio med projektet"
Write-Host " [3] Ge dig instruktioner för att bygga APK:n"
Write-Host ""
Write-Host "VIKTIGT: Du behöver inte göra något!" -ForegroundColor Green
Write-Host "         Låt scriptet köra klart." -ForegroundColor Green
Write-Host ""

Start-Sleep -Seconds 2

# ===================================================================
# STEG 1: Skapa projektmapp
# ===================================================================
Write-Host ""
Write-Host "[1/4] Skapar projektmapp i Windows..." -ForegroundColor Cyan

$projectPath = "C:\AndroidProjects\rtops"

if (Test-Path "C:\AndroidProjects\rtops") {
    Write-Host "Tar bort gammal version..." -ForegroundColor Yellow
    Remove-Item -Path "C:\AndroidProjects\rtops" -Recurse -Force
}

New-Item -ItemType Directory -Path "C:\AndroidProjects" -Force | Out-Null
Write-Host "OK!" -ForegroundColor Green

# ===================================================================
# STEG 2: Kopiera projekt från WSL
# ===================================================================
Write-Host ""
Write-Host "[2/4] Kopierar projekt från WSL till Windows..." -ForegroundColor Cyan
Write-Host "Detta tar 30-60 sekunder..." -ForegroundColor Yellow

$wslPaths = @(
    "\\wsl.localhost\Ubuntu\home\user\rtops",
    "\\wsl$\Ubuntu\home\user\rtops",
    "\\wsl$\Ubuntu-24.04\home\user\rtops",
    "\\wsl.localhost\Ubuntu-24.04\home\user\rtops"
)

$copied = $false
foreach ($wslPath in $wslPaths) {
    Write-Host "Försöker: $wslPath" -ForegroundColor Yellow
    if (Test-Path $wslPath) {
        try {
            Copy-Item -Path "$wslPath\*" -Destination "C:\AndroidProjects\rtops\" -Recurse -Force -ErrorAction Stop
            $copied = $true
            Write-Host "OK! Projektet kopierat!" -ForegroundColor Green
            break
        } catch {
            Write-Host "Misslyckades, försöker nästa..." -ForegroundColor Yellow
        }
    }
}

# Försök med WSL-kommando om kopiering misslyckades
if (-not $copied) {
    Write-Host "Försöker med WSL-kommando..." -ForegroundColor Yellow
    try {
        wsl cp -r /home/user/rtops /mnt/c/AndroidProjects/ 2>$null
        if (Test-Path "C:\AndroidProjects\rtops") {
            $copied = $true
            Write-Host "OK! Projektet kopierat med WSL!" -ForegroundColor Green
        }
    } catch {
        # Ignorera fel
    }
}

if (-not $copied) {
    Write-Host ""
    Write-Host "FEL: Kunde inte kopiera projekt automatiskt!" -ForegroundColor Red
    Write-Host ""
    Write-Host "Manuellt steg krävs:" -ForegroundColor Yellow
    Write-Host "1. Öppna File Explorer"
    Write-Host "2. Gå till en av dessa sökvägar:"
    foreach ($path in $wslPaths) {
        Write-Host "   - $path" -ForegroundColor Cyan
    }
    Write-Host "3. Kopiera hela rtops-mappen till C:\AndroidProjects\"
    Write-Host ""
    Read-Host "Tryck Enter när du kopierat mappen"
}

# ===================================================================
# STEG 3: Hitta och starta Android Studio
# ===================================================================
Write-Host ""
Write-Host "[3/4] Startar Android Studio..." -ForegroundColor Cyan

$studioPaths = @(
    "$env:ProgramFiles\Android\Android Studio\bin\studio64.exe",
    "${env:ProgramFiles(x86)}\Android\Android Studio\bin\studio64.exe",
    "$env:LOCALAPPDATA\Programs\Android Studio\bin\studio64.exe",
    "C:\Program Files\Android\Android Studio\bin\studio64.exe"
)

$studioPath = $null
foreach ($path in $studioPaths) {
    if (Test-Path $path) {
        $studioPath = $path
        Write-Host "Hittade Android Studio: $path" -ForegroundColor Green
        break
    }
}

if ($studioPath) {
    Write-Host "Startar Android Studio med projektet..." -ForegroundColor Yellow
    Start-Process $studioPath -ArgumentList "`"$projectPath`""
    Write-Host "OK!" -ForegroundColor Green
} else {
    Write-Host ""
    Write-Host "VARNING: Android Studio hittades inte automatiskt!" -ForegroundColor Red
    Write-Host ""
    Write-Host "Öppna Android Studio manuellt och:" -ForegroundColor Yellow
    Write-Host "1. File → Open"
    Write-Host "2. Välj: $projectPath"
    Write-Host "3. Trust Project"
    Write-Host ""
}

# ===================================================================
# STEG 4: Instruktioner
# ===================================================================
Write-Host ""
Write-Host "[4/4] Android Studio startar nu..." -ForegroundColor Cyan
Write-Host ""
Write-Host "============================================================" -ForegroundColor Green
Write-Host "  NÄSTA STEG I ANDROID STUDIO:" -ForegroundColor Green
Write-Host "============================================================" -ForegroundColor Green
Write-Host ""
Write-Host "1. NÄR ANDROID STUDIO ÖPPNAS:" -ForegroundColor Yellow
Write-Host "   - Klicka 'Trust Project' om det frågas"
Write-Host ""
Write-Host "2. VÄNTA PÅ GRADLE SYNC:" -ForegroundColor Yellow
Write-Host "   - Se progress bar längst ner i fönster"
Write-Host "   - Detta tar 2-5 minuter första gången"
Write-Host "   - Vänta tills det står 'Gradle sync finished'"
Write-Host ""
Write-Host "3. BYGG APK:N:" -ForegroundColor Yellow
Write-Host "   - Klicka: Build → Build Bundle(s) / APK(s) → Build APK(s)"
Write-Host "   - Vänta 1-2 minuter"
Write-Host "   - Du får ett meddelande när det är klart"
Write-Host ""
Write-Host "4. HITTA APK:N:" -ForegroundColor Yellow
Write-Host "   - Klicka på 'locate' i meddelandet"
Write-Host "   - Eller gå till:" -ForegroundColor Cyan
Write-Host "     $projectPath\app\build\outputs\apk\debug\"
Write-Host "   - Filen heter: " -NoNewline
Write-Host "app-debug.apk" -ForegroundColor Green
Write-Host ""
Write-Host "5. INSTALLERA PÅ TELEFONEN:" -ForegroundColor Yellow
Write-Host "   - Kopiera app-debug.apk till din Google Pixel 8a"
Write-Host "   - Öppna filen på telefonen"
Write-Host "   - Installera!"
Write-Host ""
Write-Host "============================================================" -ForegroundColor Green

Start-Sleep -Seconds 3

Write-Host ""
Write-Host "Öppnar projektmappen i Explorer för dig..." -ForegroundColor Cyan
Start-Process explorer.exe -ArgumentList $projectPath

Write-Host ""
Write-Host "============================================================" -ForegroundColor Green
Write-Host "  SETUP KLAR!" -ForegroundColor Green
Write-Host "============================================================" -ForegroundColor Green
Write-Host ""
Write-Host "Android Studio borde nu vara öppen med projektet." -ForegroundColor Cyan
Write-Host "Följ stegen ovan för att bygga APK:n." -ForegroundColor Cyan
Write-Host ""

Read-Host "Tryck Enter för att avsluta"
