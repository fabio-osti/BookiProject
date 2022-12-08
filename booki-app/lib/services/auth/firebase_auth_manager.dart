import 'package:bookiapp/firebase_options.dart';
import 'package:bookiapp/services/auth/auth_exceptions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

class FirebaseAuthManager {
  static Future<void> initialize() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  static Future createUser(
    String email,
    String password,
  ) async {
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        throw AuthException(AuthProblem.weakPassword);
      } else if (e.code == 'email-already-in-use') {
        throw AuthException(AuthProblem.emailInUse);
      } else if (e.code == 'invalid-email') {
        throw AuthException(AuthProblem.invalidEmail);
      } else {
        throw AuthException(AuthProblem.generic);
      }
    } catch (_) {
      throw AuthException(AuthProblem.generic);
    }
  }

  static Future logIn(
    String email,
    String password,
  ) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (!FirebaseAuth.instance.currentUser!.emailVerified) {
        throw AuthException(AuthProblem.emailUnverified);
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        throw AuthException(AuthProblem.userNotFound);
      } else if (e.code == 'wrong-password') {
        throw AuthException(AuthProblem.wrongPassword);
      } else {
        throw AuthException(AuthProblem.generic);
      }
    } on AuthException {
      rethrow;
    } catch (_) {
      throw AuthException(AuthProblem.generic);
    }
  }
  
  static Future<void> logOut() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseAuth.instance.signOut();
    } else {
      throw AuthException(AuthProblem.generic);
    }
  }

  static Future<void> sendEmailVerification() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await user.sendEmailVerification();
    } else {
      throw AuthException(AuthProblem.generic);
    }
  }

  static Future<void> sendPasswordReset(String toEmail) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: toEmail);
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'firebase_auth/invalid-email':
          throw AuthException(AuthProblem.invalidEmail);
        case 'firebase_auth/user-not-found':
          throw AuthException(AuthProblem.userNotFound);
        default:
          throw AuthException(AuthProblem.generic);
      }
    } catch (_) {
      throw AuthException(AuthProblem.generic);
    }
  }
}
