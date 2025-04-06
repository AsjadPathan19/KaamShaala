import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:work/services/user_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:work/models/user.dart';
import 'package:work/services/notification_service.dart';

/// A service class that handles all authentication-related operations
/// including user sign-up, sign-in, sign-out, and password reset.
class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  // Firebase Auth instance
  final auth.FirebaseAuth _auth = auth.FirebaseAuth.instance;
  final UserService _userService = UserService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );
  final NotificationService _notificationService = NotificationService();

  /// Returns the current user if logged in, null otherwise
  auth.User? get currentUser => _auth.currentUser;

  /// Returns a stream of authentication state changes
  Stream<auth.User?> get authStateChanges => _auth.authStateChanges();

  /// Signs in a user with email and password
  ///
  /// [email] - The user's email address
  /// [password] - The user's password
  ///
  /// Returns a [UserCredential] if successful
  /// Throws [FirebaseAuthException] if authentication fails
  Future<auth.UserCredential> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      print('AuthService: Attempting to sign in user: $email');
      auth.UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      await _updateFCMToken(result.user!.uid);
      print('AuthService: Sign in successful for user: ${result.user?.email}');
      return result;
    } catch (e) {
      print('AuthService: Error during sign in: $e');
      throw _handleAuthException(e);
    }
  }

  /// Creates a new user account with email and password
  ///
  /// [email] - The user's email address
  /// [password] - The user's password
  /// [name] - The user's full name
  /// [role] - The user's role (e.g., 'worker' or 'client')
  ///
  /// Returns a [UserCredential] if successful
  /// Throws [FirebaseAuthException] if account creation fails
  Future<auth.UserCredential> registerWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
    required String role,
  }) async {
    try {
      final batch = _firestore.batch();

      // Create the user account
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update display name
      await userCredential.user?.updateDisplayName(name);

      // Create user document in Firestore
      final userDoc =
          _firestore.collection('users').doc(userCredential.user?.uid);
      batch.set(userDoc, {
        'id': userCredential.user?.uid,
        'name': name,
        'email': email,
        'role': role,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Execute batch write
      await batch.commit();

      await _updateFCMToken(userCredential.user!.uid);
      return userCredential;
    } catch (e) {
      print('AuthService: Error during registration: $e');
      throw _handleAuthException(e);
    }
  }

  /// Signs in a user with Google
  ///
  /// Returns a [UserCredential] if successful
  /// Throws [FirebaseAuthException] if authentication fails
  Future<auth.UserCredential> signInWithGoogle() async {
    try {
      print('AuthService: Starting Google sign in flow');

      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        throw auth.FirebaseAuthException(
          code: 'ERROR_ABORTED_BY_USER',
          message: 'Sign in aborted by user',
        );
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create a new credential
      final credential = auth.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      final userCredential = await _auth.signInWithCredential(credential);

      // Check if this is a new user
      if (userCredential.additionalUserInfo?.isNewUser ?? false) {
        // Create user document in Firestore with required fields
        await _firestore.collection('users').doc(userCredential.user?.uid).set({
          'name': userCredential.user?.displayName ?? '',
          'email': userCredential.user?.email ?? '',
          'contact': '', // Add empty contact field
          'createdAt': FieldValue.serverTimestamp(),
          'jobsPosted': 0,
          'jobsCompleted': 0,
        });
      } else {
        // For existing users, ensure they have all required fields
        final userDoc = await _firestore
            .collection('users')
            .doc(userCredential.user?.uid)
            .get();
        if (!userDoc.exists) {
          // If document doesn't exist, create it
          await _firestore
              .collection('users')
              .doc(userCredential.user?.uid)
              .set({
            'name': userCredential.user?.displayName ?? '',
            'email': userCredential.user?.email ?? '',
            'contact': '', // Add empty contact field
            'createdAt': FieldValue.serverTimestamp(),
            'jobsPosted': 0,
            'jobsCompleted': 0,
          });
        } else {
          // Update existing document to ensure all fields exist
          final data = userDoc.data() ?? {};
          if (!data.containsKey('contact')) {
            await _firestore
                .collection('users')
                .doc(userCredential.user?.uid)
                .update({
              'contact': '',
            });
          }
        }
      }

      await _updateFCMToken(userCredential.user!.uid);
      print(
          'AuthService: Google sign in successful for user: ${userCredential.user?.email}');
      return userCredential;
    } catch (e) {
      print('AuthService: Error during Google sign in: $e');
      throw _handleAuthException(e);
    }
  }

  /// Signs out the current user
  Future<void> signOut() async {
    try {
      print('AuthService: Signing out user');
      await Future.wait([
        _auth.signOut(),
        _googleSignIn.signOut(),
      ]);
      print('AuthService: User signed out successfully');
    } catch (e) {
      print('AuthService: Error during sign out: $e');
      throw _handleAuthException(e);
    }
  }

  /// Sends a password reset email to the specified email address
  ///
  /// [email] - The email address to send the reset link to
  Future<void> resetPassword(String email) async {
    try {
      print('AuthService: Sending password reset email to: $email');
      await _auth.sendPasswordResetEmail(email: email.trim());
      print('AuthService: Password reset email sent successfully');
    } catch (e) {
      print('AuthService: Error sending password reset email: $e');
      rethrow;
    }
  }

  /// Updates the user type in Firestore
  /// [userType] can be either 'worker' or 'client'
  Future<void> updateUserType(String userType) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw auth.FirebaseAuthException(
          code: 'ERROR_USER_NOT_FOUND',
          message: 'No user found',
        );
      }

      await _firestore.collection('users').doc(user.uid).update({
        'userType': userType,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      print('AuthService: Updated user type to $userType for user ${user.uid}');
    } catch (e) {
      print('AuthService: Error updating user type: $e');
      throw _handleAuthException(e);
    }
  }

  /// Updates the FCM token for a user
  Future<void> _updateFCMToken(String userId) async {
    try {
      final token = await _notificationService.getFCMToken();
      if (token != null) {
        await _firestore.collection('users').doc(userId).update({
          'fcmToken': token,
        });
      }
    } catch (e) {
      print('AuthService: Error updating FCM token: $e');
    }
  }

  /// Gets user data from Firestore
  Future<User?> getUserData(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        return User.fromMap(doc.data()!);
      }
      return null;
    } catch (e) {
      print('AuthService: Error getting user data: $e');
      rethrow;
    }
  }

  String _handleAuthException(dynamic e) {
    if (e is auth.FirebaseAuthException) {
      switch (e.code) {
        case 'weak-password':
          return 'The password provided is too weak.';
        case 'email-already-in-use':
          return 'An account already exists for that email.';
        case 'invalid-email':
          return 'The email address is not valid.';
        case 'operation-not-allowed':
          return 'Email & Password accounts are not enabled.';
        case 'user-disabled':
          return 'This user has been disabled.';
        case 'user-not-found':
          return 'No user found for that email.';
        case 'wrong-password':
          return 'Wrong password provided.';
        case 'ERROR_ABORTED_BY_USER':
          return 'Sign in was aborted by the user.';
        case 'ERROR_USER_NOT_FOUND':
          return 'No user found';
        default:
          return 'Authentication error: ${e.message}';
      }
    }
    return 'An error occurred: $e';
  }
}
