# Resume Builder AI

An AI-powered resume builder application built with Flutter that helps users create professional resumes with intelligent suggestions and AI-assisted writing.

## Features

- 🎨 Multiple resume templates
- 🤖 AI-powered content suggestions
- ✏️ Real-time editing and preview
- 📄 PDF export
- 📱 Responsive design for mobile, tablet, and desktop
- 🚀 Local backend server for AI processing

## Tech Stack

- **Frontend**: Flutter
- **Backend**: Dart with Shelf framework
- **State Management**: Provider
- **Local Storage**: Hive
- **PDF Generation**: pdf package

## Setup

### Prerequisites

- Flutter SDK (latest stable version)
- Dart SDK
- Git

### Installation

1. Clone the repository:
```bash
git clone <repository-url>
cd resume_builder_ai
```

2. Install dependencies:
```bash
flutter pub get
```

3. Run the app:
```bash
flutter run
```

## Backend Server

The project includes a Dart-based backend server for handling API requests.

### Starting the Server

**Option 1: Direct Dart command**
```bash
dart run server.dart
```

**Option 2: Using the wrapper**
```bash
dart run bin/server.dart
```

**Option 3: Using batch file (Windows)**
```bash
start_server.bat
```

The server will start on `http://localhost:8080`

### API Endpoints

#### Resumes
- `GET /api/resumes` - Get all resumes
- `POST /api/resumes` - Create resume
- `POST /api/resumes/update` - Update resume
- `POST /api/resumes/delete` - Delete resume

#### AI Services
- `POST /api/ai/generate-summary` - Generate professional summary
- `POST /api/ai/enhance-bullet` - Enhance bullet points
- `POST /api/ai/suggest-skills` - Suggest skills for job title
- `POST /api/ai/analyze-resume` - Analyze resume quality

## Project Structure

```
resume_builder_ai/
├── lib/
│   ├── main.dart
│   ├── models/
│   │   └── resume_model.dart
│   ├── providers/
│   │   └── resume_provider.dart
│   ├── screens/
│   │   ├── builder/
│   │   ├── home/
│   │   ├── preview/
│   │   └── templates/
│   ├── services/
│   │   ├── ai_service.dart
│   │   ├── pdf_service.dart
│   │   ├── storage_service.dart
│   │   └── server/          # Backend services
│   │       ├── resume_service.dart
│   │       ├── ai_service.dart
│   │       └── database_service.dart
│   ├── widgets/
│   ├── theme/
│   └── utils/
├── server.dart              # Main server entry point
├── bin/
│   └── server.dart         # Server wrapper
├── android/
├── ios/
├── web/
└── pubspec.yaml
```

## Development

### Running Tests

```bash
flutter test
```

### Building for Production

**Android:**
```bash
flutter build apk --release
```

**iOS:**
```bash
flutter build ios --release
```

**Web:**
```bash
flutter build web
```

**Windows:**
```bash
flutter build windows
```

## Features in Detail

### AI-Powered Features

- **Smart Summary Generation**: Automatically generates professional summaries based on user profile
- **Bullet Point Enhancement**: Suggests improvements to make accomplishments more impactful
- **Skills Suggestion**: Recommends relevant skills based on job title
- **Resume Analysis**: Provides feedback on resume quality and ATS compatibility

### Resume Building

- **Multiple Templates**: Choose from various professionally designed templates
- **Drag-and-Drop Sections**: Easy section management
- **Real-Time Preview**: See changes instantly
- **Export Options**: Export as PDF or share digitally

### User Management

- **Local Storage**: Resumes stored locally using Hive
- **Profile Management**: Save and manage multiple resumes
- **Instant Access**: No account required - start building immediately

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- Flutter team for the amazing framework
- All open-source contributors
