# Intern Management System (IMS)

A comprehensive Flutter application for managing interns, tracking assigned tasks, and monitoring progress with real-time Firebase integration and analytics dashboard.

## 🚀 Features

### Core Functionality
- **Real-time Database**: Cloud Firestore integration with live updates and offline support
- **Authentication**: Firebase Auth with role-based access (Admin/Intern)
- **Task Management**: Create, assign, track, and manage tasks with real-time synchronization
- **Intern Management**: Comprehensive intern profiles with performance tracking
- **Feedback System**: User feedback collection and management with analytics
- **Analytics Dashboard**: Performance metrics, task statistics, and progress tracking
- **Cross-platform**: Android, iOS, Web, Windows, macOS, and Linux support

### Advanced Features
- **Real-time Synchronization**: Live updates across all connected devices
- **Offline Support**: Automatic data caching and sync when connection is restored
- **Role-based Access Control**: Different interfaces for admins and interns
- **Performance Analytics**: Detailed reporting and statistics
- **Search & Filter**: Advanced search and filtering capabilities
- **Batch Operations**: Bulk task updates and management
- **Responsive Design**: Optimized for all screen sizes

## 📱 Screenshots

*Screenshots would be added here showing the admin dashboard, intern interface, task management, and analytics views*

## 🛠️ Tech Stack

- **Frontend**: Flutter 3.9.2+
- **Backend**: Firebase (Firestore, Auth, Analytics)
- **State Management**: Provider
- **Charts & Analytics**: FL Chart, Syncfusion Flutter Charts
- **UI Components**: Material Design with custom theming
- **Real-time Sync**: Cloud Firestore streams
- **Offline Support**: Firestore offline persistence

## 📋 Prerequisites

- Flutter SDK (3.9.2 or higher)
- Firebase CLI
- Google account
- Android Studio or VS Code with Flutter extension
- Git

## 🔧 Installation & Setup

### 1. Clone the Repository
```bash
git clone <repository-url>
cd task_tracker_app
```

### 2. Install Dependencies
```bash
flutter pub get
```

### 3. Firebase Setup

#### Create Firebase Project
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Create a project"
3. Enter project name: `intern-management-system` (or your preferred name)
4. Enable Google Analytics (recommended)
5. Click "Create project"

#### Enable Required Services

**Authentication:**
1. Go to "Authentication" → "Sign-in method"
2. Enable "Email/Password" provider
3. Optionally enable other providers (Google, etc.)

**Firestore Database:**
1. Go to "Firestore Database"
2. Click "Create database"
3. Choose "Start in test mode" (for development)
4. Select a location for your database

#### Configure Firebase for Flutter

**For Android:**
1. In Firebase Console, click "Add app" and select Android
2. Enter package name: `com.example.intern_management_system`
3. Download `google-services.json` file
4. Place the file in `android/app/` directory

**For iOS:**
1. In Firebase Console, click "Add app" and select iOS
2. Enter bundle ID: `com.example.internManagementSystem`
3. Download `GoogleService-Info.plist` file
4. Add the file to `ios/Runner/` directory in Xcode

**For Web:**
1. In Firebase Console, click "Add app" and select Web
2. Register app with nickname: `intern-management-web`
3. Copy the Firebase configuration to `lib/firebase_options.dart`

#### Configure Firebase Options

**Using FlutterFire CLI (Recommended):**
```bash
# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Login to Firebase
flutterfire login

# Configure your Flutter app
flutterfire configure
```

### 4. Set Up Firestore Security Rules

Deploy the security rules from `firestore.rules`:

```bash
# Using Firebase CLI
firebase deploy --only firestore:rules

# Or use the provided scripts
# Windows:
scripts\deploy_firestore_rules.bat

# Unix/Linux/macOS:
scripts/deploy_firestore_rules.sh
```

### 5. Run the Application
```bash
flutter run
```

## 🗄️ Database Schema

### Collections Structure

#### Users Collection (`users`)
```json
{
  "id": "string",
  "email": "string",
  "name": "string",
  "role": "admin|intern",
  "profileImageUrl": "string?",
  "createdAt": "timestamp"
}
```

#### Tasks Collection (`tasks`)
```json
{
  "id": "string",
  "title": "string",
  "description": "string",
  "assignedTo": "string (user ID)",
  "assignedBy": "string (admin ID)",
  "deadline": "timestamp",
  "status": "notStarted|inProgress|completed|overdue",
  "priority": "low|medium|high|urgent",
  "createdAt": "timestamp",
  "completedAt": "timestamp?",
  "notes": "string?",
  "attachments": ["string"]
}
```

#### Feedbacks Collection (`feedbacks`)
```json
{
  "id": "string",
  "userId": "string",
  "userName": "string",
  "userEmail": "string",
  "category": "course|internship|company|experience",
  "rating": "number (1-5)",
  "comments": "string",
  "createdAt": "timestamp",
  "status": "pending|approved|rejected"
}
```

## 🏗️ Project Structure

```
lib/
├── models/
│   ├── task_model.dart              # Task data model with enums
│   ├── user_model.dart              # User data model
│   ├── intern_model.dart            # Intern data model
│   └── feedback_model.dart          # Feedback data model
├── services/
│   ├── database_service.dart        # Centralized database operations
│   ├── realtime_sync_service.dart   # Real-time synchronization
│   ├── auth_service.dart            # Authentication service
│   ├── task_service.dart            # Task management service
│   ├── intern_service.dart          # Intern management service
│   ├── feedback_service.dart        # Feedback service
│   └── database_init_service.dart   # Database initialization
├── providers/
│   ├── auth_provider.dart           # Authentication state management
│   ├── task_provider.dart           # Task state management
│   ├── intern_provider.dart         # Intern state management
│   └── feedback_provider.dart       # Feedback state management
├── screens/
│   ├── admin/                       # Admin-specific screens
│   │   ├── admin_home_screen.dart
│   │   ├── task_management_screen.dart
│   │   ├── intern_management_screen.dart
│   │   └── performance_reports_screen.dart
│   ├── intern/                      # Intern-specific screens
│   │   ├── intern_home_screen.dart
│   │   ├── task_list_screen.dart
│   │   └── feedback_screen.dart
│   ├── auth/                        # Authentication screens
│   │   ├── login_screen.dart
│   │   └── register_screen.dart
│   ├── dashboard/                   # Dashboard screens
│   └── profile_screen.dart
├── widgets/                         # Reusable UI components
│   ├── app_bar.dart
│   ├── custom_button.dart
│   ├── task_card.dart
│   ├── feedback_card.dart
│   └── shimmer_widget.dart
├── utils/                           # Utility functions
│   ├── app_theme.dart
│   └── responsive_helper.dart
└── firebase_options.dart            # Firebase configuration
```

## 🔄 Real-time Synchronization

### How It Works
1. **Stream Listeners**: Each service uses Firestore streams for real-time updates
2. **Provider Integration**: Providers automatically update UI when data changes
3. **Offline Support**: Data is cached locally and synced when connection is restored
4. **Conflict Resolution**: Last-write-wins strategy for data conflicts

### Implementation
```dart
// Listen to tasks stream
Stream<List<TaskModel>> getTasksStream() {
  return _firestore
      .collection('tasks')
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((snapshot) => snapshot.docs
          .map((doc) => TaskModel.fromDocument(doc))
          .toList());
}
```

## 📊 Analytics and Reporting

### Built-in Analytics
- **Task Analytics**: Completion rates, overdue tasks, priority distribution
- **Intern Analytics**: Performance metrics, department statistics
- **Feedback Analytics**: Rating distribution, category statistics
- **Real-time Dashboards**: Live data visualization

### Performance Tracking
- **Task Completion Rates**: Individual and team performance
- **Intern Progress**: Skill development and task completion
- **Feedback Analysis**: User satisfaction and improvement areas
- **Time Tracking**: Task duration and deadline adherence

## 🛡️ Security Features

### Authentication System
- **Firebase Auth**: Email/password authentication
- **Role-based Access**: Admin and Intern user roles
- **User Management**: Profile management and user data synchronization

### Security Best Practices
1. **Firestore Security Rules**: Comprehensive rules to protect data
2. **Authentication Required**: All data access requires authentication
3. **Role-based Permissions**: Different access levels for admins and interns
4. **Data Validation**: Server-side validation for all operations

## 📱 Offline Support

### Automatic Offline Handling
- **Data Caching**: All data is cached locally for offline access
- **Sync on Reconnect**: Automatic synchronization when connection is restored
- **Conflict Resolution**: Handles data conflicts gracefully
- **Offline Indicators**: UI indicators for offline/online status

### Offline Capabilities
- **Read Operations**: All read operations work offline
- **Write Operations**: Write operations are queued and synced when online
- **Real-time Updates**: Updates are applied when connection is restored

## 🚀 Usage Examples

### Creating a Task
```dart
// Using TaskService
final taskService = TaskService();
final task = await taskService.createTask(
  title: 'New Task',
  description: 'Task description',
  assignedTo: 'intern_id',
  assignedBy: 'admin_id',
  deadline: DateTime.now().add(Duration(days: 7)),
  priority: TaskPriority.high,
);
```

### Real-time Task Updates
```dart
// Using RealtimeSyncService
final syncService = RealtimeSyncService();
await syncService.initializeSync();

// Listen to task updates
syncService.getTasksStream().listen((tasks) {
  // Update UI with new tasks
  setState(() {
    this.tasks = tasks;
  });
});
```

### User Authentication
```dart
// Using AuthProvider
final authProvider = Provider.of<AuthProvider>(context);

// Sign in
await authProvider.signInWithEmailAndPassword(
  email: 'user@example.com',
  password: 'password',
);

// Check authentication status
if (authProvider.isAuthenticated) {
  // User is logged in
}
```

## 🐛 Troubleshooting

### Common Issues

1. **"Firebase not initialized" error**
   - Ensure `google-services.json` is in `android/app/`
   - Ensure `GoogleService-Info.plist` is in `ios/Runner/`
   - Check that `firebase_options.dart` has correct configuration

2. **Authentication not working**
   - Verify Email/Password authentication is enabled in Firebase Console
   - Check security rules allow user creation

3. **Firestore permission denied**
   - Verify security rules are properly configured
   - Ensure user is authenticated before accessing Firestore

4. **Build errors**
   - Run `flutter clean` and `flutter pub get`
   - Ensure all Firebase dependencies are properly installed

### Debug Steps
1. Check Flutter logs for Firebase errors
2. Verify Firebase project configuration
3. Test with Firebase Console directly
4. Check network connectivity

## 📈 Performance Optimization

### Best Practices
1. **Efficient Queries**: Use indexes for complex queries
2. **Data Pagination**: Implement pagination for large datasets
3. **Selective Sync**: Only sync necessary data based on user role
4. **Connection Management**: Properly dispose of listeners

### Required Indexes
Create the following indexes in Firebase Console:
```
tasks: assignedTo + createdAt (descending)
tasks: status + createdAt (descending)
tasks: priority + createdAt (descending)
tasks: assignedBy + createdAt (descending)
feedbacks: userId + createdAt (descending)
feedbacks: status + createdAt (descending)
feedbacks: category + createdAt (descending)
users: role + name (ascending)
users: role + isActive + name (ascending)
```

## 🔄 Migration Guide

### From Local Storage to Firebase
1. **Data Migration**: Use `DatabaseInitService` to migrate existing data
2. **User Migration**: Migrate user accounts to Firebase Auth
3. **Settings Migration**: Update app settings for Firebase configuration
4. **Testing**: Thoroughly test all functionality with Firebase backend

## 📚 Dependencies

### Core Dependencies
- `firebase_core: ^3.6.0` - Firebase core functionality
- `firebase_auth: ^5.3.1` - Authentication
- `cloud_firestore: ^5.4.4` - Database
- `firebase_messaging: ^15.1.3` - Push notifications
- `firebase_analytics: ^11.3.3` - Analytics

### UI Dependencies
- `provider: ^6.1.2` - State management
- `fl_chart: ^0.69.0` - Charts and graphs
- `syncfusion_flutter_charts: ^26.2.14` - Advanced charts
- `shimmer: ^3.0.0` - Loading animations
- `google_fonts: ^6.2.1` - Typography

## 📞 Support

For additional help:
- Check the troubleshooting section above
- Review Firebase Console for configuration issues
- Check Flutter logs for detailed error messages
- Refer to the official Firebase and Flutter documentation

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📝 Changelog

### Version 1.0.0
- Initial release
- Firebase integration
- Real-time synchronization
- Role-based access control
- Task management system
- Intern management
- Feedback system
- Analytics dashboard
- Offline support

---

**Note**: This application provides a robust, scalable foundation for managing interns and tasks with real-time synchronization, offline support, and comprehensive security measures.