import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'firebase_options.dart';
import 'models/user_model.dart';
import 'utils/app_theme.dart';
import 'providers/auth_provider.dart';
import 'providers/task_provider.dart';
import 'providers/admin_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/intern/intern_home_screen.dart';
import 'screens/admin/admin_home_screen.dart';
import 'screens/splash_screen.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('Handling a background message: ${message.messageId}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  runApp(const FeedbackReviewApp());
}

class FeedbackReviewApp extends StatelessWidget {
  const FeedbackReviewApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => TaskProvider()),
        ChangeNotifierProvider(create: (_) => AdminProvider()),
      ],
      child: MaterialApp(
        title: 'Feedback & Review App',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        home: const AppRouter(),
        routes: {
          '/login': (context) => const LoginScreen(),
          '/register': (context) => const RegisterScreen(),
        },
      ),
    );
  }
}

class AppRouter extends StatelessWidget {
  const AppRouter({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        if (authProvider.isLoading) {
          return const SplashScreen();
        }

        if (!authProvider.isAuthenticated) {
          return const LoginScreen();
        }

        if (authProvider.userModel != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            final taskProvider = Provider.of<TaskProvider>(
              context,
              listen: false,
            );
            taskProvider.setUserId(authProvider.userModel!.id);
          });

          switch (authProvider.userModel!.role) {
            case UserRole.admin:
              return const AdminHomeScreen();
            case UserRole.intern:
              return const InternHomeScreen();
          }
        }

        return const LoginScreen();
      },
    );
  }
}
