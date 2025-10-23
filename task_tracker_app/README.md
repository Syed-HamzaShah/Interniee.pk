# Task Tracker Mobile App

A Flutter-based mobile application for managing tasks and monitoring progress, designed specifically for interns and administrators.

## Features

### For Interns

- **Task Management**: View, update, and complete assigned tasks
- **Real-time Updates**: Live synchronization of task status across devices
- **Progress Tracking**: Monitor personal task completion rates
- **Task Categories**: Organize tasks by status (pending, in progress, completed)
- **Priority Management**: Handle tasks with different priority levels

### For Admins

- **Task Assignment**: Create and assign tasks to specific interns
- **Progress Monitoring**: Track overall team performance and individual progress
- **User Management**: View and manage all registered users
- **Reports & Analytics**: Generate performance reports and leaderboards
- **Real-time Dashboard**: Monitor team activity in real-time

### General Features

- **Dark Theme**: Modern dark UI with green accents
- **Role-based Authentication**: Secure login system for interns and admins
- **Firebase Integration**: Real-time database and authentication
- **Cross-platform**: Works on both Android and iOS

## Tech Stack

- **Frontend**: Flutter (Dart)
- **Backend**: Firebase
  - Firestore (Real-time Database)
  - Firebase Authentication
  - Firebase Cloud Messaging (Push Notifications)
- **State Management**: Provider
- **Architecture**: MVVM with Provider pattern

## Prerequisites

Before running this application, make sure you have:

1. **Flutter SDK** (3.0.0 or higher)
2. **Dart SDK** (included with Flutter)
3. **Android Studio** or **VS Code** with Flutter extensions
4. **Firebase Project** set up with the following services:
   - Authentication
   - Firestore Database
   - Cloud Messaging (optional)

## Setup Instructions

### 1. Clone the Repository

```bash
git clone <repository-url>
cd task_tracker_app
```

### 2. Install Dependencies

```bash
flutter pub get
```

### 3. Firebase Configuration

#### Create a Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Create a new project
3. Enable the following services:
   - Authentication (Email/Password)
   - Firestore Database
   - Cloud Messaging (optional)

#### Configure Firebase for Android

1. Add an Android app to your Firebase project
2. Download `google-services.json` from Firebase Console
3. Place the file in `android/app/` directory

#### Configure Firebase for iOS

1. Add an iOS app to your Firebase project
2. Download `GoogleService-Info.plist` from Firebase Console
3. Place the file in `ios/Runner/` directory

#### Update Firebase Options

1. Install FlutterFire CLI:

   ```bash
   dart pub global activate flutterfire_cli
   ```

2. Configure Firebase:

   ```bash
   flutterfire configure
   ```

3. This will update `lib/firebase_options.dart` with your project configuration.

### 4. Firestore Security Rules

Set up the following Firestore security rules:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users collection
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
      allow read: if request.auth != null &&
        get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }

    // Tasks collection
    match /tasks/{taskId} {
      allow read, write: if request.auth != null &&
        (resource.data.assignedToId == request.auth.uid ||
         get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin');
      allow create: if request.auth != null &&
        get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }

    // Progress collection
    match /progress/{progressId} {
      allow read: if request.auth != null &&
        (resource.data.userId == request.auth.uid ||
         get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin');
      allow write: if request.auth != null;
    }
  }
}
```

### 5. Run the Application

#### For Android

```bash
flutter run
```

#### For iOS

```bash
flutter run -d ios
```

## Usage

### First Time Setup

1. Launch the app
2. Create an admin account by registering with "Admin" role
3. Create intern accounts by registering with "Intern" role
4. Admins can now assign tasks to interns

### For Admins

1. Login with admin credentials
2. Use the dashboard to:
   - Create new tasks
   - Assign tasks to interns
   - Monitor progress
   - View reports
   - Manage users

### For Interns

1. Login with intern credentials
2. View assigned tasks organized by status
3. Update task status (pending → in progress → completed)
4. Track personal progress and completion rates

## Features in Development

- [ ] Push notifications for task assignments
- [ ] File attachments for tasks
- [ ] Advanced reporting and analytics
- [ ] Task templates
- [ ] Team collaboration features
- [ ] Export functionality for reports

## Troubleshooting

### Common Issues

1. **Firebase not initialized**

   - Ensure `google-services.json` (Android) or `GoogleService-Info.plist` (iOS) is properly placed
   - Check that `firebase_options.dart` is correctly configured

2. **Authentication errors**

   - Verify Firebase Authentication is enabled in Firebase Console
   - Check that Email/Password authentication method is enabled

3. **Firestore permission errors**

   - Ensure security rules are properly configured
   - Check that user roles are correctly set in the database

4. **Build errors**
   - Run `flutter clean` and `flutter pub get`
   - Ensure all dependencies are properly installed

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

For support and questions, please create an issue in the repository or contact the development team.
