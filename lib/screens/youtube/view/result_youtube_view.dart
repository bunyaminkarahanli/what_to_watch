import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/youtube_ai_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class YoutubeResultView extends StatefulWidget {
  final Map<String, dynamic> answers;

  const YoutubeResultView({super.key, required this.answers});

  @override
  State<YoutubeResultView> createState() => _YoutubeResultViewState();
}

class _YoutubeResultViewState extends State<YoutubeResultView> {
  bool loading = true;
  String? error;

  List<Map<String, String>> recommended = [];

  @override
  void initState() {
    super.initState();
    loadFromAI();
  }

  Future<void> loadFromAI() async {
    try {
      final ai = YoutubeAIService(dotenv.env["OPENAI_KEY"]!);

      final result = await ai.fetchRecommendedChannels(widget.answers);
      setState(() {
        recommended = result;
        loading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Önerilen Kanallar")),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : error != null
          ? Center(child: Text(error!))
          : ListView.builder(
              itemCount: recommended.length,
              itemBuilder: (_, i) {
                final c = recommended[i];
                return ListTile(
                  title: Text(c["name"]!),
                  subtitle: Text(c["description"]!),
                  onTap: () async {
                    final url = Uri.parse(c["link"]!);
                    if (await canLaunchUrl(url)) {
                      await launchUrl(
                        url,
                        mode: LaunchMode.externalApplication,
                      );
                    }
                  },
                );
              },
            ),
    );
  }
}
