# Resume Builder AI - Backend Server

This is a Dart-based backend server for the Resume Builder AI application.

## Setup

### 1. Install Dependencies

```bash
flutter pub get
```

### 2. Run the Server

**Option 1: Using Dart directly**
```bash
dart run server.dart
```

**Option 2: Using the batch file (Windows)**
```bash
start_server.bat
```

**Option 3: Using Dart with bin wrapper**
```bash
dart run bin/server.dart
```

The server will start on `http://localhost:8080`

## API Endpoints

### Resumes (No authentication required)
- `GET /api/resumes` - Get all resumes
- `POST /api/resumes` - Create new resume
- `POST /api/resumes/update` - Update resume (pass 'id' in request body)
- `POST /api/resumes/delete` - Delete resume (pass 'id' in request body)

### AI Services
- `POST /api/ai/generate-summary` - Generate professional summary
- `POST /api/ai/enhance-bullet` - Enhance bullet point
- `POST /api/ai/suggest-skills` - Suggest skills for job title
- `POST /api/ai/analyze-resume` - Analyze resume

## Development

### Project Structure

```
.
├── server.dart              # Main server file
├── bin/
│   └── server.dart         # Server wrapper
├── lib/
│   ├── models/             # Data models
│   ├── services/
│   │   ├── server/         # Backend services
│   │   │   ├── resume_service.dart
│   │   │   ├── ai_service.dart
│   │   │   └── database_service.dart
│   ├── middleware/         # Server middleware
│   └── utils/              # Utilities
│       └── logger.dart
└── pubspec.yaml            # Dependencies
```

### Adding New Endpoints

1. Add route handler in `server.dart`
2. Implement service logic in `lib/services/server/`
3. Add authentication if needed using middleware

### Testing

The API can be tested using:
- Postman
- curl
- Flutter app

## Notes

- Currently uses in-memory storage (data is lost on restart)
- CORS is enabled for all origins
- Server uses Shelf framework for HTTP handling

