import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:what_to_watch/screens/favorite/services/car_favorite_service.dart';
import 'package:what_to_watch/screens/car/services/car_ai_service.dart';

class CarResultView extends StatefulWidget {
  final Map<String, dynamic> answers;

  const CarResultView({super.key, required this.answers});

  @override
  State<CarResultView> createState() => _CarResultViewState();
}

class _CarResultViewState extends State<CarResultView> {
  bool loading = true;
  String? error;

  List<Map<String, String>> recommended = [];

  /// FAVORİLERE ALINAN KARTLARIN INDEXLERİNİ TUTUYORUZ
  Set<int> favoriteIndexes = {};

  @override
  void initState() {
    super.initState();
    loadFromAI();
  }

  Future<void> loadFromAI() async {
    try {
      final apiKey = dotenv.env["OPENAI_KEY"];

      if (apiKey == null || apiKey.isEmpty) {
        setState(() {
          error =
              "API anahtarı bulunamadı (OPENAI_KEY). Lütfen .env dosyanı kontrol et.";
          loading = false;
        });
        return;
      }

      final ai = CarAIService(apiKey);
      final result = await ai.fetchRecommendedCars(widget.answers);

      if (!mounted) return;

      setState(() {
        recommended = result;
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        error = "Bir hata oluştu: $e";
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Önerilen Arabalar")),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : error != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  error!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: recommended.length,
              itemBuilder: (_, i) {
                final car = recommended[i];
                final isFavorite = favoriteIndexes.contains(i);

                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.07),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Model adı
                        Text(
                          car["model"] ?? "Bilinmeyen Model",
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 10),

                        // Açıklama
                        Text(
                          car["why"] ?? "",
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.grey[700],
                            height: 1.4,
                          ),
                        ),

                        const SizedBox(height: 14),

                        // ❤️ Favori butonu
                        Align(
                          alignment: Alignment.centerRight,
                          child: IconButton(
                            onPressed: () async {
                              // FAVORİYE EKLE / ÇIKAR
                              setState(() {
                                if (isFavorite) {
                                  favoriteIndexes.remove(i);
                                } else {
                                  favoriteIndexes.add(i);
                                }
                              });

                              // Servise kaydet
                              await CarFavoriteService.saveCar(car);

                              if (!mounted) return;

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    isFavorite
                                        ? "Favorilerden çıkarıldı"
                                        : "Favorilere eklendi!",
                                  ),
                                  duration: const Duration(seconds: 1),
                                ),
                              );
                            },

                            /// İKON DURUMU
                            icon: Icon(
                              isFavorite
                                  ? Icons
                                        .favorite // DOLU KIRMIZI KALP
                                  : Icons.favorite_border, // BOŞ KALP
                              color: Colors.red,
                              size: 30,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
