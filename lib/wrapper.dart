import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:work/screens/Registration/LoginScreen.dart';
import 'package:work/screens/Registration/SignupScreen.dart';
import 'package:work/screens/Registration/UserTypeScreen.dart';
import 'package:work/screens/Home/NavBar/main_screen.dart';

/// A wrapper widget that handles authentication state and navigation
///
/// This widget listens to Firebase Auth state changes and routes the user
/// to the appropriate screen based on their authentication status:
/// - If authenticated: Shows the main application screen
/// - If not authenticated: Shows the login screen
/// - If loading: Shows a loading indicator
class Wrapper extends StatelessWidget {
  const Wrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData) {
          return const LoginScreen();
        }

        return FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance
              .collection('users')
              .doc(snapshot.data!.uid)
              .get(),
          builder: (context, userSnapshot) {
            if (userSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
              return const SignUpScreen();
            }

            final userData = userSnapshot.data!.data() as Map<String, dynamic>?;

            // Check if user type is not set
            if (userData == null || !userData.containsKey('userType')) {
              return const UserTypeScreen();
            }

            return const MainPage();
          },
        );
      },
    );
  }
}
