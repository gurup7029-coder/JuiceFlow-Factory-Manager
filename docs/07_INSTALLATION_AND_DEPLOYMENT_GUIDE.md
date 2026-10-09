# 07. Installation & Deployment Guide

## 1. Prerequisites
- **Flutter SDK:** Version 3.47+ (Stable channel)
- **Dart SDK:** Version 3.13+
- **Android SDK:** Platform Android 34 / 35 / 36 with Build-Tools
- **Java Development Kit (JDK):** JDK 17 or higher (bundled with Android Studio at `D:\android studio\jbr`)
- **ADB Platform Tools:** Located at `%LOCALAPPDATA%\Android\Sdk\platform-tools\adb.exe`

---

## 2. Automated USB Physical Phone Deployment
1. Connect your Android smartphone to your workstation with a high-quality USB data cable.
2. Ensure **Developer Options** and **USB Debugging** are toggled ON.
3. Execute the automated batch script:
   ```cmd
   c:\projects\Juice shop\run_on_phone.bat
   ```
4. The script performs:
   - Dynamic ADB detection.
   - Device connectivity and authorization verification.
   - Code validation via `dart analyze lib`.
   - Building debug APK (`flutter build apk --debug`).
   - Installing the APK via `adb install -r`.
   - Launching `com.juiceflow.app.juice_flow` on the phone screen.

---

## 3. Manual Build Commands

### Clean and Fetch Dependencies
```cmd
flutter clean
flutter pub get
```

### Static Analysis
```cmd
dart analyze lib
```

### Build APK
```cmd
flutter build apk --debug
```

### Output Location
The generated APK is located at:
`c:\projects\Juice shop\build\app\outputs\flutter-apk\app-debug.apk`
