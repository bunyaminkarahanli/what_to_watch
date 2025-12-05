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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text("Kaydedilen Arabalar")),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : saved.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  "Henüz kaydedilen araba yok 🚗",
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontSize: 16,
                    color: isDark ? Colors.grey[300] : Colors.grey[600],
                  ),
                ),
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
                    // 🌙🌞 Tema tabanlı kart rengi
                    color: theme.cardColor, // CarResultView ile aynı mantık
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
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        /// MODEL ADI
                        Text(
                          car["model"] ?? "",
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 6),

                        /// NEDEN UYGUN
                        Text(
                          car["why"] ?? "",
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontSize: 14,
                            height: 1.4,
                            color: isDark ? Colors.grey[300] : Colors.grey[700],
                          ),
                        ),

                        const SizedBox(height: 8),

                        /// SEGMENT (VARSA)
                        if ((car["segment"] ?? "").isNotEmpty)
                          Text(
                            "Segment: ${car["segment"]}",
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontSize: 13,
                              color: isDark
                                  ? Colors.grey[400]
                                  : Colors.grey[600],
                            ),
                          ),

                        const SizedBox(height: 12),

                        /// SİL BUTONU
                        Align(
                          alignment: Alignment.centerRight,
                          child: IconButton(
                            onPressed: () async {
                              await CarFavoriteService.removeCar(car["model"]!);
                              await loadSaved();

                              if (!mounted) return;

                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Araba favorilerden silindi"),
                                  duration: Duration(seconds: 1),
                                ),
                              );
                            },
                            icon: Icon(
                              Icons.delete_outline,
                              color: isDark ? Colors.red[300] : Colors.red,
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
