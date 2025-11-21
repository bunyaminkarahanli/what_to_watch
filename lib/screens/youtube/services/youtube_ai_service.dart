import 'dart:convert';
import 'package:http/http.dart' as http;

class YoutubeAIService {
  final String apiKey;

  YoutubeAIService(this.apiKey);

  Future<List<Map<String, String>>> fetchRecommendedChannels(
    Map<String, dynamic> prefs,
  ) async {
    // ------------------------------------------------------
    // 🔥 FİNAL ÜRETİM PROMPTU — GERÇEK YOUTUBE KANALLARI 🔥
    // ------------------------------------------------------
    final String prompt =
        """
Sen profesyonel bir YouTube içerik analisti ve öneri sistemisin. 
Görevin, kullanıcının tercih ettiği özellikleri analiz ederek
**gerçek YouTube kanallarını** önermek.

❗ ÖNEMLİ KURALLAR
- Sadece GERÇEK YouTube kanallarını öner.
- Hayali (uydurulmuş) kanal adı üretme.
- Gerçek olmayan link verme.
- Yanlış, bozuk, rastgele kanal verme.
- Cevabı sadece geçerli bir JSON dizi (array) olarak döndür.
- JSON dışında tek bir cümle bile yazma.

Kullanıcı tercihleri:

• Kategori: ${prefs["category"]}
• Dil: ${prefs["language"]}
• Popülerlik: ${prefs["popularity"]}
• İçerik stili: ${prefs["content_style"]}
• İçerik yoğunluğu: ${prefs["content_depth"]}
• Video uzunluğu: ${prefs["video_length"]}
• Kullanıcı açıklaması: ${prefs["channel_description"]}

### Görevin:
Bu tercihlere **en uygun** 4 adet YouTube kanalını araştırıp seç.

### Her kanal için JSON formatı:
{
  "name": "",
  "description": "",
  "link": ""
}

### Açıklama kuralları:
- 1 cümle kısa özet olsun.
- Kanalın güçlü yönlerini anlat.
- Kullanıcının tercihleriyle neden eşleştiğini hissettir.

### Link formatı:
Mutlaka şu formatta olmalı:
https://www.youtube.com/@KANALADI

### Son olarak:
Tamamı sadece bir JSON ARRAY olarak dön.
Ekstra açıklama yok.
""";

    // -------------------------------
    // OpenAI API Çağrısı
    // -------------------------------
    final response = await http.post(
      Uri.parse("https://api.openai.com/v1/chat/completions"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $apiKey",
      },
      body: jsonEncode({
        "model": "gpt-4o",
        "messages": [
          {"role": "system", "content": "You are a YouTube recommendation AI."},
          {"role": "user", "content": prompt},
        ],
        "temperature": 0.4,
      }),
    );

    // -------------------------------
    // JSON Parse
    // -------------------------------
    final content = jsonDecode(
      response.body,
    )["choices"][0]["message"]["content"];

    final parsed = jsonDecode(content);

    return List<Map<String, String>>.from(parsed);
  }
}
