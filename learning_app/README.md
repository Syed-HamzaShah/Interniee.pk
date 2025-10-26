# Intern Management System - Learning Management System (LMS)

A comprehensive Flutter-based Learning Management System with Firebase backend integration. This application provides course management, interactive lessons, quizzes, progress tracking, and real-time synchronization for managing intern training and development.

## 🚀 Features

- **Course Management**: Browse and enroll in courses with detailed information
- **Interactive Lessons**: Video and text-based lessons with progress tracking
- **Quizzes & Assessments**: Multiple choice quizzes with score tracking
- **Progress Tracking**: Monitor learning progress and completion rates
- **User Authentication**: Secure email/password authentication via Firebase
- **Real-time Sync**: Automatic data synchronization with Firebase
- **Push Notifications**: Firebase Cloud Messaging for updates
- **Analytics**: Track user engagement and learning patterns
- **Cross-platform**: Supports Android, iOS, Web, Windows, macOS, and Linux

## 📋 Prerequisites

Before you begin, ensure you have:

- **Flutter SDK** (3.9.2 or higher) - [Install Guide](https://docs.flutter.dev/get-started/install)
- **Dart SDK** (included with Flutter)
- **Firebase Account** - [Create one here](https://console.firebase.google.com/)
- **IDE**: VS Code or Android Studio with Flutter plugins
- **Git** for version control

## 🏗️ Project Structure

```
task_tracker_app/
├── lib/
│   ├── main.dart                      # App entry point
│   ├── firebase_options.dart          # Firebase configuration
│   ├── models/                        # Data models
│   │   ├── course_model.dart
│   │   ├── lesson_model.dart
│   │   ├── quiz_model.dart
│   │   ├── user_model.dart
│   │   └── learning_progress_model.dart
│   ├── providers/                     # State management (Provider)
│   │   ├── auth_provider.dart
│   │   └── learning_provider.dart
│   ├── screens/                       # UI screens
│   │   ├── auth/
│   │   │   ├── login_screen.dart
│   │   │   └── register_screen.dart
│   │   ├── learning/
│   │   │   ├── course_listing_screen.dart
│   │   │   ├── course_detail_screen.dart
│   │   │   ├── video_player_screen.dart
│   │   │   ├── quiz_screen.dart
│   │   │   └── quiz_listing_screen.dart
│   │   ├── splash_screen.dart
│   │   └── profile_screen.dart
│   ├── services/                      # Business logic & API calls
│   │   ├── auth_service.dart
│   │   ├── learning_service.dart
│   │   ├── lms_api_service.dart
│   │   └── data_seed_service.dart
│   ├── widgets/                       # Reusable UI components
│   │   ├── app_bar.dart
│   │   ├── custom_button.dart
│   │   └── shimmer_widget.dart
│   └── utils/                         # Helper utilities
│       ├── app_theme.dart
│       └── responsive_helper.dart
├── scripts/                           # Data seeding and deployment
│   ├── add_data_rest.py
│   ├── run_seed.bat
│   ├── run_seed.sh
│   ├── deploy_firestore_rules.bat
│   ├── deploy_firestore_rules.sh
│   └── requirements.txt
├── quizzes.json                       # Sample quiz data
├── firestore.rules                    # Firestore security rules
├── firestore.indexes.json             # Firestore indexes
├── firebase.json                      # Firebase configuration
└── pubspec.yaml                       # Flutter dependencies
```

## 🔥 Firebase Setup

### Step 1: Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click **"Add project"** or **"Create a project"**
3. Enter your project name
4. Enable Google Analytics (optional)
5. Click **"Create project"**

### Step 2: Enable Firebase Services

#### Authentication Setup
1. Navigate to **Authentication** → **Get started**
2. Go to **Sign-in method** tab
3. Enable **Email/Password** provider
4. Click **Save**

#### Firestore Database Setup
1. Navigate to **Firestore Database** → **Create database**
2. Select **Start in test mode** (for development)
3. Choose your preferred database location
4. Click **Enable**

#### Firebase Cloud Messaging (Optional)
1. Navigate to **Cloud Messaging**
2. Configure as needed for push notifications

### Step 3: Configure Firebase for Your Platforms

#### For Android
1. In Firebase Console, click **Add app** → Select **Android**
2. Package name: `com.example.taskTrackerApp` (or your package name)
3. Download `google-services.json`
4. Place it in `android/app/` directory

#### For iOS
1. Click **Add app** → Select **iOS**
2. Bundle ID: `com.example.taskTrackerApp` (or your bundle ID)
3. Download `GoogleService-Info.plist`
4. Add to `ios/Runner/` via Xcode

#### For Web
1. Click **Add app** → Select **Web**
2. App nickname: `intern-management-web`
3. Configuration is automatically handled in `lib/firebase_options.dart`

### Step 4: Install FlutterFire CLI

```bash
# Install the CLI
dart pub global activate flutterfire_cli

# Login to Firebase
flutterfire login

# Configure your Flutter app
flutterfire configure
```

Select your Firebase project and platforms (Android, iOS, Web) when prompted. This will generate `lib/firebase_options.dart` automatically.

## 📦 Installation

### 1. Clone the Repository

```bash
git clone <your-repository-url>
cd task_tracker_app
```

### 2. Install Flutter Dependencies

```bash
flutter pub get
```

### 3. Seed Sample Data (Optional but Recommended)

Populate your Firebase database with sample courses, lessons, and quizzes:

**On Windows:**
```bash
scripts\run_seed.bat
```

**On Linux/Mac:**
```bash
chmod +x scripts/run_seed.sh
./scripts/run_seed.sh
```

**Or manually:**
```bash
cd scripts
pip install -r requirements.txt
python add_data_rest.py
```

This will add:
- **10 Courses** (Flutter, React, Python ML, AWS, UI/UX, Node.js, DevOps, Blockchain, Angular, Data Analytics)
- **12 Lessons** across different courses
- **4 Sample Quizzes** (Flutter, React, UI/UX, C++) with questions and answers

**Note:** Before running the seed script, ensure your Firestore security rules allow write access for testing.

### 4. Deploy Firestore Security Rules

After seeding data, deploy proper security rules:

```bash
firebase deploy --only firestore:rules
```

Or use the provided scripts:
- **Windows**: `scripts\deploy_firestore_rules.bat`
- **Linux/Mac**: `./scripts/deploy_firestore_rules.sh`

## 🚀 Running the App

### Development Mode

```bash
# List available devices
flutter devices

# Run on default device
flutter run

# Run on specific device
flutter run -d <device-id>

# Run with hot reload enabled (default)
flutter run --debug
```

### Build for Production

```bash
# Android APK
flutter build apk --release

# Android App Bundle (for Play Store)
flutter build appbundle --release

# iOS (macOS only)
flutter build ios --release

# Web
flutter build web --release

# Windows
flutter build windows --release
```

## 🗄️ Database Schema

### Firestore Collections

#### `users` - User Information
```json
{
  "uid": "user123",
  "email": "user@example.com",
  "name": "John Doe",
  "role": "intern",
  "createdAt": "2024-01-01T00:00:00Z"
}
```

#### `courses` - Course Information
```json
{
  "id": "flutter_basics",
  "title": "Flutter Development Fundamentals",
  "description": "Learn Flutter from scratch...",
  "instructor": "Dr. Sarah Ahmed",
  "thumbnailUrl": "https://...",
  "category": "Mobile Development",
  "duration": 480,
  "totalLessons": 12,
  "rating": 4.8,
  "enrolledCount": 1250,
  "difficulty": "beginner",
  "tags": ["Flutter", "Dart", "Mobile"],
  "createdAt": "2024-01-01T00:00:00Z",
  "updatedAt": "2024-01-15T00:00:00Z",
  "isPublished": true
}
```

#### `lessons` - Lesson Content
```json
{
  "id": "flutter_intro",
  "courseId": "flutter_basics",
  "title": "Introduction to Flutter",
  "description": "Get started with Flutter...",
  "type": "video",
  "order": 1,
  "duration": 30,
  "videoUrl": "https://www.youtube.com/watch?v=...",
  "isPublished": true,
  "isFree": true,
  "createdAt": "2024-01-01T00:00:00Z",
  "updatedAt": "2024-01-01T00:00:00Z"
}
```

#### `quizzes` - Quiz Questions
```json
{
  "id": "flutter_basics_quiz",
  "courseId": "flutter_basics",
  "lessonId": "flutter_intro",
  "title": "Flutter Basics Quiz",
  "questions": [
    {
      "id": "q1",
      "question": "What is Flutter?",
      "type": "multipleChoice",
      "options": ["A web framework", "A mobile SDK", "A database", "A language"],
      "correctAnswer": 1,
      "points": 10
    }
  ],
  "timeLimit": 15,
  "passingScore": 70,
  "isPublished": true
}
```

#### `learning_progress` - User Progress Tracking
```json
{
  "userId": "user123",
  "courseId": "flutter_basics",
  "lessonId": "flutter_intro",
  "isCompleted": true,
  "progress": 100,
  "quizScore": 85,
  "lastAccessedAt": "2024-01-15T10:30:00Z"
}
```

## 🔐 Security Rules

The app uses comprehensive Firestore security rules. Key rules:

- **Authentication required** for all operations
- **Users can only read published courses/lessons**
- **Users can only update their own progress**
- **Admin-only permissions** for creating/updating courses

View full rules in `firestore.rules`.

## 📱 Key Features Documentation

### Course Enrollment
- Browse available courses by category
- Filter by difficulty level or instructor
- View course details, syllabus, and reviews
- Enroll in courses with one tap

### Lesson Progress
- Track completion of individual lessons
- Watch video lessons with YouTube integration
- Mark lessons as complete/incomplete
- Resume from last watched position

### Quiz System
- Multiple choice questions
- Real-time scoring and feedback
- Time limits and passing score requirements
- Track quiz attempts and best scores

### Progress Tracking
- Overall course completion percentage
- Time spent learning
- Quiz scores and performance analytics
- Certificates upon course completion

## 🛠️ Development

### Running Tests

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage

# View coverage report
genhtml coverage/lcov.info -o coverage/html
```

### Code Formatting

```bash
# Format code
dart format lib/

# Analyze code
flutter analyze

# Check for outdated dependencies
flutter pub outdated
```

### Key Dependencies

- `firebase_core` (^3.6.0) - Firebase SDK
- `firebase_auth` (^5.3.1) - Authentication
- `cloud_firestore` (^5.4.4) - Database
- `firebase_messaging` (^15.1.3) - Push notifications
- `firebase_analytics` (^11.3.3) - Analytics
- `provider` (^6.1.2) - State management
- `fl_chart` (^0.69.0) - Charts and graphs
- `video_player` (^2.8.2) - Video playback
- `youtube_player_flutter` (^9.0.3) - YouTube integration
- `google_fonts` (^6.2.1) - Typography

See `pubspec.yaml` for complete list.

## 🔧 Troubleshooting

### Firebase Connection Issues

```bash
# Verify Firebase configuration
flutterfire configure

# Check if google-services.json exists
ls android/app/google-services.json

# Check if GoogleService-Info.plist exists (iOS)
ls ios/Runner/GoogleService-Info.plist
```

### Build Errors

```bash
# Clean build cache
flutter clean

# Get dependencies
flutter pub get

# Rebuild
flutter run
```

### Quiz "No Questions" Error

If you see "Quiz has no questions" error:

1. **Verify data is seeded**: Run `scripts/run_seed.bat` or `scripts/run_seed.sh`
2. **Check Firebase Console**:
   - Go to Firestore Database
   - Verify `quizzes` collection exists
   - Check that quiz documents have a `questions` array
3. **Check lesson configuration**: Ensure lessons have a `quizId` field matching an existing quiz
4. **View debug logs**: Check Flutter console for detailed error messages

### YouTube Video Not Playing

If YouTube videos show "Open in Browser" instead of playing in-app:

1. **Check WebView configuration**: Ensure `webview_flutter` is installed
2. **Verify video URL format**: Use `https://www.youtube.com/watch?v=VIDEO_ID` or `https://youtu.be/VIDEO_ID`
3. **Network connectivity**: Ensure device has internet access
4. **Check console logs** for WebView initialization errors
5. **Platform-specific**:
   - Android: Internet permission is required (already configured)
   - iOS: May require additional Info.plist permissions

### Firestore Permission Errors

- Ensure security rules are deployed: `firebase deploy --only firestore:rules`
- Check user authentication status
- Verify rules in Firebase Console → Firestore Database → Rules
- For testing, you can temporarily use test mode rules (not recommended for production)

### Common Flutter Issues

```bash
# If you encounter "Waiting for another flutter command to release the startup lock"
rm -rf ~/.flutter/flutter.lock

# If gradle sync fails on Android
cd android && ./gradlew clean

# If pod install fails on iOS
cd ios && pod deintegrate && pod install
```

## 📚 Additional Resources

- [Flutter Documentation](https://docs.flutter.dev/)
- [Firebase Documentation](https://firebase.google.com/docs)
- [FlutterFire Plugin](https://firebase.flutter.dev/)
- [Firestore Security Rules](https://firebase.google.com/docs/firestore/security/get-started)
- [Provider State Management](https://pub.dev/packages/provider)
- [Material Design Guidelines](https://material.io/design)

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

### Code Style Guidelines

- Follow [Effective Dart](https://dart.dev/guides/language/effective-dart) guidelines
- Use meaningful variable and function names
- Add comments for complex logic
- Write unit tests for new features

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 📞 Support

For issues and questions:
- Open an issue on GitHub
- Check existing documentation
- Review Firebase Console logs
- Check Flutter logs: `flutter logs`

## 👥 Authors

Developed for Internee.pk intern management and training.

---

**Built with ❤️ using Flutter and Firebase**
