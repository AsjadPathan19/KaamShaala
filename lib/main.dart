import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:work/services/auth_service.dart';
import 'package:work/services/firebase_options.dart';
import 'package:work/screens/Registration/LoginScreen.dart';
import 'package:work/screens/Registration/SignupScreen.dart';
import 'package:work/screens/Home/NavBar/Settings/TermsAndConditionsScreen.dart';
import 'package:work/screens/Home/NavBar/Settings/Settings.dart';
import 'package:work/screens/Home/NavBar/main_screen.dart';
import 'package:work/screens/Home/NavBar/post_job_screen.dart';
import 'package:work/screens/Home/NavBar/completed_jobs_screen.dart';
import 'package:work/screens/SplashScreen.dart';

/// The main entry point of the application
/// Initializes Firebase and runs the app
void main() async {
  try {
    // Ensure Flutter bindings are initialized
    WidgetsFlutterBinding.ensureInitialized();
    print('Main: Flutter bindings initialized');

    // Initialize Firebase
    if (Firebase.apps.isEmpty) {
      print('Main: Initializing Firebase...');
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      print('Main: Firebase initialized successfully');

      // Initialize Firestore settings
      print('Main: Configuring Firestore settings...');
      await FirebaseFirestore.instance.settings.persistenceEnabled;
      FirebaseFirestore.instance.settings = const Settings(
        persistenceEnabled: true,
        cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
      );
      print('Main: Firestore settings configured');

      // Test Firestore connection
      try {
        print('Main: Testing Firestore connection...');
        await FirebaseFirestore.instance.collection('test').doc('test').set({
          'timestamp': FieldValue.serverTimestamp(),
        });
        print('Main: Firestore connection test successful');

        // Clean up test document
        await FirebaseFirestore.instance
            .collection('test')
            .doc('test')
            .delete();
      } catch (e) {
        print('Main: Firestore connection test failed: $e');
      }
    }
  } catch (e) {
    print('Main: Error during initialization: $e');
  }

  // Run the app
  runApp(MyApp());
}

/// The root widget of the application
/// Sets up the MaterialApp with routes and theme
class MyApp extends StatelessWidget {
  final AuthService _authService = AuthService();

  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KaamShaala',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const SplashScreen(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignUpScreen(),
        '/terms': (context) => const TermsAndConditionsScreen(),
        '/home': (context) => MainPage(),
        '/settings': (context) => SettingsScreen(),
        '/post-job': (context) => const PostJobScreen(),
        '/completed-jobs': (context) => const CompletedJobsScreen(),
      },
    );
  }
}
