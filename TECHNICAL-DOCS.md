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
│   │   └── tote.dart          # Tote data model
│   ├── screens/               # App screens
│   │   ├── home_screen.dart       # Main tote list view
│   │   ├── add_tote_screen.dart   # Add new tote form
│   │   ├── tote_detail_screen.dart # View/edit tote details
│   │   ├── scan_screen.dart        # QR code scanner (placeholder)
│   │   └── settings_screen.dart    # Server configuration
│   ├── services/              # Business logic
│   │   └── api_service.dart   # Backend API communication
│   ├── utils/                 # Helpers
│   │   └── theme.dart         # App theme matching ToteTrax web
│   └── widgets/               # Reusable components (to be added)
├── android/                   # Android-specific code
├── ios/                       # iOS-specific code
├── web/                       # Web-specific code
├── windows/                   # Windows-specific code
├── linux/                     # Linux-specific code
├── macos/                     # macOS-specific code
├── test/                      # Unit and widget tests
├── pubspec.yaml              # Dependencies
├── README.md
└── TECHNICAL-DOCS.md         # This file
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
  final int id;
  final String name;
  final String items;       // Newline-separated item list
  final String? qrCode;     // Base64 data URI for QR code image
  
  // Helper method to show first 3 lines of items
  String getPreviewItems() {
    List<String> lines = items.split('\n');
    if (lines.length <= 3) return items;
    return '${lines.take(3).join('\n')}...';
  }
}
```

**Note**: Images are stored in the database (not in model yet - future enhancement)

## UI/UX Design

### Theme & Colors

Matches ToteTrax web application design:

**Light Mode:**
- Background: `#F5F5F5`
- Header: `#2C3E50` (dark blue-gray)
- Text: `#333333`
- Cards: `#FFFFFF`
- Border: `#DDDDDD`
- Primary: `#3498DB` (blue)
- Success: `#2ECC71` (green)
- Danger: `#E74C3C` (red)
- Warning: `#F39C12` (orange)

**Dark Mode:**
- Background: `#1A1A1A`
- Header: `#0D1117`
- Text: `#E0E0E0`
- Cards: `#2D2D2D`
- Border: `#404040`
- (Same accent colors as light mode)

### Screens

#### Home Screen
- AppBar with "ToteTrax" title
- Action buttons: Add New (+), Scan (QR), Settings
- List of tote cards showing:
  - Tote name (bold/large)
  - First 3 lines of items
- Pull-to-refresh functionality
- Loading spinner when fetching data
- Error state with retry button
- Empty state message

#### Add Tote Screen
- Form with:
  - Tote Name text field (required)
  - Items text area (10 lines, required)
- Save button with loading state
- Validation before submission
- Back navigation on success

#### Tote Detail Screen
- AppBar with delete button
- Full tote information:
  - Name (large heading)
  - Complete items list
  - QR code image (if available)
- Delete confirmation dialog
- Error handling

#### Settings Screen
- Server URL configuration
- Save button with confirmation
- (Future: theme toggle, other preferences)

#### Scan Screen
- Placeholder for QR scanner
- "Coming Soon" message
- Camera permission note

## Current Implementation Status

### ✅ Completed
- Project scaffolding
- Theme system matching ToteTrax web
- Data models (Tote)
- API service with full CRUD operations
- Home screen with tote list
- Add tote screen with form validation
- Tote detail screen with delete
- Settings screen (basic server URL)
- Scan screen (placeholder)
- Pull-to-refresh
- Error handling and loading states
- Navigation between screens
- Responsive Material Design UI
- Code analysis passing with no issues

### 🚧 Planned/Future
- QR code scanner implementation
- Camera integration for images
- Image upload and gallery
- Server connectivity testing
- Shared preferences for settings persistence
- Offline support with local caching
- Search and filter
- Dark mode toggle in settings
- Export/import data

## Version History

- **v0.1.0** (Feb 2026) - Initial implementation
  - Flutter project created
  - Theme matching ToteTrax web
  - All CRUD screens implemented
  - API integration complete
  - Basic navigation and state management
  - Code quality verified (flutter analyze passes)

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

## Development Commands

```bash
# Get dependencies
flutter pub get

# Run code analysis
flutter analyze

# Run tests
flutter test

# Run app (debug mode)
flutter run

# Build for production
flutter build apk --release      # Android APK
flutter build appbundle --release # Android App Bundle
flutter build windows --release   # Windows
flutter build linux --release     # Linux
```

## Notes

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

- **v0.1.0** (Feb 2026) - Initial implementation
  - Flutter project created
  - Theme matching ToteTrax web
  - All CRUD screens implemented
  - API integration complete
  - Basic navigation and state management
  - Code quality verified (flutter analyze passes)

## Development Commands

- Follows Material Design guidelines
- Supports both portrait and landscape orientations
- Implements accessibility features
- Uses semantic versioning
- Git repository initialized

## Related Documentation

- See ToteTrax backend: `D:\projects\totetrax\TECHNICAL-DOCS.md`
- See FilaTrax Mobile: `D:\projects\filatrax_mobile\filatrax-mobile-info.md`
