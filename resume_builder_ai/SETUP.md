# Setup Guide for Resume Builder AI

## Quick Start

### 1. Install Dependencies

```bash
flutter pub get
```

### 2. Start the Backend Server

Open a terminal and run:

```bash
dart run server.dart
```

Or on Windows:
```bash
start_server.bat
```

The server will start on `http://localhost:8080`

### 3. Run the Flutter App

In another terminal, run:

```bash
flutter run
```

### 4. Test the Connection

The app will automatically connect to the local server. If the server is not running, it will fall back to the external AI service.

## Project Structure

### Main Files

- `server.dart` - Main backend server
- `lib/services/ai_service.dart` - AI service with local/external fallback
- `lib/services/server/` - Backend service implementations

### Backend Services

- `lib/services/server/resume_service.dart` - Resume management
- `lib/services/server/ai_service.dart` - AI processing
- `lib/services/server/database_service.dart` - Database layer

### Configuration

The app uses in-memory storage by default. For production, you can:

1. Replace the in-memory database with SQLite
2. Add SQL Server support
3. Implement Firebase integration

## API Usage Examples

### AI Services

**Generate Summary:**
```bash
curl -X POST http://localhost:8080/api/ai/generate-summary \
  -H "Content-Type: application/json" \
  -d '{"role":"Software Engineer","experienceLevel":"Senior","skills":["Flutter","Dart","REST APIs"]}'
```

**Enhance Bullet Point:**
```bash
curl -X POST http://localhost:8080/api/ai/enhance-bullet \
  -H "Content-Type: application/json" \
  -d '{"bulletPoint":"Developed features for mobile app"}'
```

**Suggest Skills:**
```bash
curl -X POST http://localhost:8080/api/ai/suggest-skills \
  -H "Content-Type: application/json" \
  -d '{"jobTitle":"Flutter Developer"}'
```

## Troubleshooting

### Server Not Starting

1. Check if port 8080 is available
2. Run `dart run --debug server.dart` for detailed errors
3. Check if all dependencies are installed

### App Not Connecting

1. Verify server is running on `http://localhost:8080`
2. Check network permissions in the Flutter app
3. For Android emulator, use `10.0.2.2` instead of `localhost`

### AI Services Not Working

The app automatically falls back to external AI service if local server is unavailable. To disable local server:

Edit `lib/services/ai_service.dart`:
```dart
static bool _useLocalServer = false;
```

## Next Steps

1. **Add Database**: Implement SQLite for persistent storage
2. **Add PDF Generation**: Implement PDF export on server
3. **Add Template System**: Create multiple resume templates
4. **Add Cloud Sync**: Implement cloud backup and sync

## Resources

- [Shelf Documentation](https://pub.dev/packages/shelf)
- [Flutter Documentation](https://flutter.dev/docs)
- [Dart Server Development](https://dart.dev/server)

