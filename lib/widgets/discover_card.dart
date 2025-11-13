import 'package:flutter/material.dart';

class DiscoverCard extends StatelessWidget {
  final String title;
  final String imageUrl;
  final VoidCallback onTap;

  const DiscoverCard({
    required this.title,
    required this.imageUrl,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 5,
      shadowColor: Colors.black.withOpacity(0.15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // 📸 Arka plan görseli
          Image.asset(imageUrl, fit: BoxFit.cover),

          // 🌈 Alt kısım karartma
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Color(0xFF3F51B5)],
              ),
            ),
          ),

          // 📝 Başlık (aşağı ortalanmış)
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: const [
                    Shadow(
                      color: Colors.black54,
                      offset: Offset(0, 1),
                      blurRadius: 4,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 🔹 Tam ekran tıklama katmanı
          Positioned.fill(
            child: Material(
              color: const Color.fromARGB(0, 255, 255, 255),
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                splashColor: theme.primaryColor.withOpacity(0.2),
                onTap: onTap,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
