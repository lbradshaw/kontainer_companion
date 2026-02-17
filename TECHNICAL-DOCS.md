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
  image_picker: ^1.0.4        # Camera and gallery access for images
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
- `GET /api/totes/:id` - Get tote details with images
- `POST /api/totes` - Create new tote
- `PUT /api/totes/:id` - Update tote name and items
- `POST /api/totes/:id/add-image` - Add image(s) to tote
- `DELETE /api/totes/:id/image/:imageId` - Delete specific image from tote
- `DELETE /api/totes/:id` - Delete tote
- `GET /api/settings` - Get app settings

### Data Model

```dart
class Tote {
  final int id;
  final String name;
  final String items;       // Newline-separated item list
  final String? qrCode;     // Base64 data URI for QR code image
  final List<ToteImage> images; // List of images stored in database
  
  // Helper method to show first 3 lines of items
  String getPreviewItems() {
    List<String> lines = items.split('\n');
    if (lines.length <= 3) return items;
    return '${lines.take(3).join('\n')}...';
  }
}

class ToteImage {
  final int id;
  final String data;  // Base64 encoded image data
  bool markedForDeletion = false; // UI flag for deletion
}
```

**Note**: Images are stored in the database as Base64 encoded data

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
- Editable form:
  - Tote name text field
  - Items text area (multiline)
- Image management:
  - Grid view of all tote images
  - Add images from camera or gallery
  - Delete images (tap to mark X, confirmed on save)
  - View full-size images on tap
- QR code display (if available)
- Update button to save changes
- Real-time refresh on screen load to sync with backend
- Delete confirmation dialog
- Error handling

#### Settings Screen
- Server URL configuration
- Save button with confirmation
- (Future: theme toggle, other preferences)

#### Scan Screen
- Full QR code scanner using mobile_scanner
- Real-time camera view with overlay
- Visual scanning frame with corner indicators
- Automatic tote lookup by QR code
- Navigation to tote detail on successful scan
- Error dialog for totes not found
- Flashlight toggle button
- Camera switch button (front/back)
- Works with printed QR codes (not reliable with screens)

## Current Implementation Status

### ✅ Completed
- Project scaffolding
- Theme system matching ToteTrax web
- Data models (Tote, ToteImage)
- API service with full CRUD operations including image management
- QR code lookup API endpoint (`getToteByQRCode`)
- Home screen with tote list
- Add tote screen with form validation
- Tote detail/edit screen with:
  - Name and items editing
  - Image gallery with add/delete
  - Camera and gallery integration
  - Full-size image viewer
  - Auto-refresh on load
  - Delete tote functionality
- Settings screen (basic server URL)
- **QR code scanner (fully functional)**:
  - Real-time camera scanning
  - Visual overlay with scanning frame
  - Automatic tote lookup and navigation
  - Error handling for missing totes
  - Flashlight and camera switch controls
  - Works with printed QR codes
- Camera permissions (Android + iOS)
- Pull-to-refresh
- Error handling and loading states
- Navigation between screens
- Responsive Material Design UI
- Image picker integration (camera + gallery)
- Base64 image encoding/decoding
- Code analysis passing with minimal warnings

### 🚧 Planned/Future
- Fix image upload (critical - images not saving to backend)
- Server connectivity testing
- Shared preferences for settings persistence
- Offline support with local caching
- Search and filter functionality
- Dark mode toggle in settings
- Export/import data
- Image compression for large photos
- Batch image operations
- Image reordering
- Manual QR code entry option

## Key Features & Implementation Details

### Image Management
- **Storage**: Images stored as Base64 encoded data in SQLite database
- **Upload**: Uses `image_picker` package for camera and gallery access
- **Display**: Grid view with thumbnails, tap for full-screen view
- **Deletion**: Mark for deletion with X overlay, confirmed on update
- **Auto-refresh**: Tote details reload from server on screen navigation to sync changes

### Update Workflow
1. Load tote details from server (ensures latest data)
2. User edits name, items, adds/removes images
3. On save:
   - Update tote name and items via PUT request
   - Upload new images via POST to add-image endpoint
   - Delete marked images via DELETE requests
4. Refresh tote data after successful update

### Data Synchronization
- Mobile app fetches fresh data on screen load
- Changes made via web UI are reflected immediately when details screen is opened
- No local caching to avoid stale data issues

## Version History

- **v0.3.0** (Feb 2026) - QR Scanner Implementation
  - Full QR code scanner using mobile_scanner package
  - Real-time barcode detection with visual overlay
  - Automatic tote lookup by QR code (GET /api/tote/qr/{code})
  - Camera permissions configured (Android + iOS)
  - Flashlight and camera switching
  - Error handling for totes not found
  - Works reliably with printed QR codes

- **v0.2.0** (Feb 2026) - Image Management Update
  - Added full image CRUD operations
  - Camera and gallery integration
  - Base64 image storage matching backend
  - Auto-refresh on detail screen load
  - Image deletion with visual feedback
  
- **v0.1.0** (Feb 2026) - Initial implementation
  - Flutter project created
  - Theme matching ToteTrax web
  - All CRUD screens implemented
  - API integration complete
  - Basic navigation and state management
  - Code quality verified (flutter analyze passes)

## Platform-Specific Considerations

### Android
- Camera permissions configured in AndroidManifest.xml:
  - `android.permission.CAMERA`
  - Hardware feature declarations (camera, autofocus)
- Minimum SDK version: 21 (Android 5.0)
- Uses Material Design
- QR scanner fully functional

### iOS
- Camera usage description in Info.plist:
  - `NSCameraUsageDescription`: "ToteTrax needs camera access to scan QR codes on storage totes"
- Minimum iOS version: 12.0
- Uses Cupertino design where appropriate
- QR scanner fully functional

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

## Best Practices

- Follows Material Design guidelines
- Supports both portrait and landscape orientations
- Implements accessibility features
- Uses semantic versioning
- Git repository initialized
- Base64 encoding for cross-platform image compatibility
- RESTful API design
- Proper error handling and user feedback

## Related Documentation

- See ToteTrax backend: `D:\projects\totetrax\TECHNICAL-DOCS.md`
- See FilaTrax Mobile: `D:\projects\filatrax_mobile\filatrax-mobile-info.md`
