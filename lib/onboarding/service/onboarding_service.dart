import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart'; // debugPrint için

class OnboardingService {
  Future<bool> onGoogleContinue() async {
    try {
      // 1. Google hesabını seç
      final GoogleSignInAccount? gUser = await GoogleSignIn().signIn();
      if (gUser == null) {
        // Kullanıcı iptal etti
        return false;
      }

      // 2. Google auth bilgilerini al
      final GoogleSignInAuthentication gAuth = await gUser.authentication;

      // 3. Firebase credential oluştur
      final credential = GoogleAuthProvider.credential(
        accessToken: gAuth.accessToken,
        idToken: gAuth.idToken,
      );

      // 4. Firebase ile giriş yap
      await FirebaseAuth.instance.signInWithCredential(credential);

      // Başarılı
      return true;
    } catch (e) {
      debugPrint('Google ile giriş hatası: $e');
      return false;
    }
  }
}
