import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

class CarAIService {
  // Render backend URL
  final String baseUrl = "https://what-to-watch-backend.onrender.com";

  CarAIService();

  Future<List<Map<String, String>>> fetchRecommendedCars(
    Map<String, dynamic> prefs,
  ) async {
    // ✅ userId asla gönderme (B seçeneği: backend token’dan uid alıyor)
    prefs.remove("userId");

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception("Giriş yapılmadan araç önerisi alınamaz.");
    }

    // ✅ Firebase ID Token (gerekirse yenile)
    final idToken = await user.getIdToken(true);

    final response = await http.post(
      Uri.parse("$baseUrl/api/cars/recommend"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $idToken",
      },
      body: jsonEncode(prefs),
    );

    if (response.statusCode != 200) {
      String message = "Backend error: ${response.statusCode}";
      try {
        final err = jsonDecode(response.body);
        if (err is Map && err["message"] != null) {
          message = err["message"].toString();
        }
      } catch (_) {}
      throw Exception(message);
    }

    final parsed = jsonDecode(response.body);

    if (parsed is! List) {
      throw Exception(
          "Beklenen format: List, fakat gelen: ${parsed.runtimeType}");
    }

    return parsed.map<Map<String, String>>((e) {
      return {
        "model": e["model"]?.toString() ?? "",
        "why": e["why"]?.toString() ?? "",
        "segment": e["segment"]?.toString() ?? "",
      };
    }).toList();
  }
}
