import 'package:flutter/material.dart';
import 'package:what_to_watch/screens/car/view/car_view.dart';
import 'package:what_to_watch/screens/discover/data/data_discover.dart';
import 'package:what_to_watch/widgets/discover_card.dart';

// yeni eklenen import

class DiscoverView extends StatefulWidget {
  const DiscoverView({super.key});

  @override
  State<DiscoverView> createState() => _DiscoverViewState();
}

class _DiscoverViewState extends State<DiscoverView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Keşfet")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          itemCount: discoverItems.length, // <-- artık buradan geliyor
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1,
          ),
          itemBuilder: (context, index) {
            final item = discoverItems[index];

            return DiscoverCard(
              title: item.title,
              imageUrl: item.image,
              subtitle: item.subtitle,
              onTap: () {
                if (item.title == "Araba") {
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
