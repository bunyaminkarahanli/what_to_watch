import 'package:firebase_auth/firebase_auth.dart';

class ForgotPasswordService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Şifre sıfırlama e-postası gönderir
  /// Hata durumunda Türkçe mesaj döner
  Future<void> sendPasswordResetEmail({required String email}) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (_) {
      throw 'Beklenmeyen bir hata oluştu. Lütfen tekrar deneyin.';
    }
  }

  /// Firebase Auth hatalarını Türkçe mesajlara çevirir
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'Bu e-posta adresi ile kayıtlı kullanıcı bulunamadı.';
      case 'invalid-email':
        return 'Geçersiz e-posta adresi.';
      case 'missing-email':
        return 'Lütfen bir e-posta adresi girin.';
      case 'network-request-failed':
        return 'İnternet bağlantınızı kontrol edin.';
      case 'too-many-requests':
        return 'Çok fazla deneme yapıldı. Bir süre sonra tekrar deneyin.';
      default:
        return 'Şifre sıfırlanırken bir hata oluştu: ${e.message}';
    }
  }
}
