import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Creates a new user document in Firestore
  ///
  /// [uid] - The user's unique ID from Firebase Auth
  /// [name] - The user's full name
  /// [email] - The user's email address
  /// [contact] - The user's contact number
  /// [createdAt] - The timestamp when the user was created
  Future<void> createUserDocument({
    required String uid,
    required String name,
    required String email,
    required String contact,
    DateTime? createdAt,
  }) async {
    try {
      print('UserService: Starting user document creation...');
      print('UserService: Checking Firestore instance...');

      if (_firestore == null) {
        throw Exception('Firestore instance is null');
      }

      print('UserService: Creating user data map...');
      final userData = {
        'name': name,
        'email': email,
        'contact': contact,
        'createdAt': FieldValue.serverTimestamp(),
        'lastUpdated': FieldValue.serverTimestamp(),
        'uid': uid, // Adding UID for reference
      };
      print('UserService: User data prepared: $userData');

      print('UserService: Accessing users collection...');
      final userRef = _firestore.collection('users').doc(uid);

      print('UserService: Attempting to write document...');
      await userRef.set(userData);
      print('UserService: Document write completed');

      // Verify the write
      print('UserService: Verifying document write...');
      final docSnapshot = await userRef.get();

      if (docSnapshot.exists) {
        print('UserService: Document verified - Data: ${docSnapshot.data()}');
      } else {
        print('UserService: WARNING - Document not found after writing!');
        throw Exception('Document write verification failed');
      }

      print('UserService: User document created successfully');
    } catch (e, stackTrace) {
      print('UserService: Error creating user document:');
      print('Error: $e');
      print('Stack trace: $stackTrace');
      throw Exception('Failed to create user document: $e');
    }
  }

  /// Updates an existing user document
  ///
  /// [uid] - The user's unique ID
  /// [data] - Map of fields to update
  Future<void> updateUserDocument(String uid, Map<String, dynamic> data) async {
    try {
      print('UserService: Starting document update for UID: $uid');

      if (_firestore == null) {
        throw Exception('Firestore instance is null');
      }

      final userRef = _firestore.collection('users').doc(uid);

      // Check if document exists before updating
      final docSnapshot = await userRef.get();
      if (!docSnapshot.exists) {
        print('UserService: Document does not exist, creating new document');
        await createUserDocument(
          uid: uid,
          name: data['name'] ?? '',
          email: data['email'] ?? '',
          contact: data['contact'] ?? '',
        );
        return;
      }

      data['lastUpdated'] = FieldValue.serverTimestamp();
      await userRef.update(data);
      print('UserService: Document updated successfully');
    } catch (e, stackTrace) {
      print('UserService: Error updating user document:');
      print('Error: $e');
      print('Stack trace: $stackTrace');
      throw Exception('Failed to update user document: $e');
    }
  }

  /// Gets the current user's document from Firestore
  Future<DocumentSnapshot?> getCurrentUserDocument() async {
    try {
      print('UserService: Fetching current user document');

      if (_firestore == null) {
        throw Exception('Firestore instance is null');
      }

      final user = _auth.currentUser;
      if (user == null) {
        print('UserService: No authenticated user found');
        return null;
      }

      print('UserService: Getting document for UID: ${user.uid}');
      final docSnapshot =
          await _firestore.collection('users').doc(user.uid).get();

      if (docSnapshot.exists) {
        print('UserService: Document found - Data: ${docSnapshot.data()}');
      } else {
        print('UserService: No document found for current user');
      }

      return docSnapshot;
    } catch (e, stackTrace) {
      print('UserService: Error getting user document:');
      print('Error: $e');
      print('Stack trace: $stackTrace');
      throw Exception('Failed to get user document: $e');
    }
  }
}
