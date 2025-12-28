# Object Detector - AI-baserad Objektigenkänning för Android

En Android-app utvecklad för Google Pixel 8a som använder AI/ML för att känna igen objekt i realtid via kameran och kategorisera dem baserat på återkommande mönster.

## Funktioner

- **Realtids objektigenkänning** - Använder Google ML Kit Object Detection API
- **Kameraintegration** - CameraX för smidig kameraåtkomst
- **Mönsterigenkänning** - Spårar och kategoriserar upprepade objekt
- **Visuell feedback** - Gröna detektionsboxar med labels och konfidenspoäng
- **Statistik** - Live-statistik över detekterade objekt med antal
- **Enkel UI** - Material Design med mörkt tema

## Teknisk Stack

- **Språk**: Kotlin
- **Min SDK**: 26 (Android 8.0)
- **Target SDK**: 34 (Android 14)
- **Kamera**: CameraX 1.3.1
- **AI/ML**: Google ML Kit Object Detection 17.0.1
- **UI**: Material Components, ConstraintLayout, RecyclerView

## Projektstruktur

```
app/src/main/
├── java/com/rtops/objectdetector/
│   ├── MainActivity.kt              # Huvudaktivitet med kamera och UI
│   ├── ObjectDetectorHelper.kt      # ML Kit wrapper för objektdetektering
│   ├── ObjectTracker.kt             # Spårar och kategoriserar objekt
│   ├── GraphicOverlay.kt            # Rita detektionsboxar på kameran
│   └── ObjectStatsAdapter.kt        # RecyclerView adapter för statistik
├── res/
│   ├── layout/
│   │   ├── activity_main.xml        # Huvud-layout med kamera och statistik
│   │   └── item_object_stat.xml     # Layout för statistikobjekt
│   ├── values/
│   │   ├── strings.xml              # Strängresurser
│   │   ├── colors.xml               # Färgpalette
│   │   └── themes.xml               # App-tema
│   └── drawable/                    # Ikoner och grafik
└── AndroidManifest.xml              # App-manifest med permissions
```

## Hur det fungerar

### 1. Objektdetektering (ObjectDetectorHelper.kt)
- Konfigurerar ML Kit Object Detector i STREAM_MODE
- Aktiverar multi-objekt detektering och klassificering
- Processar kameraframes och returnerar detekterade objekt

### 2. Mönsterigenkänning (ObjectTracker.kt)
- **ObjectStats**: Håller koll på varje unikt objekt och antal gånger det detekterats
- **DetectionHistory**: Sparar historik på upp till 1000 detektioner
- **Smart räkning**: Undviker dubbelräkning genom 2-sekunders timeout
- **Mönsteranalys**: Grupperar och kategoriserar återkommande objekt

### 3. Visuell Overlay (GraphicOverlay.kt)
- Rita gröna bounding boxes runt detekterade objekt
- Visa objektnamn och konfidenspoäng
- Skalerar korrekt till olika skärmstorlekar

### 4. Användargränssnitt (MainActivity.kt)
- CameraX för kameraförhandsvisning
- Realtidsuppdatering av detektioner
- RecyclerView med statistik över detekterade objekt
- Knapp för att rensa statistik

## Bygga APK

### Förutsättningar
- Android Studio (Hedgehog 2023.1.1 eller senare)
- JDK 8 eller senare
- Android SDK med Build Tools 34.0.0
- Google Pixel 8a eller annan Android-enhet med kamera (min SDK 26)

### Steg för att bygga

#### Med Android Studio:
1. Öppna projektet i Android Studio
2. Synka Gradle-filer (File → Sync Project with Gradle Files)
3. Anslut din Google Pixel 8a via USB med USB-debugging aktiverat
4. Klicka på Run (gröna play-knappen) eller Build → Build Bundle(s) / APK(s) → Build APK(s)
5. APK:n skapas i `app/build/outputs/apk/debug/app-debug.apk`

#### Med kommandoraden:
```bash
# Installera Android SDK först om du inte har det
# Uppdatera local.properties med korrekt SDK-path

# Bygg debug APK
./gradlew assembleDebug

# Installera direkt på ansluten enhet
./gradlew installDebug

# Bygg release APK (osignerad)
./gradlew assembleRelease
```

APK:n finns sedan i:
- Debug: `app/build/outputs/apk/debug/app-debug.apk`
- Release: `app/build/outputs/apk/release/app-release-unsigned.apk`

### Signera Release APK
För att skapa en signerad release APK som kan distribueras:

1. Skapa en keystore:
```bash
keytool -genkey -v -keystore my-release-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias my-alias
```

2. Lägg till i `app/build.gradle`:
```gradle
android {
    signingConfigs {
        release {
            storeFile file("my-release-key.jks")
            storePassword "password"
            keyAlias "my-alias"
            keyPassword "password"
        }
    }
    buildTypes {
        release {
            signingConfig signingConfigs.release
            minifyEnabled true
            proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'
        }
    }
}
```

3. Bygg signerad release:
```bash
./gradlew assembleRelease
```

## Användning

1. Installera APK:n på din Google Pixel 8a
2. Starta appen "Object Detector"
3. Ge kameraåtkomst när du blir tillfrågad
4. Rikta kameran mot olika objekt
5. Appen kommer:
   - Rita gröna boxar runt detekterade objekt
   - Visa objektnamn och konfidenspoäng
   - Uppdatera statistik i botten med antal för varje objekttyp
6. Tryck på "Rensa Statistik" för att börja om

## Detekterade Objektkategorier

ML Kit kan detektera och klassificera följande huvudkategorier:
- Fashion goods (kläder, accessoarer)
- Food (mat och dryck)
- Home goods (hushållsartiklar)
- Places (platser och byggnader)
- Plants (växter)

Samt generiska objekt utan specifik kategori.

## Systemkrav

- **Enhet**: Google Pixel 8a (eller liknande med minst Android 8.0)
- **Kamera**: Bakre kamera med autofokus
- **RAM**: Minst 2GB
- **Lagring**: ~50MB för app + ML-modeller

## Felsökning

### Appen kraschar vid start
- Kontrollera att kameraåtkomst är tillåten i Inställningar → Appar → Object Detector
- Se till att enheten har bakre kamera

### Inga objekt detekteras
- Försök med bättre belysning
- Håll objekt inom 0.5-2 meter från kameran
- Vissa objekt kräver tydlig kontrast mot bakgrunden

### Build-fel
- Synka Gradle: `./gradlew --refresh-dependencies`
- Rensa build-cache: `./gradlew clean`
- Kontrollera att SDK path är korrekt i `local.properties`

## Framtida Förbättringar

- [ ] Export av statistik till CSV/JSON
- [ ] Anpassad ML-modell för specifika objekttyper
- [ ] Röststöd för objektmeddelanden
- [ ] Pausknapp för att frysa detektering
- [ ] Mörkt/ljust temaväxling
- [ ] Inställningar för detekteringskänslighet
- [ ] Stöd för främre kamera

## Licens

Detta projekt är skapat för demonstrationssyfte.

## Utvecklare

Utvecklad för rtops - AI Object Detection Project

## Support

För frågor eller problem, vänligen kontakta projektutvecklaren.
