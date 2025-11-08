import 'package:firebase_auth/firebase_auth.dart';

class SignoutService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw Exception("Çıkış işlemi başarısız: $e");
    }
  }
}
