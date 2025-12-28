# Öppna WSL-projektet i Windows Android Studio

## Steg 1: Hitta projektet från Windows

1. Öppna **File Explorer** i Windows
2. I adressfältet, skriv:
   ```
   \\wsl$\Ubuntu\home\user\rtops
   ```
   (Om din WSL-distro heter något annat än "Ubuntu", byt ut det)

3. Du bör nu se projekt-filerna (app, gradle, build.gradle, etc.)

## Steg 2: Öppna i Android Studio

1. Öppna **Android Studio** (på Windows)
2. Klicka **File → Open**
3. I dialog-rutan, skriv eller navigera till:
   ```
   \\wsl$\Ubuntu\home\user\rtops
   ```
4. Klicka **OK**

## Steg 3: Låt Android Studio konfigurera projektet

1. Android Studio kommer fråga om du litar på projektet - klicka **Trust Project**
2. Gradle kommer automatiskt synka (tar 2-5 minuter första gången)
3. Android Studio skapar automatiskt `local.properties` med rätt SDK-sökväg

## Steg 4: Bygg APK

1. Vänta tills Gradle sync är klar (se progress bar längst ner)
2. Klicka **Build → Build Bundle(s) / APK(s) → Build APK(s)**
3. När det är klart visas ett meddelande med länk till APK:n
4. APK:n finns i: `\\wsl$\Ubuntu\home\user\rtops\app\build\outputs\apk\debug\app-debug.apk`

## Troubleshooting

### Om \\wsl$ inte fungerar:
- Kontrollera att WSL är igång: `wsl --list --running` i PowerShell
- Starta WSL om nödvändigt

### Om Gradle sync misslyckas:
- Klicka på **File → Invalidate Caches / Restart**
- Kontrollera att du har JDK installerad (Android Studio brukar inkludera detta)

### Om SDK saknas:
- I Android Studio: **Tools → SDK Manager**
- Installera:
  - Android SDK Platform 34
  - Android SDK Build-Tools 34.0.0
  - Android SDK Platform-Tools

## Alternativ: Bygga från WSL kommandoraden

Om du vill bygga direkt från WSL istället, se BUILD_FROM_WSL.md
