import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'theme/app_theme.dart';
import 'providers/resume_provider.dart';
import 'services/storage_service.dart';
import 'screens/home/dashboard_screen.dart';
import 'screens/builder/resume_builder_screen.dart';
import 'screens/templates/template_gallery_screen.dart';
import 'screens/preview/resume_preview_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  await StorageService.initialize();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(const ResumeAIApp());
}

class ResumeAIApp extends StatelessWidget {
  const ResumeAIApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => ResumeProvider())],
      child: MaterialApp(
        title: 'Resume AI',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.light,
        home: const DashboardScreen(),
        routes: {
          '/dashboard': (context) => const DashboardScreen(),
          '/builder': (context) => const ResumeBuilderScreen(),
          '/templates': (context) => const TemplateGalleryScreen(),
          '/preview': (context) => const ResumePreviewScreen(),
        },
      ),
    );
  }
}
