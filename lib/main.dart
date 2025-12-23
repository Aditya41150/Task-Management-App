import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:task_management/features/auth/tasks/data/domain/presentation/pages/task_list_page.dart';
import 'package:task_management/features/auth/tasks/data/domain/presentation/pages/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await dotenv.load(fileName: ".env"); // Load the .env file

  // Initialize Firebase with your provided web options
  await Firebase.initializeApp(
    options: FirebaseOptions(
      // Remove const to fix invalid constant value
      apiKey: dotenv.env['FIREBASE_API_KEY'] ?? '',
      authDomain: dotenv.get('FIREBASE_AUTH_DOMAIN') ?? '',
      projectId: dotenv.get('FIREBASE_PROJECT_ID') ?? '',
      storageBucket: dotenv.get('FIREBASE_STORAGE_BUCKET') ?? '',
      messagingSenderId: dotenv.get('FIREBASE_MESSAGING_SENDER_ID') ?? '',
      appId: dotenv.get('FIREBASE_APP_ID') ?? '',
      measurementId: dotenv.get('FIREBASE_MEASUREMENT_ID') ?? '',
    ),
  );

  runApp(
    DevicePreview(
      enabled: !kReleaseMode,
      builder: (context) => const ProviderScope(
        child: MyApp(),
      ),
    ),
  );
}

// --- PROVIDERS ---

// Controls the manual theme toggle (Light vs Dark)
final themeNotifierProvider =
    StateProvider<ThemeMode>((ref) => ThemeMode.system);

// Watches the Firebase Auth State
final authStateProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

// --- MAIN APP WIDGET ---

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Listen to the manual theme toggle provider
    final themeMode = ref.watch(themeNotifierProvider);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      locale: DevicePreview.locale(context),
      builder: DevicePreview.appBuilder,

      // Theme Mode Logic
      themeMode: themeMode,

      // Light Theme Definition
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: const Color(0xFF7E72F2),
        scaffoldBackgroundColor: const Color(0xFFF6F6F9),
        cardColor: Colors.white,
        useMaterial3: true,
        fontFamily: 'Poppins', // If you have Poppins fonts added
      ),

      // Dark Theme Definition
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color(0xFF7E72F2),
        scaffoldBackgroundColor:
            const Color(0xFF0F0F12), // Premium dark background
        cardColor: const Color(0xFF1C1C1E), // Slightly lighter surface color
        useMaterial3: true,
        fontFamily: 'Poppins',
      ),

      home: const AuthWrapper(),
    );
  }
}

// --- AUTH WRAPPER ---

class AuthWrapper extends ConsumerWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return authState.when(
      data: (user) {
        if (user != null) return const TaskListPage();
        return const LoginScreen();
      },
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, stack) => Scaffold(
        body: Center(child: Text("Connection Error: $e")),
      ),
    );
  }
}
