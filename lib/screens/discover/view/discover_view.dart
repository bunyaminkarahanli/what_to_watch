import 'package:flutter/material.dart';
import 'package:what_to_watch/screens/car/view/car_view.dart';
import 'package:what_to_watch/screens/motorcycle/view/motorcycle_view.dart';

import 'package:what_to_watch/widgets/discover_card.dart';

class DiscoverView extends StatefulWidget {
  const DiscoverView({super.key});

  @override
  State<DiscoverView> createState() => _DiscoverViewState();
}

class _DiscoverViewState extends State<DiscoverView> {
  final List<Map<String, dynamic>> items = [
    {"title": "Araba", "image": 'assets/images/car.png', "color": Colors.blue},
    {
      "title": "Motosiklet",
      "image": 'assets/images/motorcycle.png',
      "color": Colors.orange,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Keşfet")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          itemCount: items.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1,
          ),
          itemBuilder: (context, index) {
            final item = items[index];
            final title = item["title"] as String;

            return DiscoverCard(
              title: title,
              imageUrl: item["image"],
              subtitle: title == "Motosiklet" ? "Yakında" : null,
              onTap: () {
                if (title == "Araba") {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const CarView()),
                  );
                }
              },
            );
          },
        ),
      ),
    );
  }
}
