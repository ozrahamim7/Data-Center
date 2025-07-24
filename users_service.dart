import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:srv_hub/models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<User?> get user => _auth.authStateChanges();

  Future<UserCredential?> registerWithEmailAndPassword(
      String email, String password, String username) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);

      await _firestore.collection('users').doc(result.user!.uid).set({
        'username': username,
        'email': email,
        'role': 'viewer',
        'createdAt': Timestamp.now(),
      });

      return result;
    } catch (e) {
      print('Error registering user: $e');
      rethrow;
    }
  }

  Future<UserCredential?> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      return result;
    } catch (e) {
      print('Error signing in: $e');
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      return await _auth.signOut();
    } catch (e) {
      print('Error signing out: $e');
      rethrow;
    }
  }

  User? getCurrentUser() {
    return _auth.currentUser;
  }

  Future<UserRole> getUserRole() async {
    try {
      final currentUser = getCurrentUser();
      if (currentUser == null) {
        return UserRole.technical;
      }

      final userDoc = await _firestore.collection('users').doc(currentUser.uid).get();
      if (!userDoc.exists) {
        return UserRole.technical;
      }

      final userData = userDoc.data();
      final roleStr = userData?['role'] as String? ?? 'technical';

      switch (roleStr) {
        case 'admin':
          return UserRole.admin;
        case 'viewer':
          return UserRole.viewer;
        case 'technical':
          return UserRole.technical;
        default:
          return UserRole.technical;
      }
    } catch (e) {
      print('Error getting user role: $e');
      return UserRole.technical;
    }
  }
}
