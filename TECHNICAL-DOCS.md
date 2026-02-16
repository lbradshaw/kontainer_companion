# ToteTrax Mobile - Technical Documentation

## Project Information

**Project Name**: ToteTrax Mobile  
**Technology Stack**: Flutter (Dart)  
**Purpose**: Mobile companion app for ToteTrax storage tote inventory management  
**Created**: February 2026  
**Repository**: D:\projects\totetrax_mobile

## Architecture Overview

### Technology Stack

- **Frontend Framework**: Flutter 3.x
- **Language**: Dart
- **State Management**: Provider pattern
- **HTTP Client**: http package
- **QR Scanner**: mobile_scanner package
- **Local Storage**: shared_preferences
- **Supported Platforms**: Android, iOS, Web, Windows, macOS, Linux

### Dependencies

```yaml
dependencies:
  flutter: sdk
  cupertino_icons: ^1.0.6
  mobile_scanner: ^5.0.0      # QR code scanning
  http: ^1.1.0                # API communication
  shared_preferences: ^2.2.0  # Local settings storage
  provider: ^6.1.0            # State management
```

## Project Structure

```
totetrax_mobile/
├── lib/
│   ├── main.dart              # App entry point
│   ├── models/                # Data models
│   │   ├── tote.dart          # Tote data model
│   │   └── settings.dart      # App settings model
│   ├── screens/               # App screens
│   │   ├── home_screen.dart
│   │   ├── scanner_screen.dart
│   │   ├── tote_detail_screen.dart
│   │   └── settings_screen.dart
│   ├── services/              # Business logic
│   │   ├── api_service.dart   # Backend API communication
│   │   └── storage_service.dart # Local storage
│   ├── utils/                 # Helpers
│   │   ├── constants.dart
│   │   └── theme.dart
│   └── widgets/               # Reusable components
│       ├── tote_card.dart
│       └── image_gallery.dart
├── android/                   # Android-specific code
├── ios/                       # iOS-specific code
├── web/                       # Web-specific code
├── windows/                   # Windows-specific code
├── linux/                     # Linux-specific code
├── macos/                     # macOS-specific code
├── pubspec.yaml              # Dependencies
└── README.md
```

## Backend Integration

### API Endpoints (ToteTrax Server)

The mobile app communicates with the ToteTrax backend server:

- `GET /api/totes` - List all totes
- `GET /api/totes/:id` - Get tote details
- `POST /api/totes` - Create new tote
- `PUT /api/totes/:id` - Update tote
- `DELETE /api/totes/:id` - Delete tote
- `GET /api/settings` - Get app settings

### Data Model

```dart
class Tote {
  String id;
  String name;
  String qrCode;
  List<String> images;  // Base64 encoded images stored in DB
  List<Item> items;
  DateTime createdAt;
  DateTime updatedAt;
}

class Item {
  String name;
  int quantity;
}
```

## Key Features Implementation

### 1. QR Code Scanning

Uses `mobile_scanner` package for cross-platform QR code scanning:
- Camera permission handling
- Auto-focus and torch control
- QR code detection and parsing
- Direct navigation to tote details

### 2. Image Handling

- Multiple images per tote
- Images stored as base64 in SQLite database
- Image gallery view with thumbnails
- Full-screen image viewing
- Camera integration for adding photos

### 3. Server Configuration

- Server URL stored in shared_preferences
- Connection testing
- Automatic retry with timeout handling
- Error handling and user feedback

### 4. State Management

Uses Provider pattern:
- `ToteProvider` - Manages tote data
- `SettingsProvider` - Manages app settings
- `ThemeProvider` - Manages dark/light mode

### 5. Offline Support

- Local caching of tote data
- Queue sync when connection restored
- Optimistic UI updates
- Conflict resolution

## Platform-Specific Considerations

### Android
- Camera permissions in AndroidManifest.xml
- Minimum SDK version: 21 (Android 5.0)
- Uses Material Design

### iOS
- Camera usage description in Info.plist
- Minimum iOS version: 12.0
- Uses Cupertino design where appropriate

### Web
- Camera access through browser APIs
- Responsive design for mobile browsers
- Limited offline capabilities

### Desktop (Windows/Linux/macOS)
- File picker for image selection (no camera)
- Keyboard navigation support
- Window management

## Development Workflow

### Running the App

```bash
# Run on connected device/emulator
flutter run

# Run on specific platform
flutter run -d windows
flutter run -d chrome
flutter run -d android
```

### Building

```bash
# Android
flutter build apk --release
flutter build appbundle --release

# iOS
flutter build ios --release

# Desktop
flutter build windows --release
flutter build linux --release
flutter build macos --release
```

### Testing

```bash
flutter test
flutter analyze
```

## Configuration Files

### pubspec.yaml
Defines dependencies, assets, and app metadata

### android/app/build.gradle
Android-specific configuration, permissions, min SDK

### ios/Runner/Info.plist
iOS-specific configuration, permissions, display names

## Similar to FilaTrax Mobile

This project uses the same technology stack and architecture as FilaTrax Mobile, adapted for storage tote management instead of filament spools. Key differences:

- **Data Model**: Totes instead of Spools
- **QR Codes**: Generated for storage totes instead of filament
- **Items List**: Text-based item inventory instead of filament properties
- **Images**: Multiple images per tote showing contents

## Future Enhancements

- NFC support for tote tagging
- Barcode scanning for items
- Export/import functionality
- Multi-user support
- Location tracking for totes
- Search and filter capabilities
- Batch operations
- Statistics and reports

## Version History

- **v0.1.0** - Initial project setup with Flutter structure
  - Basic project scaffolding
  - Dependencies configured
  - Directory structure created

## Notes

- Follows Material Design guidelines
- Supports both portrait and landscape orientations
- Implements accessibility features
- Uses semantic versioning
- Git repository initialized

## Related Documentation

- See ToteTrax backend: `D:\projects\totetrax\TECHNICAL-DOCS.md`
- See FilaTrax Mobile: `D:\projects\filatrax_mobile\filatrax-mobile-info.md`
