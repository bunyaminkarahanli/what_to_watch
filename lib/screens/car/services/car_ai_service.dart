import 'dart:convert';
import 'package:http/http.dart' as http;

class CarAIService {
  // ARTIK RENDER'DAKİ BACKENDİ KULLANIYORUZ
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

    if (response.statusCode != 200) {
      throw Exception(
        "Backend error: ${response.statusCode} - ${response.body}",
      );
    }

    final parsed = jsonDecode(response.body);

    if (parsed is! List) {
      throw Exception(
        "Beklenen format: List, ama gelen: ${parsed.runtimeType}",
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
