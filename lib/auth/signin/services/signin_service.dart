import 'package:firebase_auth/firebase_auth.dart';

class SigninService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Email ve şifre ile kullanıcı girişi yapar
  /// Başarılı olursa User nesnesi döner
  /// Hata durumunda Türkçe hata mesajı ile exception fırlatır
  Future<User?> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      // Firebase Authentication ile giriş yap
      final UserCredential userCredential = await _auth
          .signInWithEmailAndPassword(email: email.trim(), password: password);

      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      // Firebase hatalarını Türkçe mesajlara çevir
      throw _handleAuthException(e);
    } catch (e) {
      throw 'Beklenmeyen bir hata oluştu. Lütfen tekrar deneyin.';
    }
  }

  /// Firebase Auth hatalarını Türkçe mesajlara çevirir
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'Bu e-posta adresi ile kayıtlı kullanıcı bulunamadı.';
      case 'wrong-password':
        return 'Hatalı şifre. Lütfen tekrar deneyin.';
      case 'invalid-email':
        return 'Geçersiz e-posta adresi.';
      case 'user-disabled':
        return 'Bu hesap devre dışı bırakılmış.';
      case 'invalid-credential':
        return 'E-posta veya şifre hatalı.';
      case 'network-request-failed':
        return 'İnternet bağlantınızı kontrol edin.';
      default:
        return 'Giriş sırasında bir hata oluştu: ${e.message}';
    }
  }
}
