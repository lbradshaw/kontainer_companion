# Kontainer Mobile - Technical Documentation

## Project Information

**Project Name**: Kontainer Mobile  
**Technology Stack**: Flutter (Dart)  
**Purpose**: Mobile companion app for Kontainer storage container inventory management  
**Created**: February 2026  
**Repository**: D:\projects\kontainer_companion

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
kontainer_companion/
├── lib/
│   ├── main.dart              # App entry point
│   ├── models/                # Data models
│   │   └── tote.dart          # Kontainer data model
│   ├── screens/               # App screens
│   │   ├── home_screen.dart       # Main kontainer list view
│   │   ├── add_tote_screen.dart   # Add new kontainer form (deprecated)
│   │   ├── tote_view_screen.dart  # View kontainer details (read-only)
│   │   ├── tote_detail_screen.dart # Edit kontainer (create/update)
│   │   ├── scan_screen.dart        # QR code scanner
│   │   ├── search_screen.dart      # Search kontainers by name/items
│   │   └── settings_screen.dart    # Server configuration
│   ├── services/              # Business logic
│   │   └── api_service.dart   # Backend API communication
│   ├── utils/                 # Helpers
│   │   └── theme.dart         # App theme matching Kontainer web
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

### API Endpoints (Kontainer Server)

The mobile app communicates with the Kontainer backend server:

- `GET /api/totes` - List top-level kontainers only (depth=0)
- `GET /api/totes/all` - List all kontainers including sub-containers (for search)
- `GET /api/totes/:id` - Get kontainer details with images and children
- `POST /api/totes` - Create new kontainer (accepts optional parent_id)
- `PUT /api/totes/:id` - Update kontainer name and items
- `POST /api/totes/:id/add-image` - Add image(s) to kontainer
- `DELETE /api/totes/:id/image/:imageId` - Delete specific image from kontainer
- `DELETE /api/totes/:id` - Delete kontainer
- `GET /api/settings` - Get app settings

### Data Model

```dart
class Tote {
  final int id;
  final String name;
  final String items;       // Newline-separated item list
  final String? location;   // Physical storage location (optional)
  final String? qrCode;     // Base64 data URI for QR code image
  final List<Uint8List> images; // List of images stored in database
  final List<int> imageIds; // Image IDs from backend
  final int? parentId;      // Parent container ID (null for top-level)
  final int depth;          // Nesting level: 0=top-level, 1=sub-container
  final List<Tote>? children; // Sub-containers (for parent containers)
  
  // Helper method to show first 3 lines of items
  String getPreviewItems() {
    List<String> lines = items.split('\n');
    if (lines.length <= 3) return items;
    return '${lines.take(3).join('\n')}...';
  }
}
```

**Note**: Represents Kontainer instances; images are stored in the database as Base64 encoded data

## UI/UX Design

### Theme & Colors

Matches Kontainer web application design:

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
- AppBar with "Kontainer" title
- Action buttons: Refresh, Search, Add New (+), Scan (QR), Settings
- List of **top-level kontainer cards only** (depth=0) showing:
  - Kontainer name (bold/large)
  - First 3 lines of items
  - **Sub-container count badge** (green) if has children
- Tap card to view kontainer details
- Pull-to-refresh functionality
- Manual refresh button to sync with backend
- Loading spinner when fetching data
- Error state with retry button
- Empty state message (no error when database is empty)

#### Kontainer View Screen (Read-Only)
- View kontainer details without editing
- AppBar with Edit and Delete buttons
- **Parent breadcrumb** for sub-containers (depth=1) - always navigates to parent container view (loads fresh parent data)
- **Sub-container indicator badge** (orange) for depth=1 containers
- Display sections:
  - Kontainer name (large, bold)
  - Location (with 📍 icon, if set)
  - Items list (full text)
  - QR code (only for top-level containers, hidden for sub-containers)
  - Images grid (tap for full-size view)
  - **Sub-containers list** (only for top-level, below images) - text-only list with icons, names, QR codes
  - **"Add Sub-Container" button** (only for top-level containers, below sub-containers list)
- Pull-to-refresh to sync with server
- Edit button navigates to edit screen
- Delete button with confirmation dialog

#### Kontainer Detail Screen (Create/Edit)
- Form for creating new kontainers, sub-containers, or editing existing ones
- **Parent breadcrumb** when creating sub-container (shows parent name/QR)
- **Title changes**: "New Kontainer" / "New Sub-Container" / "Edit Kontainer"
- **"Add Sub-Container" button** when editing a top-level container (depth=0)
- Fields:
  - Kontainer Name text field (required)
  - Location text field (optional) with location icon
  - Items text area (multiline)
- Image management:
  - Grid view of all kontainer images
  - Add images from camera or gallery
  - Delete images (tap X button)
  - View full-size images on tap
- Save/Update button with loading state
- Validation before submission
- Returns to previous screen on success

#### Add Kontainer Screen (Deprecated)
- Legacy screen, functionality moved to Kontainer Detail Screen
- May be removed in future version

#### Search Screen
- Search kontainers by name or items
- **Searches ALL containers** including sub-containers (uses /api/totes/all)
- Real-time search input with clear button
- Search button and Enter key to search
- Results displayed in card list format with:
  - **Orange "📦 Sub" badge** for sub-containers (depth=1)
  - Kontainer name and preview items
- Shows count of matching kontainers
- Tap result to view kontainer details
- Empty state when no matches found
- Pre-search state with helpful message

#### Settings Screen
- Server URL configuration
- Save button with confirmation
- (Future: theme toggle, other preferences)

#### Scan Screen
- Full QR code scanner using mobile_scanner
- Real-time camera view with overlay
- Visual scanning frame with corner indicators
- Automatic kontainer lookup by QR code
- Navigation to kontainer detail on successful scan
- Error dialog for kontainers not found
- Flashlight toggle button
- Camera switch button (front/back)
- Works with printed QR codes (not reliable with screens)

## Current Implementation Status

### ✅ Completed
- Project scaffolding
- Theme system matching Kontainer web
- Data models with hierarchical support (parent_id, depth, children)
- API service with full CRUD operations including image management
- getTotesAll() endpoint for searching all containers
- QR code lookup API endpoint (`getToteByQRCode`)
- Home screen with top-level kontainer list and sub-container badges
- **Refresh button on home screen** - Manual sync with backend
- **Search functionality** - Search across ALL containers (parent + sub)
- Add kontainer screen with form validation
- Kontainer detail/edit screen with:
  - Name and items editing
  - Image gallery with add/delete
  - Camera and gallery integration
  - Full-size image viewer
  - Auto-refresh on load
  - Delete kontainer functionality
- **Hierarchical sub-containers support**:
  - Parent breadcrumb navigation for sub-containers
  - Sub-container indicator badges
  - Sub-containers grid display on parent view
  - "Add Sub-Container" button (top-level only)
  - QR codes hidden for sub-containers
  - Create sub-containers with parent_id parameter
- Settings screen (basic server URL)
- **QR code scanner (fully functional)**:
  - Real-time camera scanning
  - Visual overlay with scanning frame
  - Automatic kontainer lookup and navigation
  - Error handling for missing kontainers
  - Flashlight and camera switch controls
  - Works with printed QR codes
- Camera permissions (Android + iOS)
- Pull-to-refresh
- Error handling and loading states
- **Null/empty list handling** - No error on empty database
- Navigation between screens
- Responsive Material Design UI
- Image picker integration (camera + gallery)
- Base64 image encoding/decoding
- Code analysis passing with minimal warnings

### 🚧 Planned/Future
- ~~Fix image upload (critical - images not saving to backend)~~ ✅ FIXED v0.4.0
- ~~Fix delete kontainer error~~ ✅ FIXED v0.4.0
- ~~Search and filter functionality~~ ✅ ADDED v0.6.0
- Server connectivity testing
- Shared preferences for settings persistence
- Offline support with local caching
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
- **Auto-refresh**: Kontainer details reload from server on screen navigation to sync changes

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
- Manual refresh button to sync changes from other apps
- Pull-to-refresh gesture for quick updates
- Changes made via web UI are reflected immediately when details screen is opened
- No local caching to avoid stale data issues
- All kontainer updates are synchronized in real-time

## Version History

- **v0.8.0** (Feb 2026) - Hierarchical Sub-Containers Support
  - **NEW: 2-level hierarchical container support**
    - Added parent_id, depth, and children fields to Tote model
    - Home screen now shows only top-level containers (depth=0)
    - Green badge shows sub-container count on parent cards
    - Search functionality searches ALL containers (parents + subs)
    - Orange "📦 Sub" badge on sub-containers in search results
  - **View Screen enhancements**:
    - Parent breadcrumb for sub-containers always navigates to parent (works from any entry point)
    - Sub-container indicator badge (orange) for depth=1
    - Sub-containers displayed as text-only list below parent images
    - "Add Sub-Container" button below sub-containers list
    - QR code hidden for sub-containers (depth=1)
  - **Create/Edit Screen enhancements**:
    - Support for parent_id parameter to create sub-containers
    - Parent breadcrumb when creating sub-container
    - Dynamic title: "New Sub-Container" vs "New Kontainer"
    - "Add Sub-Container" button when editing a top-level container
  - **API updates**:
    - New getTotesAll() method for searching all containers
    - Modified getTotes() returns only top-level (depth=0)
    - createTote() accepts optional parentId parameter
  - **Backend compatibility**: Requires Kontainer backend v1.8.0+
  - **Color scheme**: Matches web UI design
    - Green (#4CAF50) for sub-container count badges
    - Orange (#FF9800) for sub-container indicators
    - Blue (#2196F3) for breadcrumb links

- **v0.7.0** (Feb 2026) - Location Field Support
  - **NEW: Location field for kontainers**
    - Added optional location field to Tote model
    - Location input on create/edit screen with icon
    - Location display on view screen (when set)
    - Placeholder text with example locations
    - Fully integrated with backend API v1.7.0+
  - Backend compatibility:
    - Sends location in create and update requests
    - Receives location in all API responses
    - Handles null/empty locations gracefully

- **v0.6.0** (Feb 2026) - Kontainer Rebrand & Search
  - **Rebranded from ToteTrax to Kontainer**
    - All user-facing text updated to "Kontainer"
    - Package name: kontainer_companion
    - Updated Android and iOS app labels
    - Documentation fully updated
  - **NEW: Search functionality**
    - Search screen with name/items filtering
    - Real-time search results
    - Result count display
    - Clear button and empty states
  - **NEW: Refresh button on home screen**
    - Manual sync button in AppBar
    - Disabled while loading
    - Works alongside pull-to-refresh
  - **FIXED: Empty database error**
    - No longer shows type error when no kontainers exist
    - Gracefully handles null/empty API responses
    - Shows friendly empty state message

- **v0.5.0** (Feb 2026) - View/Edit Screen Separation
  - **NEW: Separate view and edit screens**
    - Created ToteViewScreen for read-only viewing
    - ToteDetailScreen now dedicated to editing (create/update)
    - Improved UX by preventing accidental edits
    - Edit button on view screen navigates to edit mode
    - Delete button remains accessible on view screen
  - Navigation updates:
    - Home screen taps now go to view screen
    - QR scanner navigates to view screen
    - Pull-to-refresh on view screen
  - Better separation of concerns

- **v0.4.1** (Feb 2026) - Gallery Image Update Fix
  - **FIXED: Gallery image update bug** - RangeError when adding gallery images to existing kontainers
    - MIME types list only tracks new images, not existing ones from database
    - Fixed sublist calculation in tote_detail_screen.dart (line 244)
    - Gallery and camera images now work correctly for both create and update operations

- **v0.4.0** (Feb 2026) - Critical Bug Fixes
  - **FIXED: Image upload bug** - Images now save correctly to database
    - Track MIME types from XFile when picking images
    - Send images in data URI format: `data:image/jpeg;base64,{data}`
    - Send image_paths and image_types arrays to backend
    - Works for both create and add-image operations
  - **FIXED: Delete kontainer bug** - Accept 204 No Content status code
  - **FIXED: Create endpoint** - Changed from /api/totes to /api/tote
  - All CRUD operations now working correctly
  - Images persist in database and display in web UI

- **v0.3.0** (Feb 2026) - QR Scanner Implementation
  - Full QR code scanner using mobile_scanner package
  - Real-time barcode detection with visual overlay
  - Automatic kontainer lookup by QR code (GET /api/tote/qr/{code})
  - Camera permissions configured (Android + iOS)
  - Flashlight and camera switching
  - Error handling for kontainers not found
  - Works reliably with printed QR codes

- **v0.2.0** (Feb 2026) - Image Management Update
  - Added full image CRUD operations
  - Camera and gallery integration
  - Base64 image storage matching backend
  - Auto-refresh on detail screen load
  - Image deletion with visual feedback
  
- **v0.1.0** (Feb 2026) - Initial implementation
  - Flutter project created
  - Theme matching Kontainer web
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
  - `NSCameraUsageDescription`: "Kontainer needs camera access to scan QR codes on storage containers"
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

This project uses the same technology stack and architecture as FilaTrax Mobile, adapted for storage container management instead of filament spools. Key differences:

- **Data Model**: Kontainers instead of Spools
- **QR Codes**: Generated for storage containers instead of filament
- **Items List**: Text-based item inventory instead of filament properties
- **Images**: Multiple images per kontainer showing contents

## Future Enhancements

- NFC support for kontainer tagging
- Barcode scanning for items
- Export/import functionality
- Multi-user support
- Location tracking for kontainers
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

- See Kontainer backend: `D:\projects\kontainer\TECHNICAL-DOCS.md`
- See FilaTrax Mobile: `D:\projects\filatrax_mobile\filatrax-mobile-info.md`
