import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleAuthResult {
  final String email;
  final String displayName;
  final String? photoUrl;
  final String? idToken;
  final User? firebaseUser;

  GoogleAuthResult({
    required this.email,
    required this.displayName,
    this.photoUrl,
    this.idToken,
    this.firebaseUser,
  });
}

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'email',
      'profile',
    ],
  );

  /// Cek apakah Firebase telah berhasil diinisialisasi
  bool get isFirebaseInitialized => Firebase.apps.isNotEmpty;

  /// Pengguna yang sedang masuk di FirebaseAuth (jika Firebase aktif)
  User? get currentFirebaseUser {
    if (isFirebaseInitialized) {
      try {
        return FirebaseAuth.instance.currentUser;
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  /// Masuk atau Daftar Menggunakan Akun Google Asli
  Future<GoogleAuthResult?> signInWithGoogle() async {
    try {
      // 1. Munculkan dialog pemilihan akun Google
      final GoogleSignInAccount? googleAccount = await _googleSignIn.signIn();
      if (googleAccount == null) {
        // Pengguna membatalkan dialog login
        return null;
      }

      // 2. Dapatkan token otentikasi dari Google
      final GoogleSignInAuthentication googleAuth =
          await googleAccount.authentication;

      User? firebaseUser;

      // 3. Jika Firebase terinisialisasi, hubungkan kredensial ke FirebaseAuth
      if (isFirebaseInitialized) {
        try {
          final AuthCredential credential = GoogleAuthProvider.credential(
            accessToken: googleAuth.accessToken,
            idToken: googleAuth.idToken,
          );

          final UserCredential userCredential =
              await FirebaseAuth.instance.signInWithCredential(credential);
          firebaseUser = userCredential.user;
        } catch (firebaseErr) {
          debugPrint('Firebase Auth link warning: $firebaseErr');
          // Tetap lanjutkan jika Google sign-in berhasil di tingkat client
        }
      }

      return GoogleAuthResult(
        email: googleAccount.email,
        displayName: googleAccount.displayName ?? 'Pengguna Google',
        photoUrl: googleAccount.photoUrl,
        idToken: googleAuth.idToken,
        firebaseUser: firebaseUser,
      );
    } catch (e) {
      debugPrint('Error signInWithGoogle: $e');
      rethrow;
    }
  }

  /// Keluar dari akun Google dan Firebase
  Future<void> signOut() async {
    try {
      if (await _googleSignIn.isSignedIn()) {
        await _googleSignIn.signOut();
      }
      if (isFirebaseInitialized) {
        await FirebaseAuth.instance.signOut();
      }
    } catch (e) {
      debugPrint('Error during signOut: $e');
    }
  }
}
