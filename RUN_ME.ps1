# ===================================================================
# ANDROID OBJECT DETECTOR - SUPER AUTOMATISK INSTALLATION
# Kör detta script från Windows PowerShell (Admin)
# ===================================================================

Write-Host ""
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "  ANDROID OBJECT DETECTOR" -ForegroundColor Cyan
Write-Host "  Super Automatisk Installation & Build" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host ""

# Kontrollera admin-rättigheter
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $isAdmin) {
    Write-Host "VIKTIGT: Detta script behöver köras som Administrator!" -ForegroundColor Red
    Write-Host ""
    Write-Host "Starta om PowerShell som Administrator och kör:" -ForegroundColor Yellow
    Write-Host "Set-Location `"\\wsl.localhost\Ubuntu\home\user\rtops`"" -ForegroundColor Cyan
    Write-Host ".\RUN_ME.ps1" -ForegroundColor Cyan
    Write-Host ""
    Read-Host "Tryck Enter för att avsluta"
    exit 1
}

Write-Host "Detta script kommer AUTOMATISKT:" -ForegroundColor Yellow
Write-Host " [1] Konfigurera WSL för Windows-åtkomst"
Write-Host " [2] Starta om WSL"
Write-Host " [3] Kopiera projektet till Windows"
Write-Host " [4] Starta Android Studio"
Write-Host " [5] Ge dig instruktioner för att bygga APK:n"
Write-Host ""
Write-Host "Du behöver INTE göra något!" -ForegroundColor Green
Write-Host ""

Read-Host "Tryck Enter för att börja"

# ===================================================================
# STEG 1: Konfigurera WSL (redan gjort i WSL)
# ===================================================================
Write-Host ""
Write-Host "[1/5] WSL-konfiguration är redan klar..." -ForegroundColor Cyan
Write-Host "OK!" -ForegroundColor Green

# ===================================================================
# STEG 2: Starta om WSL för att aktivera konfigurationen
# ===================================================================
Write-Host ""
Write-Host "[2/5] Startar om WSL för att aktivera Windows-åtkomst..." -ForegroundColor Cyan
Write-Host "Stänger alla WSL-instanser..." -ForegroundColor Yellow

try {
    wsl --shutdown 2>$null
    Start-Sleep -Seconds 3
    Write-Host "OK! WSL omstartad" -ForegroundColor Green
} catch {
    Write-Host "Varning: Kunde inte starta om WSL automatiskt" -ForegroundColor Yellow
}

# ===================================================================
# STEG 3: Kopiera projekt till Windows
# ===================================================================
Write-Host ""
Write-Host "[3/5] Kopierar projekt från WSL till Windows..." -ForegroundColor Cyan

$projectPath = "C:\AndroidProjects\rtops"

# Ta bort gammal version
if (Test-Path $projectPath) {
    Write-Host "Tar bort gammal version..." -ForegroundColor Yellow
    Remove-Item -Path $projectPath -Recurse -Force
}

New-Item -ItemType Directory -Path "C:\AndroidProjects" -Force | Out-Null

$wslPaths = @(
    "\\wsl.localhost\Ubuntu\home\user\rtops",
    "\\wsl$\Ubuntu\home\user\rtops",
    "\\wsl.localhost\Ubuntu-24.04\home\user\rtops",
    "\\wsl$\Ubuntu-24.04\home\user\rtops"
)

$copied = $false
foreach ($wslPath in $wslPaths) {
    if (Test-Path $wslPath) {
        Write-Host "Kopierar från: $wslPath" -ForegroundColor Yellow
        try {
            Copy-Item -Path "$wslPath\*" -Destination $projectPath -Recurse -Force -ErrorAction Stop
            $copied = $true
            Write-Host "OK! Projektet kopierat!" -ForegroundColor Green
            break
        } catch {
            Write-Host "Misslyckades, försöker nästa..." -ForegroundColor Yellow
        }
    }
}

if (-not $copied) {
    Write-Host "Försöker med WSL-kommando..." -ForegroundColor Yellow
    wsl bash -c "mkdir -p /mnt/c/AndroidProjects && cp -r /home/user/rtops /mnt/c/AndroidProjects/" 2>$null
    Start-Sleep -Seconds 2
    if (Test-Path $projectPath) {
        $copied = $true
        Write-Host "OK! Kopierat med WSL!" -ForegroundColor Green
    }
}

if (-not $copied) {
    Write-Host ""
    Write-Host "FEL: Kopiering misslyckades!" -ForegroundColor Red
    Write-Host "Manuellt steg krävs - se SNABBSTART.txt" -ForegroundColor Yellow
    Read-Host "Tryck Enter för att avsluta"
    exit 1
}

# ===================================================================
# STEG 4: Starta Android Studio
# ===================================================================
Write-Host ""
Write-Host "[4/5] Startar Android Studio..." -ForegroundColor Cyan

$studioPaths = @(
    "$env:ProgramFiles\Android\Android Studio\bin\studio64.exe",
    "${env:ProgramFiles(x86)}\Android\Android Studio\bin\studio64.exe",
    "$env:LOCALAPPDATA\Programs\Android Studio\bin\studio64.exe"
)

$studioPath = $null
foreach ($path in $studioPaths) {
    if (Test-Path $path) {
        $studioPath = $path
        break
    }
}

if ($studioPath) {
    Write-Host "Startar: $studioPath" -ForegroundColor Yellow
    Start-Process $studioPath -ArgumentList "`"$projectPath`""
    Write-Host "OK! Android Studio startar..." -ForegroundColor Green
} else {
    Write-Host "Varning: Android Studio hittades inte" -ForegroundColor Yellow
    Write-Host "Öppna Android Studio manuellt: $projectPath" -ForegroundColor Cyan
}

# ===================================================================
# STEG 5: Instruktioner
# ===================================================================
Write-Host ""
Write-Host "[5/5] Öppnar projektmappen..." -ForegroundColor Cyan
Start-Process explorer.exe -ArgumentList $projectPath
Write-Host "OK!" -ForegroundColor Green

Write-Host ""
Write-Host "============================================================" -ForegroundColor Green
Write-Host "  AUTOMATISK SETUP KLAR!" -ForegroundColor Green
Write-Host "============================================================" -ForegroundColor Green
Write-Host ""
Write-Host "Android Studio öppnas nu med projektet." -ForegroundColor Cyan
Write-Host ""
Write-Host "NÄSTA STEG I ANDROID STUDIO:" -ForegroundColor Yellow
Write-Host ""
Write-Host "1. Klicka 'Trust Project' när det frågas" -ForegroundColor White
Write-Host ""
Write-Host "2. Vänta på Gradle sync (2-5 min)" -ForegroundColor White
Write-Host "   - Progress bar längst ner visar status" -ForegroundColor Gray
Write-Host ""
Write-Host "3. Bygg APK:" -ForegroundColor White
Write-Host "   Build → Build Bundle(s) / APK(s) → Build APK(s)" -ForegroundColor Cyan
Write-Host ""
Write-Host "4. APK:n skapas här:" -ForegroundColor White
Write-Host "   $projectPath\app\build\outputs\apk\debug\app-debug.apk" -ForegroundColor Cyan
Write-Host ""
Write-Host "5. Kopiera till Pixel 8a och installera!" -ForegroundColor White
Write-Host ""
Write-Host "============================================================" -ForegroundColor Green
Write-Host ""

Read-Host "Tryck Enter för att avsluta"
