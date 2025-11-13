import 'package:flutter/material.dart';
import 'package:what_to_watch/screens/kick/view/kick_view.dart';
import 'package:what_to_watch/screens/youtube/view/youtube_view.dart';
import 'package:what_to_watch/widgets/discover_card.dart';

class DiscoverView extends StatefulWidget {
  const DiscoverView({super.key});

  @override
  State<DiscoverView> createState() => _DiscoverViewState();
}

class _DiscoverViewState extends State<DiscoverView> {
  final List<Map<String, dynamic>> items = [
    {
      "title": "Youtube",
      "image": 'assets/images/youtube.png',
      "color": Colors.blue,
    },
    {
      "title": "Kick",
      "image": 'assets/images/gamer.png',
      "color": Colors.orange,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Discover")),
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
            return DiscoverCard(
              title: item["title"],
              imageUrl: item["image"],
              onTap: () {
                if (item["title"] == "Youtube") {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const YoutubeView(),
                    ),
                  );
                } else if (item["title"] == "Kick") {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const KickView()),
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
