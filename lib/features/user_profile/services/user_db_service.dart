import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:betwizz_app/features/auth/models/user_model.dart';

abstract class UserDbService {
  Future<void> createUserProfile(UserModel user);
  Future<UserModel?> getUserProfile(String uid);
  // Future<void> updateUserProfile(UserModel user); // Example for future extension
}

class FirestoreUserDbService implements UserDbService {
  final FirebaseFirestore _firestore;
  final String _usersCollectionPath = 'users';

  // Constructor, allowing injection of FirebaseFirestore instance for testability
  FirestoreUserDbService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<void> createUserProfile(UserModel user) async {
    try {
      // Firestore security rules are crucial here:
      // Ensure users can only create their own profile, typically by checking auth.uid == userId in rules.
      // Example rule:
      // match /users/{userId} {
      //   allow create: if request.auth != null && request.auth.uid == userId;
      //   allow read, update: if request.auth != null && request.auth.uid == userId;
      // }
      await _firestore.collection(_usersCollectionPath).doc(user.uid).set({
        'uid': user.uid,
        'email': user.email,
        'displayName': user.displayName, // This might be null initially
        'createdAt': FieldValue.serverTimestamp(), // Good practice to store creation time
        // Add other initial profile fields here if any
      });
    } on FirebaseException catch (e) {
      // It's good to catch FirebaseException specifically for more granular error handling
      throw Exception('Error creating user profile in Firestore: ${e.message} (Code: ${e.code})');
    } catch (e) {
      throw Exception('An unexpected error occurred while creating user profile: ${e.toString()}');
    }
  }

  @override
  Future<UserModel?> getUserProfile(String uid) async {
    try {
      final docSnapshot = await _firestore.collection(_usersCollectionPath).doc(uid).get();
      if (docSnapshot.exists && docSnapshot.data() != null) {
        final data = docSnapshot.data()!;
        return UserModel(
          uid: data['uid'] ?? uid, // uid from doc id as fallback
          email: data['email'],
          displayName: data['displayName'],
          // Map other fields from Firestore document to UserModel if they exist
        );
      }
      return null; // User profile not found
    } on FirebaseException catch (e) {
      throw Exception('Error fetching user profile from Firestore: ${e.message} (Code: ${e.code})');
    } catch (e) {
      throw Exception('An unexpected error occurred while fetching user profile: ${e.toString()}');
    }
  }

  // Example for future extension:
  // @override
  // Future<void> updateUserProfile(UserModel user) async {
  //   try {
  //     await _firestore.collection(_usersCollectionPath).doc(user.uid).update({
  //       'displayName': user.displayName,
  //       // Update other modifiable fields
  //       'updatedAt': FieldValue.serverTimestamp(),
  //     });
  //   } on FirebaseException catch (e) {
  //     throw Exception('Error updating user profile: ${e.message} (Code: ${e.code})');
  //   } catch (e) {
  //     throw Exception('An unexpected error occurred while updating profile: ${e.toString()}');
  //   }
  // }
}

// Riverpod provider for UserDbService
final userDbServiceProvider = Provider<UserDbService>((ref) {
  // If FirebaseFirestore.instance needs specific configuration or
  // if you're using a different Firestore instance (e.g., for testing or secondary app),
  // you can configure it here or when creating FirestoreUserDbService.
  return FirestoreUserDbService();
});
