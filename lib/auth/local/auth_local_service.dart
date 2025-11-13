import 'package:shared_preferences/shared_preferences.dart';
import 'package:what_to_watch/constants/pref_keys.dart';

class AuthLocalService {
  /// Kullanıcı giriş yaptığında bilgileri kaydeder
  Future<void> saveLogin(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(PrefKeys.keyIsLoggedIn, true);
    await prefs.setString(PrefKeys.keyUserEmail, email);
  }

  /// Kullanıcı giriş yapmış mı? (Uygulama açılırken kontrol için)
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(PrefKeys.keyIsLoggedIn) ?? false;
  }

  /// Kayıtlı e-posta adresini getirir
  Future<String?> getUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(PrefKeys.keyUserEmail);
  }

  /// Kullanıcı çıkış yaptığında bilgileri siler
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(PrefKeys.keyIsLoggedIn);
    await prefs.remove(PrefKeys.keyUserEmail);
  }
}
