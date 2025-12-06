import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:url_launcher/url_launcher.dart';

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

  Future<void> _openCarInGoogle(String query) async {
    final encoded = Uri.encodeComponent(query);
    final uri = Uri.parse('https://www.google.com/search?q=$encoded');

    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);

    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Bağlantı açılamadı."),
          duration: Duration(seconds: 1),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

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
                      style: theme.textTheme.bodyMedium?.copyWith(fontSize: 16),
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: recommended.length,
                  itemBuilder: (_, i) {
                    final car = recommended[i];
                    final isFavorite = favoriteIndexes.contains(i);
                    final model = car["model"] ?? "Bilinmeyen Model";

                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: isDark
                                ? Colors.black.withOpacity(0.5)
                                : Colors.black.withOpacity(0.07),
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
                            /// MODEL ADI
                            Text(
                              model,
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 10),

                            /// AÇIKLAMA
                            Text(
                              car["why"] ?? "",
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontSize: 15,
                                height: 1.4,
                                color: isDark
                                    ? Colors.grey[300]
                                    : Colors.grey[700],
                              ),
                            ),

                            const SizedBox(height: 12),

                            /// ALT SATIR: ARACA GİT + FAVORİ AYNI HİZADA
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                // 🔎 ARACA GİT BUTONU
                                TextButton.icon(
                                  onPressed: () =>
                                      _openCarInGoogle("$model araba"),
                                  style: TextButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 6),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                      side: BorderSide(
                                        color: Color(0xFF3F51B5),
                                      ),
                                    ),
                                  ),
                                  icon: const Icon(
                                    Icons.search,
                                    size: 18,
                                  ),
                                  label: const Text(
                                    "Araca git",
                                    style: TextStyle(fontSize: 13),
                                  ),
                                ),

                                const SizedBox(width: 8),

                                //  FAVORİ BUTONU
                                IconButton(
                                  onPressed: () async {
                                    setState(() {
                                      if (isFavorite) {
                                        favoriteIndexes.remove(i);
                                      } else {
                                        favoriteIndexes.add(i);
                                      }
                                    });

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
                                  icon: Icon(
                                    isFavorite
                                        ? Icons.favorite
                                        : Icons.favorite_border,
                                    color: Colors.red,
                                    size: 26,
                                  ),
                                ),
                              ],
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
