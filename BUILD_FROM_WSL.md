# Bygga från WSL (Avancerat)

Om du vill bygga APK:n direkt från WSL-terminalen istället för Windows Android Studio.

## Alternativ 1: Peka till Windows SDK (Snabbare)

### Steg 1: Hitta din Windows SDK-sökväg

Kör i **Windows PowerShell**:
```powershell
echo $env:LOCALAPPDATA\Android\Sdk
```

Vanligtvis: `C:\Users\<ditt-användarnamn>\AppData\Local\Android\Sdk`

### Steg 2: Konvertera till WSL-sökväg

Om Windows-sökvägen är:
```
C:\Users\YourName\AppData\Local\Android\Sdk
```

WSL-sökvägen blir:
```
/mnt/c/Users/YourName/AppData/Local/Android/Sdk
```

### Steg 3: Uppdatera local.properties

```bash
cd /home/user/rtops

# Ersätt YourName med ditt Windows-användarnamn
echo "sdk.dir=/mnt/c/Users/YourName/AppData/Local/Android/Sdk" > local.properties
```

### Steg 4: Bygg APK

```bash
./gradlew assembleDebug
```

**OBS:** Detta kan vara långsamt eftersom Gradle kör i WSL men använder Windows-filer.

## Alternativ 2: Installera Android SDK i WSL (Ren Linux-miljö)

### Steg 1: Installera JDK

```bash
sudo apt update
sudo apt install openjdk-17-jdk -y
java -version
```

### Steg 2: Ladda ner Android Command Line Tools

```bash
mkdir -p ~/Android/Sdk/cmdline-tools
cd ~/Android/Sdk/cmdline-tools

# Ladda ner senaste command line tools (Linux version)
wget https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip

# Extrahera
unzip commandlinetools-linux-11076708_latest.zip
mv cmdline-tools latest
```

### Steg 3: Konfigurera SDK

```bash
# Sätt miljövariabler (lägg till i ~/.bashrc för permanent)
export ANDROID_HOME=~/Android/Sdk
export PATH=$PATH:$ANDROID_HOME/cmdline-tools/latest/bin
export PATH=$PATH:$ANDROID_HOME/platform-tools

# Acceptera licenser
yes | sdkmanager --licenses

# Installera nödvändiga SDK-paket
sdkmanager "platform-tools" "platforms;android-34" "build-tools;34.0.0"
```

### Steg 4: Uppdatera local.properties

```bash
cd /home/user/rtops
echo "sdk.dir=$HOME/Android/Sdk" > local.properties
```

### Steg 5: Bygg APK

```bash
./gradlew assembleDebug
```

APK:n skapas i: `app/build/outputs/apk/debug/app-debug.apk`

## Installera APK på telefon

### Via USB (ADB)

1. Aktivera USB-debugging på Pixel 8a
2. Anslut via USB
3. Från WSL:
```bash
# Om du använder Windows SDK
/mnt/c/Users/YourName/AppData/Local/Android/Sdk/platform-tools/adb.exe devices

# Installera APK
/mnt/c/Users/YourName/AppData/Local/Android/Sdk/platform-tools/adb.exe install app/build/outputs/apk/debug/app-debug.apk
```

### Via filöverföring

1. Kopiera APK:n till Windows:
```bash
cp app/build/outputs/apk/debug/app-debug.apk /mnt/c/Users/YourName/Downloads/
```

2. Skicka filen till din telefon (via email, Google Drive, eller USB)
3. Öppna APK:n på telefonen för att installera

## Felsökning

### "Permission denied" för gradlew
```bash
chmod +x gradlew
```

### "ANDROID_HOME not set"
```bash
export ANDROID_HOME=~/Android/Sdk
# eller
export ANDROID_HOME=/mnt/c/Users/YourName/AppData/Local/Android/Sdk
```

### Gradle tar väldigt lång tid
- Detta är normalt första gången (laddar ner dependencies)
- Efterföljande builds blir snabbare
- Överväg att använda Windows Android Studio istället för bättre prestanda
