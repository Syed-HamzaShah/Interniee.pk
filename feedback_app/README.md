# Feedback & Review App

A Flutter-based mobile application for collecting, managing, and analyzing feedback from interns and users. The app provides a comprehensive platform for feedback submission, review, and analytics.

## Features

### For Interns/Users
- **Feedback Submission**: Submit feedback across multiple categories (Course, Internship, Company, Experience)
- **Rating System**: Rate experiences with a 1-5 star system
- **Feedback History**: View all submitted feedback with status tracking
- **Real-time Updates**: Live synchronization of feedback status
- **Analytics Dashboard**: View personal feedback analytics and trends

### For Admins
- **Feedback Management**: Review, approve, or reject submitted feedback
- **Analytics & Reports**: Comprehensive analytics with charts and statistics
- **User Management**: View and manage all registered users
- **Firebase Data Management**: Direct access to Firebase data with export capabilities
- **Real-time Monitoring**: Monitor feedback submissions in real-time
- **Category Analysis**: Track feedback distribution across different categories

### General Features
- **Dark Theme**: Modern dark UI with green accents and smooth animations
- **Role-based Authentication**: Secure login system for users and admins
- **Firebase Integration**: Real-time database, authentication, and analytics
- **Cross-platform**: Works on both Android and iOS
- **Responsive Design**: Optimized for different screen sizes

## Tech Stack

- **Frontend**: Flutter (Dart)
- **Backend**: Firebase
  - Firestore (Real-time Database)
  - Firebase Authentication
  - Firebase Analytics
  - Firebase Cloud Messaging (Push Notifications)
- **State Management**: Provider
- **Charts & Analytics**: fl_chart
- **UI Components**: Material Design with custom theming
- **Architecture**: MVVM with Provider pattern

## Prerequisites

Before running this application, make sure you have:

1. **Flutter SDK** (3.0.0 or higher)
2. **Dart SDK** (included with Flutter)
3. **Android Studio** or **VS Code** with Flutter extensions
4. **Firebase Project** set up with the following services:
   - Authentication (Email/Password)
   - Firestore Database
   - Analytics
   - Cloud Messaging (optional)

## Setup Instructions

### 1. Clone the Repository

```bash
git clone <repository-url>
cd feedback_app
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
   - Analytics
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
    
    // Feedbacks collection
    match /feedbacks/{feedbackId} {
      allow read, write: if request.auth != null && 
        (resource.data.userId == request.auth.uid || 
         get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin');
      allow create: if request.auth != null;
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

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── firebase_options.dart     # Firebase configuration
├── models/                   # Data models
│   ├── user_model.dart       # User data model
│   └── feedback_model.dart   # Feedback data model
├── services/                 # Firebase services
│   ├── auth_service.dart     # Authentication service
│   └── feedback_service.dart # Feedback service
├── providers/                # State management
│   ├── auth_provider.dart    # Authentication state
│   └── feedback_provider.dart # Feedback state
├── screens/                  # UI screens
│   ├── auth/
│   │   ├── login_screen.dart
│   │   └── register_screen.dart
│   ├── admin/
│   │   ├── admin_home_screen.dart
│   │   ├── admin_feedback_screen.dart
│   │   └── firebase_data_screen.dart
│   ├── feedback/
│   │   ├── feedback_home_screen.dart
│   │   ├── submit_feedback_screen.dart
│   │   └── my_feedback_screen.dart
│   ├── analytics/
│   │   └── analytics_screen.dart
│   ├── dashboard/
│   │   └── dashboard_screen.dart
│   ├── profile_screen.dart
│   └── splash_screen.dart
├── widgets/                  # Reusable widgets
│   ├── custom_button.dart
│   ├── feedback_card.dart
│   ├── feedback_overview_card.dart
│   ├── shimmer_widget.dart
│   └── app_bar.dart
└── utils/
    ├── app_theme.dart        # App theming
    └── responsive_helper.dart # Responsive utilities
```

## Usage

### First Time Setup
1. Launch the app
2. Create an admin account by registering with "Admin" role
3. Create user accounts by registering with "Intern" role
4. Users can now submit feedback and admins can manage it

### For Admins
1. Login with admin credentials
2. Use the admin dashboard to:
   - Review and manage all submitted feedback
   - Approve or reject feedback submissions
   - View comprehensive analytics and reports
   - Monitor real-time feedback submissions
   - Access Firebase data management tools
   - Export feedback data

### For Users/Interns
1. Login with user credentials
2. Submit feedback across different categories:
   - Course feedback
   - Internship experience
   - Company feedback
   - General experience
3. Rate experiences with 1-5 star system
4. View personal feedback history and analytics
5. Track feedback status (pending, approved, rejected)

## Feedback Categories

The app supports four main feedback categories:

- **Course**: Feedback about educational courses, training programs, or learning experiences
- **Internship**: Feedback about internship programs, work experience, or professional development
- **Company**: Feedback about company culture, work environment, or organizational aspects
- **Experience**: General feedback about overall experiences, services, or interactions

## Rating System

- **1 Star**: Poor experience
- **2 Stars**: Below average experience
- **3 Stars**: Average experience
- **4 Stars**: Good experience
- **5 Stars**: Excellent experience

## Features in Development

- [ ] Push notifications for feedback status updates
- [ ] File attachments for feedback submissions
- [ ] Advanced filtering and search capabilities
- [ ] Feedback templates for common scenarios
- [ ] Email notifications for admins
- [ ] Advanced data visualization and reporting
- [ ] Feedback sentiment analysis
- [ ] Bulk feedback management tools

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
   - Verify feedback collection permissions

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