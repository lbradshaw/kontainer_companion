# Kontainer Companion

**This is the official companion mobile app for [Kontainer](https://github.com/lbradshaw/kontainer).**

Kontainer Companion lets you manage your storage containers on the go, connecting directly to your Kontainer backend server.


Companion mobile app for Kontainer storage container inventory management system.

## Overview

Kontainer Mobile is a Flutter-based mobile application that connects to the Kontainer backend server to manage storage containers. The app provides QR code scanning capabilities to quickly access and update container information.

## Features

- **QR Code Scanning**: Scan container QR codes to instantly view container details
- **Container Management**: View, add, and edit storage containers
- **Image Gallery**: View multiple images associated with each container
- **Item List Management**: Track items stored in each container with quantities
- **Server Configuration**: Flexible server connection settings
- **Dark/Light Mode**: Theme support synchronized with Kontainer web app

## Technology Stack

- **Framework**: Flutter
- **State Management**: Provider
- **QR Code Scanning**: mobile_scanner
- **HTTP Client**: http package
- **Local Storage**: shared_preferences
- **Platforms**: Android, iOS, Web, Windows, macOS, Linux

## Project Structure

```
lib/
├── main.dart              # App entry point
├── models/                # Data models
├── screens/               # App screens/pages
├── services/              # API and business logic
├── utils/                 # Utilities and helpers
└── widgets/               # Reusable UI components
```

## Getting Started

### Prerequisites

- Flutter SDK (>=3.0.0)
- Kontainer backend server running

### Installation

1. Clone the repository
2. Install dependencies:
   ```bash
   flutter pub get
   ```
3. Run the app:
   ```bash
   flutter run
   ```

## Building

### Android
```bash
flutter build apk
# or
flutter build appbundle
```

### Windows
```bash
flutter build windows
```

### Linux
```bash
flutter build linux
```

### macOS
```bash
flutter build macos
```

### iOS
```bash
flutter build ios
```

#### iOS Distribution Notes
- Building for iOS requires a Mac and Xcode.
- You cannot freely distribute iOS binaries (IPA files) for public download due to Apple restrictions.
- Sideloading is only possible for developers with an Apple Developer account ($99/year) and limited to personal devices.
- TestFlight is Apple's beta distribution platform, but also requires a paid Developer account and App Store review.
- There is currently no funding to distribute Kontainer Companion on TestFlight or the App Store.
- If you want to run the app on your own iOS device, follow [Flutter's iOS deployment guide](https://docs.flutter.dev/deployment/ios) and note the limitations.
- For most users, Android APK and Windows EXE are the recommended options.

## Configuration

On first launch, configure the Kontainer server URL in the settings screen.

## Development

This project follows the same architecture patterns as FilaTrax Mobile, adapted for storage container management.

## License

Private project - not published to pub.dev

## Related Projects

- **Kontainer**: Main backend server (Go + HTML/CSS/JS)
- **FilaTrax**: Filament inventory management system
