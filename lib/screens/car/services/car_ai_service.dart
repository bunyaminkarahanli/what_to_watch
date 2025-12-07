import 'dart:convert';
import 'package:http/http.dart' as http;

class CarAIService {
  // Render backend URL
  final String baseUrl = "https://what-to-watch-backend.onrender.com";

  CarAIService();

  Future<List<Map<String, String>>> fetchRecommendedCars(
    Map<String, dynamic> prefs,
  ) async {
    print(">>> CarAIService baseUrl = $baseUrl");

    final response = await http.post(
      Uri.parse("$baseUrl/api/cars/recommend"),
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode(prefs),
    );

    // 🔥 Backend hata döndüyse özel mesaj üret
    if (response.statusCode != 200) {
      String message = "Backend error: ${response.statusCode}";

      try {
        final err = jsonDecode(response.body);

        if (err is Map && err["message"] != null) {
          message = err["message"];
        }
      } catch (_) {
        // JSON değilse default mesaj kalır
      }

      throw Exception(message);
    }

    // 🔥 Başarılı cevap
    final parsed = jsonDecode(response.body);

    if (parsed is! List) {
      throw Exception(
        "Beklenen format: List, fakat gelen: ${parsed.runtimeType}",
      );
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
