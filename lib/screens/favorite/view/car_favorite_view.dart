import 'package:flutter/material.dart';
import 'package:what_to_watch/screens/favorite/services/car_favorite_service.dart';


class CarFavoriteView extends StatefulWidget {
  const CarFavoriteView({super.key});

  @override
  State<CarFavoriteView> createState() => _CarFavoriteViewState();
}

class _CarFavoriteViewState extends State<CarFavoriteView> {
  List<Map<String, String>> saved = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadSaved();
  }

  Future<void> loadSaved() async {
    final result = await CarFavoriteService.loadCars();
    if (!mounted) return;
    setState(() {
      saved = result;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Kaydedilen Arabalar")),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : saved.isEmpty
              ? Center(
                  child: Text(
                    "Henüz kaydedilen araba yok 🚗",
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: saved.length,
                  itemBuilder: (_, i) {
                    final car = saved[i];

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
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Model adı
                            Text(
                              car["model"] ?? "",
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 6),

                            // Neden uygun
                            Text(
                              car["why"] ?? "",
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[700],
                                height: 1.4,
                              ),
                            ),

                            const SizedBox(height: 8),

                            // Segment (varsa)
                            if ((car["segment"] ?? "").isNotEmpty)
                              Text(
                                "Segment: ${car["segment"]}",
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey[600],
                                ),
                              ),

                            const SizedBox(height: 12),

                            // Alt satır: sil butonu
                            Align(
                              alignment: Alignment.centerRight,
                              child: IconButton(
                                onPressed: () async {
                                  await CarFavoriteService.removeCar(
                                    car["model"]!,
                                  );
                                  await loadSaved();

                                  if (!mounted) return;

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text("Araba favorilerden silindi"),
                                      duration: Duration(seconds: 1),
                                    ),
                                  );
                                },
                                icon: const Icon(
                                  Icons.delete_outline,
                                  color: Colors.red,
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
