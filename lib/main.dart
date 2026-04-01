// lib/main.dart

import 'package:animal_detection/provider/civilian_proivder.dart';
import 'package:animal_detection/provider/office_provider.dart';
import 'package:animal_detection/screens/roles_selection_screen.dart';
import 'package:animal_detection/services/fcm_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'firebase_options.dart';
import 'screens/splash_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/alert_screen.dart';
import 'screens/history_screen.dart';
import 'services/notification_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'dart:async';

// ✅ FIX: Background message handler — MUST be top-level function
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  debugPrint('📩 BACKGROUND FCM MESSAGE');
  debugPrint('   Title: ${message.notification?.title}');
  debugPrint('   Body : ${message.notification?.body}');
  debugPrint('   Data : ${message.data}');
  debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  // Android handles background notification display automatically
  // via the `notification` payload from the server.
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ FIX: Firebase MUST be initialized FIRST (before NotificationService)
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // ✅ FIX: Register background handler BEFORE anything else
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Now initialize local notifications (channels, permissions)
  await NotificationService().initialize();

  // ✅ FIX: Setup foreground FCM listener
  _setupForegroundFCMListener();

  // Setup FCM message open handlers
  _setupMessageOpenHandlers();

  final officerProvider = OfficerProvider();
  final civilianProvider = CivilianProvider();
  await officerProvider.loadFromPrefs();
  await civilianProvider.loadFromPrefs();

  // Initialize FCM if user is logged in
  if (officerProvider.isLoggedIn && officerProvider.officer != null) {
    await FCMService().initializeFCM(
      officerProvider.officer!.id,
      'forestOfficer',
    );
  } else if (civilianProvider.isLoggedIn && civilianProvider.civilian != null) {
    await FCMService().initializeFCM(
      civilianProvider.civilian!.id,
      'civilian',
    );
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: officerProvider),
        ChangeNotifierProvider.value(value: civilianProvider),
      ],
      child: const WildAnimalDetectionApp(),
    ),
  );
}

// ✅ FIX: Foreground message listener — WITHOUT THIS, notifications
//         are SILENT when app is open!
void _setupForegroundFCMListener() {
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    debugPrint('📩 FOREGROUND FCM MESSAGE RECEIVED');
    debugPrint('   Title: ${message.notification?.title}');
    debugPrint('   Body : ${message.notification?.body}');
    debugPrint('   Data : ${message.data}');
    debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

    // Show local notification with sound
    NotificationService().showNotification(message);
  });
}

// ✅ Handle notification tap when app is in background/terminated
void _setupMessageOpenHandlers() {
  // When user taps notification and app is in background
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    debugPrint('📲 Notification opened app from background');
    debugPrint('   Data: ${message.data}');
    // TODO: Navigate to detection detail screen
  });

  // When app is opened from terminated state via notification
  FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? message) {
    if (message != null) {
      debugPrint('📲 App opened from terminated state via notification');
      debugPrint('   Data: ${message.data}');
      // TODO: Navigate to detection detail screen
    }
  });
}

class AppTheme {
  static const Color forestGreen = Color(0xFF1B5E20);
  static const Color darkGreen = Color(0xFF0D3B0D);
  static const Color lightGreen = Color(0xFF4CAF50);
  static const Color earthBrown = Color(0xFF5D4037);
  static const Color lightBrown = Color(0xFF8D6E63);
  static const Color alertRed = Color(0xFFD32F2F);
  static const Color warningRed = Color(0xFFB71C1C);
  static const Color white = Colors.white;
  static const Color offWhite = Color(0xFFF5F5F5);
  static const Color darkBackground = Color(0xFF121212);
  static const Color cardBackground = Color(0xFF1E1E1E);
  static const Color surfaceColor = Color(0xFF252525);

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: forestGreen,
      scaffoldBackgroundColor: darkBackground,
      colorScheme: const ColorScheme.dark(
        primary: forestGreen,
        secondary: lightGreen,
        surface: surfaceColor,
        error: alertRed,
        onPrimary: white,
        onSecondary: white,
        onSurface: white,
        onError: white,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: darkBackground,
        elevation: 0,
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        iconTheme: IconThemeData(color: white),
        titleTextStyle: TextStyle(
          color: white,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      cardTheme: CardThemeData(
        color: cardBackground,
        elevation: 8,
        shadowColor: Colors.black.withValues(alpha: 0.3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: forestGreen,
          foregroundColor: white,
          elevation: 4,
          shadowColor: forestGreen.withValues(alpha: 0.4),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: lightGreen,
          side: const BorderSide(color: lightGreen, width: 2),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceColor,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Colors.white.withValues(alpha: 0.1),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: lightGreen, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: alertRed),
        ),
        hintStyle: TextStyle(
          color: Colors.white.withValues(alpha: 0.5),
        ),
        labelStyle: const TextStyle(color: white),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(color: white, fontWeight: FontWeight.bold),
        displayMedium: TextStyle(color: white, fontWeight: FontWeight.bold),
        displaySmall: TextStyle(color: white, fontWeight: FontWeight.bold),
        headlineLarge: TextStyle(color: white, fontWeight: FontWeight.w600),
        headlineMedium: TextStyle(color: white, fontWeight: FontWeight.w600),
        headlineSmall: TextStyle(color: white, fontWeight: FontWeight.w600),
        titleLarge: TextStyle(color: white, fontWeight: FontWeight.w600),
        titleMedium: TextStyle(color: white, fontWeight: FontWeight.w500),
        titleSmall: TextStyle(color: white, fontWeight: FontWeight.w500),
        bodyLarge: TextStyle(color: white),
        bodyMedium: TextStyle(color: white),
        bodySmall: TextStyle(color: Colors.white70),
        labelLarge: TextStyle(color: white, fontWeight: FontWeight.w600),
        labelMedium: TextStyle(color: white),
        labelSmall: TextStyle(color: Colors.white70),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: cardBackground,
        selectedItemColor: lightGreen,
        unselectedItemColor: Colors.white54,
        type: BottomNavigationBarType.fixed,
        elevation: 16,
      ),
    );
  }
}

class WildAnimalDetectionApp extends StatelessWidget {
  const WildAnimalDetectionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wild Animal Detection',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) => const RoleSelectionScreen(),
        '/home': (context) => const DashboardScreen(),
        '/alerts': (context) => const AlertScreen(),
        '/history': (context) => const HistoryScreen(),
      },
    );
  }
}
