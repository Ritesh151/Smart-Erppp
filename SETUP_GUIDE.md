# SmartERP Setup Guide

## 📋 Prerequisites

Before you begin, ensure you have the following installed:

### Required Software

1. **Flutter SDK** (version 3.0.0 or higher)
   - Download from: https://flutter.dev/docs/get-started/install
   - Verify installation: `flutter --version`

2. **Dart SDK** (version 3.0.0 or higher)
   - Comes bundled with Flutter
   - Verify: `dart --version`

3. **IDE** (Choose one)
   - Android Studio with Flutter plugin
   - VS Code with Flutter extension
   - IntelliJ IDEA with Flutter plugin

4. **Git** (for version control)
   - Download from: https://git-scm.com/downloads
   - Verify: `git --version`

### Platform-Specific Requirements

#### For Android Development
- Android Studio
- Android SDK (API level 21 or higher)
- Android Emulator or physical device

#### For iOS Development (macOS only)
- Xcode (latest version)
- CocoaPods: `sudo gem install cocoapods`
- iOS Simulator or physical device

#### For Web Development
- Chrome browser
- Enable web support: `flutter config --enable-web`

#### For Desktop Development
- **Windows:** Visual Studio 2019 or later with C++ tools
- **macOS:** Xcode command line tools
- **Linux:** Required libraries (see Flutter docs)

## 🚀 Installation Steps

### Step 1: Clone or Navigate to Project

```bash
cd "/run/media/ritesh/Project Data/Flutter Projects/Siddhivinayak Enterprise/smarterp"
```

### Step 2: Install Dependencies

```bash
flutter pub get
```

This will download all required packages listed in `pubspec.yaml`.

### Step 3: Verify Installation

```bash
flutter doctor
```

Ensure all checks pass. Fix any issues reported.

### Step 4: Check Available Devices

```bash
flutter devices
```

This shows all connected devices and emulators.

## 🏃 Running the Application

### Run on Default Device

```bash
flutter run
```

### Run on Specific Device

```bash
# List devices
flutter devices

# Run on specific device
flutter run -d <device-id>
```

### Run in Different Modes

```bash
# Debug mode (default)
flutter run

# Profile mode (for performance testing)
flutter run --profile

# Release mode (optimized)
flutter run --release
```

### Run on Specific Platforms

```bash
# Android
flutter run -d android

# iOS
flutter run -d ios

# Web
flutter run -d chrome

# Windows
flutter run -d windows

# macOS
flutter run -d macos

# Linux
flutter run -d linux
```

## 🔧 Development Setup

### VS Code Setup

1. Install Flutter extension
2. Install Dart extension
3. Open project folder
4. Press F5 to run with debugging

**Recommended VS Code Extensions:**
- Flutter
- Dart
- Pubspec Assist
- Flutter Widget Snippets
- Error Lens

### Android Studio Setup

1. Install Flutter plugin
2. Install Dart plugin
3. Open project
4. Click Run button or Shift+F10

### Configure Launch Settings

Create `.vscode/launch.json`:

```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "SmartERP (Debug)",
      "request": "launch",
      "type": "dart",
      "program": "lib/main.dart"
    },
    {
      "name": "SmartERP (Profile)",
      "request": "launch",
      "type": "dart",
      "flutterMode": "profile",
      "program": "lib/main.dart"
    },
    {
      "name": "SmartERP (Release)",
      "request": "launch",
      "type": "dart",
      "flutterMode": "release",
      "program": "lib/main.dart"
    }
  ]
}
```

## 🧪 Testing

### Run All Tests

```bash
flutter test
```

### Run Specific Test File

```bash
flutter test test/unit/auth_service_test.dart
```

### Run with Coverage

```bash
flutter test --coverage
```

### Generate Coverage Report

```bash
# Install lcov (Linux/macOS)
brew install lcov  # macOS
sudo apt-get install lcov  # Linux

# Generate HTML report
genhtml coverage/lcov.info -o coverage/html

# Open report
open coverage/html/index.html  # macOS
xdg-open coverage/html/index.html  # Linux
```

## 🏗️ Building for Production

### Android APK

```bash
# Build APK
flutter build apk

# Build split APKs (smaller size)
flutter build apk --split-per-abi

# Output: build/app/outputs/flutter-apk/app-release.apk
```

### Android App Bundle (for Play Store)

```bash
flutter build appbundle

# Output: build/app/outputs/bundle/release/app-release.aab
```

### iOS

```bash
# Build iOS app
flutter build ios

# Build IPA (for distribution)
flutter build ipa
```

### Web

```bash
# Build web app
flutter build web

# Output: build/web/
```

### Desktop

```bash
# Windows
flutter build windows

# macOS
flutter build macos

# Linux
flutter build linux
```

## 🔍 Troubleshooting

### Common Issues and Solutions

#### Issue: "Waiting for another flutter command to release the startup lock"

**Solution:**
```bash
# Delete lock file
rm -rf ~/.flutter/bin/cache/lockfile
```

#### Issue: "Unable to locate Android SDK"

**Solution:**
```bash
# Set Android SDK path
export ANDROID_HOME=/path/to/android/sdk
export PATH=$PATH:$ANDROID_HOME/tools:$ANDROID_HOME/platform-tools
```

#### Issue: "CocoaPods not installed" (iOS)

**Solution:**
```bash
sudo gem install cocoapods
pod setup
```

#### Issue: "Gradle build failed"

**Solution:**
```bash
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
```

#### Issue: "Version solving failed"

**Solution:**
```bash
flutter clean
rm pubspec.lock
flutter pub get
```

#### Issue: "Hot reload not working"

**Solution:**
- Restart the app: Press 'R' in terminal
- Full restart: Press 'Shift+R' in terminal
- Or restart IDE

## 📱 Device Setup

### Android Device

1. Enable Developer Options:
   - Go to Settings > About Phone
   - Tap "Build Number" 7 times

2. Enable USB Debugging:
   - Settings > Developer Options
   - Enable "USB Debugging"

3. Connect device via USB
4. Verify: `flutter devices`

### iOS Device

1. Connect device to Mac
2. Trust computer on device
3. Open Xcode
4. Add Apple ID in Preferences > Accounts
5. Select device in Xcode
6. Run from Xcode or Flutter

### Emulator Setup

#### Android Emulator

```bash
# List available emulators
flutter emulators

# Launch emulator
flutter emulators --launch <emulator-id>
```

#### iOS Simulator (macOS only)

```bash
# Open simulator
open -a Simulator

# Or use Xcode > Open Developer Tool > Simulator
```

## 🔐 Login Credentials

For testing the application, use these credentials:

```
Email: ritesh.work.1510@gmail.com
Password: 8980614160@.com
```

## 📊 Performance Profiling

### Profile Mode

```bash
flutter run --profile
```

### DevTools

```bash
# Run app in profile mode
flutter run --profile

# Open DevTools
flutter pub global activate devtools
flutter pub global run devtools
```

### Performance Overlay

Add to your app:
```dart
MaterialApp(
  showPerformanceOverlay: true,
  // ...
)
```

## 🔄 Updating Dependencies

### Update All Packages

```bash
flutter pub upgrade
```

### Update Specific Package

```bash
flutter pub upgrade package_name
```

### Check Outdated Packages

```bash
flutter pub outdated
```

## 🧹 Cleaning Project

### Clean Build Files

```bash
flutter clean
```

### Full Clean (including pub cache)

```bash
flutter clean
flutter pub cache repair
flutter pub get
```

## 📝 Code Generation

If you add code generation in future:

```bash
# Run build_runner
flutter pub run build_runner build

# Watch for changes
flutter pub run build_runner watch

# Delete conflicting outputs
flutter pub run build_runner build --delete-conflicting-outputs
```

## 🌐 Environment Configuration

### Development Environment

Create `.env.development`:
```
API_URL=http://localhost:3000
DEBUG_MODE=true
```

### Production Environment

Create `.env.production`:
```
API_URL=https://api.smarterp.com
DEBUG_MODE=false
```

## 📦 Asset Management

### Adding Images

1. Place images in `assets/images/`
2. Update `pubspec.yaml`:
```yaml
flutter:
  assets:
    - assets/images/logo.png
```
3. Run `flutter pub get`

### Adding Fonts

1. Place fonts in `fonts/`
2. Update `pubspec.yaml`:
```yaml
flutter:
  fonts:
    - family: CustomFont
      fonts:
        - asset: fonts/CustomFont-Regular.ttf
        - asset: fonts/CustomFont-Bold.ttf
          weight: 700
```

## 🚨 Error Handling

### Enable Verbose Logging

```bash
flutter run -v
```

### Check Logs

```bash
# Android
flutter logs

# Or use adb
adb logcat

# iOS
flutter logs

# Or use Console.app on macOS
```

## 💡 Tips for Development

1. **Hot Reload:** Press 'r' in terminal for quick updates
2. **Hot Restart:** Press 'R' for full restart
3. **Widget Inspector:** Press 'i' to toggle inspector
4. **Performance Overlay:** Press 'p' to toggle
5. **Debug Paint:** Press 'P' to show debug paint
6. **Quit:** Press 'q' to quit

## 📚 Additional Resources

- [Flutter Documentation](https://flutter.dev/docs)
- [Dart Documentation](https://dart.dev/guides)
- [Flutter Cookbook](https://flutter.dev/docs/cookbook)
- [Flutter YouTube Channel](https://www.youtube.com/c/flutterdev)
- [Flutter Community](https://flutter.dev/community)

## 🆘 Getting Help

If you encounter issues:

1. Check this guide
2. Review error messages carefully
3. Search Flutter documentation
4. Check Stack Overflow
5. Contact project maintainer: ritesh.work.1510@gmail.com

---

**Happy Coding! 🚀**
