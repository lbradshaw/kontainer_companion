# ToteTrax Mobile

Companion mobile app for ToteTrax storage tote inventory management system.

## Overview

ToteTrax Mobile is a Flutter-based mobile application that connects to the ToteTrax backend server to manage storage totes. The app provides QR code scanning capabilities to quickly access and update tote information.

## Features

- **QR Code Scanning**: Scan tote QR codes to instantly view tote details
- **Tote Management**: View, add, and edit storage totes
- **Image Gallery**: View multiple images associated with each tote
- **Item List Management**: Track items stored in each tote with quantities
- **Server Configuration**: Flexible server connection settings
- **Dark/Light Mode**: Theme support synchronized with ToteTrax web app

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
- ToteTrax backend server running

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

### iOS
```bash
flutter build ios
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

## Configuration

On first launch, configure the ToteTrax server URL in the settings screen.

## Development

This project follows the same architecture patterns as FilaTrax Mobile, adapted for storage tote management.

## License

Private project - not published to pub.dev

## Related Projects

- **ToteTrax**: Main backend server (Go + HTML/CSS/JS)
- **FilaTrax**: Filament inventory management system
