# ToteTrax Mobile - Current Session Progress & Known Issues

**Last Updated**: 2026-02-17  
**Session Context**: Development of ToteTrax Mobile companion app

## Project Overview

ToteTrax Mobile is a Flutter-based mobile companion app for the ToteTrax storage container inventory management system. It connects to the ToteTrax Go backend server to provide mobile access to tote inventory.

**Related Projects:**
- Backend: `D:\projects\totetrax` (Go + SQLite server)
- Mobile: `D:\projects\totetrax_mobile` (Flutter app - this project)

## Current Development Status

### ✅ Completed Features

1. **Project Setup**
   - Flutter project scaffolded based on FilaTrax Mobile
   - Dependencies configured (http, mobile_scanner, shared_preferences, provider, image_picker)
   - Git repository initialized
   - Code analysis passing with minimal warnings

2. **Theme & UI**
   - Custom theme matching ToteTrax web app colors
   - Light mode colors implemented
   - Dark mode colors defined (toggle not yet in UI)
   - Material Design components
   - Responsive layout

3. **Screens Implemented**
   - Home screen with tote list
   - Add tote screen with form
   - Tote detail/edit screen with camera/image picker
   - Settings screen (placeholder)
   - **QR code scanner (fully functional)**

4. **API Integration**
   - `ApiService` class with full CRUD operations
   - GET /api/totes (list all)
   - GET /api/tote/:id (get single)
   - **GET /api/tote/qr/:qrCode (lookup by QR code)** ✅ NEW
   - POST /api/tote (create new)
   - PUT /api/tote/:id (update)
   - POST /api/tote/:id/add-image (add images)
   - DELETE /api/tote/:id (delete)

5. **Navigation**
   - MaterialApp with routes
   - Navigation between screens
   - Back button handling

6. **QR Code Scanner** ✅ NEWLY COMPLETED (v0.3.0)
   - Full mobile_scanner integration
   - Real-time camera view with overlay
   - Visual scanning frame with corner indicators
   - Automatic QR code detection
   - Automatic tote lookup by QR code
   - Navigation to tote detail on success
   - Error handling for missing totes
   - Flashlight toggle button
   - Camera switch button (front/back)
   - Camera permissions configured (Android + iOS)
   - Works reliably with printed QR codes
   - Known limitation: May not scan from computer screens (normal behavior)

## 🚨 CRITICAL ISSUES - NEEDS FIXING

### Issue #1: Images Not Being Added to Totes

**Status**: ❌ BROKEN  
**Priority**: HIGH  
**Affects**: Mobile app → Backend image upload

**Symptoms:**
- User can select images from gallery or camera
- Images appear to upload (no error shown)
- But images are NOT saved to the tote in the database
- Web UI shows the tote but with no images

**Investigation Needed:**
1. Check if mobile app is sending correct API request format
2. Verify backend endpoint `/api/tote/:id/add-image` is receiving data
3. Compare mobile app request to working web UI request
4. Check if base64 encoding is correct
5. Verify MIME type is being sent correctly

**Current Mobile Code:**
```dart
// In api_service.dart
Future<void> addImagesToTote(int toteId, List<Uint8List> images) async {
  for (final imageData in images) {
    final response = await http.post(
      Uri.parse('$baseUrl/api/tote/$toteId/add-image'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'image_data': base64Encode(imageData),
      }),
    );
  }
}
```

**Backend Endpoint Expected Format:**
- Check `D:\projects\totetrax\internal\api\handlers.go`
- Look at `AddImageToToteHandler` function
- Compare with web UI's `form.js` implementation

**Next Steps:**
1. Check backend server logs when mobile app submits image
2. Add debug logging to see exact JSON payload being sent
3. Test backend endpoint with curl/Postman to verify it works
4. Compare working web UI request vs mobile app request
5. Fix mobile app to match expected format

### Issue #2: API Endpoint Mismatch (404 Errors)

**Status**: ❌ PARTIALLY FIXED  
**Priority**: HIGH  
**Affects**: Create and update operations

**Background:**
- Mobile app was getting 404 errors when updating totes
- Issue: Mobile app calling different endpoints than web UI

**Resolution:**
- Updated mobile `ApiService` to match web UI endpoints:
  - Changed `POST /api/totes` to `POST /api/tote` (singular)
  - Changed `PUT /api/totes/:id` to `PUT /api/tote/:id` (singular)
  - These now match the web UI and backend

**Verification:**
- ✅ List totes works
- ✅ Create tote works (without images)
- ✅ Update tote text works
- ❌ Add images still broken (Issue #1)

### Issue #3: App Crashes/Instability

**Status**: ⚠️ MONITORING  
**Priority**: MEDIUM  
**Affects**: General stability

**Reported Issues:**
- App crashes after running for a while
- App crashes when updating tote with images
- Socket errors when submitting large images

**Potential Causes:**
1. Memory leaks from large image data
2. Timeout issues with slow network
3. Unhandled exceptions in async code
4. State management issues

**Current Mitigations:**
- Added 30-second timeout to API requests
- Added try-catch blocks with error messages
- Separated image upload from tote update

**Still Needed:**
- Implement image compression before upload
- Add better error handling and user feedback
- Add loading indicators during image uploads
- Implement retry logic for failed uploads

## Backend Connection

### Server Information
- **Default URL**: `http://localhost:3818`
- **Configurable**: Yes, via Settings screen
- **Protocol**: HTTP REST API
- **Authentication**: None (local network use)

### API Endpoints Used

| Method | Endpoint | Purpose | Status |
|--------|----------|---------|--------|
| GET | `/api/totes` | List all totes | ✅ Working |
| GET | `/api/tote/:id` | Get tote details | ✅ Working |
| POST | `/api/tote` | Create new tote | ✅ Working |
| PUT | `/api/tote/:id` | Update tote | ✅ Working |
| POST | `/api/tote/:id/add-image` | Add image | ❌ Not working |
| DELETE | `/api/tote/:id` | Delete tote | ⚠️ Not tested |

### Expected Data Format

**Tote Object (JSON):**
```json
{
  "id": 1,
  "name": "Kitchen Supplies",
  "description": "Extra kitchen items",
  "items": "4x Dish towels\n2x Pot holders\n1x Apron",
  "images": [
    {
      "id": 1,
      "tote_id": 1,
      "image_data": "data:image/jpeg;base64,/9j/4AAQ...",
      "image_type": "image/jpeg",
      "display_order": 0
    }
  ],
  "qr_code": "TOTE-00001",
  "created_at": "2026-02-14T05:00:00Z",
  "updated_at": "2026-02-14T05:01:00Z"
}
```

**Note**: Backend stores images as BLOBs in database, returns as base64 data URIs

## Data Model Differences

### Backend (Go):
```go
type Tote struct {
    ID          int         `json:"id"`
    Name        string      `json:"name"`
    Description string      `json:"description"`
    Items       string      `json:"items"`
    Images      []ToteImage `json:"images"`
    QRCode      string      `json:"qr_code"`
    CreatedAt   time.Time   `json:"created_at"`
    UpdatedAt   time.Time   `json:"updated_at"`
}

type ToteImage struct {
    ID           int    `json:"id"`
    ToteID       int    `json:"tote_id"`
    ImageData    string `json:"image_data"`    // Base64 data URI
    ImageType    string `json:"image_type"`    // MIME type
    DisplayOrder int    `json:"display_order"`
    CreatedAt    time.Time `json:"created_at"`
}
```

### Mobile (Dart):
```dart
class Tote {
  final int id;
  final String name;
  final String description;
  final String items;
  final List<Uint8List> images;  // Raw binary data
  final String? qrCode;
  
  // Note: Missing ToteImage model, using raw bytes
}
```

**Issue**: Mobile app doesn't have `ToteImage` model yet. Currently storing images as raw bytes, but should probably match backend structure.

## Testing Checklist

### Manual Testing Required

- [ ] **Create Tote (No Images)**
  - Open mobile app
  - Click "Add New" button
  - Enter name and items
  - Click Save
  - Verify tote appears in list
  - Verify in web UI

- [ ] **Create Tote (With Images)**
  - Open mobile app
  - Click "Add New" button
  - Enter name and items
  - Select images from gallery
  - Click Save
  - ❌ **CURRENTLY BROKEN** - images not saved

- [ ] **Update Tote (Text Only)**
  - Click existing tote
  - Edit name or items
  - Click Update
  - ✅ **WORKING**

- [ ] **Update Tote (Add Images)**
  - Click existing tote
  - Select new images
  - Click Update
  - ❌ **CURRENTLY BROKEN** - images not added

- [ ] **View Tote Images**
  - Click tote with images (created from web UI)
  - ⚠️ **NOT TESTED** - need to implement image display

- [ ] **Delete Tote**
  - Click tote
  - Click delete button
  - Confirm
  - ⚠️ **NOT TESTED**

### Backend Integration Testing

```bash
# Test backend is running
curl http://localhost:3818/api/totes

# Test create tote (should work)
curl -X POST http://localhost:3818/api/tote \
  -H "Content-Type: application/json" \
  -d '{"name":"Test","items":"Item 1\nItem 2"}'

# Test add image (expected format from web UI)
curl -X POST http://localhost:3818/api/tote/1/add-image \
  -H "Content-Type: application/json" \
  -d '{"image_data":"data:image/jpeg;base64,...","image_type":"image/jpeg"}'
```

## Development Commands

```bash
# Navigate to project
cd D:\projects\totetrax_mobile

# Get dependencies
flutter pub get

# Run code analysis (should pass)
flutter analyze

# Run on Windows (for testing)
flutter run -d windows

# Run on Android device/emulator
flutter run

# Hot reload during development
# Press 'r' in terminal while app is running

# Build for release
flutter build windows --release
flutter build apk --release
```

## Running the App

### Prerequisites
1. ToteTrax backend must be running:
   ```bash
   cd D:\projects\totetrax
   .\totetrax.exe
   ```
   Server should start on `http://localhost:3818`

2. Flutter environment set up
3. Connected device or emulator (or run on Windows)

### Start Mobile App
```bash
cd D:\projects\totetrax_mobile
flutter run -d windows  # For Windows testing
# OR
flutter run             # For connected Android/iOS device
```

### Configure Server URL
1. Open app
2. Click Settings icon (top right)
3. Enter server URL (default: `http://localhost:3818`)
4. Click Save
5. Go back to home screen

**Note**: For Android emulator, use `http://10.0.2.2:3818` instead of `localhost`

## File Locations

### Mobile App Code
- **Main Entry**: `D:\projects\totetrax_mobile\lib\main.dart`
- **API Service**: `D:\projects\totetrax_mobile\lib\services\api_service.dart`
- **Models**: `D:\projects\totetrax_mobile\lib\models\tote.dart`
- **Screens**: `D:\projects\totetrax_mobile\lib\screens\*.dart`
- **Theme**: `D:\projects\totetrax_mobile\lib\utils\theme.dart`

### Backend Code (for reference)
- **Main**: `D:\projects\totetrax\cmd\totetrax\main.go`
- **Handlers**: `D:\projects\totetrax\internal\api\handlers.go`
- **Service**: `D:\projects\totetrax\internal\service\tote_service.go`
- **Models**: `D:\projects\totetrax\internal\models\tote.go`

### Documentation
- **Mobile Docs**: `D:\projects\totetrax_mobile\TECHNICAL-DOCS.md`
- **Backend Docs**: `D:\projects\totetrax\TECHNICAL-DOCS.md`
- **This File**: `D:\projects\totetrax_mobile\SESSION-PROGRESS.md`

## Next Session TODO

### Immediate Priorities (Fix Broken Features)

1. **🔥 FIX IMAGE UPLOAD** (Critical)
   - [ ] Debug mobile app image upload request format
   - [ ] Compare to working web UI implementation
   - [ ] Check backend logs for request details
   - [ ] Test with curl/Postman to isolate issue
   - [ ] Fix mobile app to send correct format
   - [ ] Test create tote with images
   - [ ] Test add images to existing tote

2. **Test Coverage**
   - [ ] Test delete tote functionality
   - [ ] Test viewing images in tote detail
   - [ ] Test with real Android device
   - [ ] Test with large images (compression needed?)

3. **Image Display**
   - [ ] Implement image display in tote detail screen
   - [ ] Show thumbnail in tote list card (optional)
   - [ ] Handle base64 data URI from backend
   - [ ] Add loading states for images

### Future Enhancements

4. **Camera Integration**
   - [ ] Add image_picker dependency
   - [ ] Implement camera capture
   - [ ] Implement gallery selection
   - [ ] Add image compression before upload

5. **QR Scanner**
   - [ ] Implement mobile_scanner on scan screen
   - [ ] Request camera permissions
   - [ ] Parse scanned QR codes
   - [ ] Navigate to tote details

6. **Offline Support**
   - [ ] Implement local caching with sqflite
   - [ ] Sync when online
   - [ ] Handle conflicts

7. **Settings Persistence**
   - [ ] Save server URL to shared_preferences
   - [ ] Add dark mode toggle
   - [ ] Save theme preference

8. **Polish**
   - [ ] Add pull-to-refresh on home screen
   - [ ] Add search/filter
   - [ ] Better error messages
   - [ ] Loading indicators
   - [ ] Success/failure snackbars

## Known Web UI Features (for reference)

The web UI has these features working correctly:
- ✅ Create tote with multiple images
- ✅ Add images to existing tote (additive)
- ✅ Delete individual images
- ✅ View all images in gallery
- ✅ Hover to preview all images
- ✅ Click image for full-size view
- ✅ QR code generation and printing
- ✅ QR code scanning (camera, upload, manual)
- ✅ Export/import with images
- ✅ Settings page (port, DB path, theme)
- ✅ Dark mode toggle

Mobile app should eventually match these features.

## Debug Tips

### Common Issues

**"Failed to load totes"**
- Backend not running
- Wrong server URL in settings
- Network connectivity issue

**"Failed to create tote"**
- Check backend logs
- Verify JSON format
- Check for required fields

**App crashes when adding images**
- Images too large (add compression)
- Memory issues (use image_picker with quality setting)
- Network timeout (already added 30s timeout)

### Debugging Steps

1. **Check backend is running**:
   ```bash
   curl http://localhost:3818/api/totes
   ```

2. **Check mobile app console logs**:
   - Run with `flutter run -v` for verbose output
   - Look for API request/response details

3. **Check backend logs**:
   - Backend prints requests to console
   - Look for 404s, 500s, or error messages

4. **Test API directly**:
   ```bash
   # Get all totes
   curl http://localhost:3818/api/totes
   
   # Create tote
   curl -X POST http://localhost:3818/api/tote \
     -H "Content-Type: application/json" \
     -d '{"name":"Test","items":"Item 1"}'
   ```

## Important Notes for Next Session

1. **Image Upload is BROKEN** - This is the #1 priority to fix
   - Mobile app sends base64 encoded image
   - Backend expects it but doesn't save it
   - Need to debug the exact request format

2. **API endpoints now match** - Fixed 404 errors by using singular `/api/tote` instead of `/api/totes`

3. **Web UI is fully working** - Use it as reference for correct behavior

4. **Backend stores images in database** - As BLOBs, not files. Returns as base64 data URIs.

5. **No image compression yet** - Large images might cause memory/network issues

6. **Test on Windows first** - Easier to debug than Android emulator

7. **Compare with FilaTrax Mobile** - Similar architecture, might have helpful examples

## Session End Checklist

Before ending session, verify:
- [ ] Code is committed to git
- [ ] Documentation updated (TECHNICAL-DOCS.md, SESSION-PROGRESS.md)
- [ ] Known issues documented
- [ ] Next steps clearly listed
- [ ] Any breaking changes noted

---

**End of Session Progress Document**

*Last Updated: 2026-02-16*  
*Next Session: Focus on fixing image upload functionality*
