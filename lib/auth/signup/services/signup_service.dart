import 'package:firebase_auth/firebase_auth.dart';

class SignupService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Email ve şifre ile kullanıcı kaydı oluşturur
  /// Başarılı olursa User nesnesi döner
  /// Hata durumunda Türkçe hata mesajı ile exception fırlatır
  Future<User?> signUpWithEmail({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      // Firebase Authentication ile kullanıcı oluştur
      final UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(
            email: email.trim(),
            password: password,
          );

      // Kullanıcının ismini güncelle
      await userCredential.user?.updateDisplayName(name);

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
      case 'weak-password':
        return 'Şifre çok zayıf. Daha güçlü bir şifre seçin.';
      case 'email-already-in-use':
        return 'Bu e-posta adresi zaten kullanımda.';
      case 'invalid-email':
        return 'Geçersiz e-posta adresi.';
      case 'operation-not-allowed':
        return 'E-posta/şifre girişi şu anda devre dışı.';
      case 'network-request-failed':
        return 'İnternet bağlantınızı kontrol edin.';
      default:
        return 'Kayıt sırasında bir hata oluştu: ${e.message}';
    }
  }
}
