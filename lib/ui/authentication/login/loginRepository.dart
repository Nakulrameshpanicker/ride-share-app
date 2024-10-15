import 'package:firebase_auth/firebase_auth.dart';

class AuthRepository {
  Future<void> signUp(String email, String password) async {
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      print('Failed to sign up: $e');
      // Handle error
    }
  }

// Sign in with email and password
  Future<void> signIn(String email, String password) async {
    try {
      final user = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      print("user $user");
    } catch (e) {
      print('Failed to sign in: $e');
      // Handle error
    }
  }
}
