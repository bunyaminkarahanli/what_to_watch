import 'dart:convert';
import 'package:http/http.dart' as http;

class CarAIService {
  final String apiKey;

  CarAIService(this.apiKey);

  Future<List<Map<String, String>>> fetchRecommendedCars(
    Map<String, dynamic> prefs,
  ) async {
    // 1) Prompt'u kullanıcı cevaplarıyla doldur
    final String prompt =
        """
Sen bir araç danışmanısın. Görevin, kullanıcının verdiği bilgilere göre ona uygun araç segmentini ve 3–5 adet model önerisini sunmaktır.

Kurallar:
- Türkiye’deki güncel fiyatları bilmiyorsun. Kesinlikle FİYAT bilgisi verme.
- “Şu kadar TL’ye alırsın”, “bu fiyat bandında” gibi ifadeler kullanma.
- Sadece genel tavsiye ver: segment, araç tipi, yakıt tipi, vites tipi, uygun kullanım senaryosu vb.
- Önerdiğin her araç için kısa açıklama yap: kime uygun, artıları neler, neden öneriyorsun.
- Kullanıcı notlarını (ek açıklama) da mutlaka dikkate al.
- Cevabı mutlaka GEÇERLİ BİR JSON olarak döndür.
- JSON dışında hiçbir şey yazma (açıklama, metin, yorum ekleme).

Kullanıcının cevapları şunlardır:

- Kullanım alanı: ${prefs["usage"]}
- Aile büyüklüğü: ${prefs["family_size"]}
- Sürüş tecrübesi: ${prefs["driving_experience"]}
- Yakıt tercihi: ${prefs["fuel_type"]}
- Vites tercihi: ${prefs["gearbox"]}
- Araç tipi: ${prefs["body_type"]}
- Sıfır / ikinci el tercihi: ${prefs["new_or_used"]}
- Önceliği: ${prefs["priority"]}
- Teknoloji/donanım beklentisi: ${prefs["tech_level"]}
- Ek not: ${prefs["extra_desc"] ?? ""}

Bu bilgilere göre bana şu formatta bir JSON dizisi döndür:

[
  {
    "model": "Model adı",
    "why": "Bu modelin neden uygun olduğu, artıları, kime hitap ettiği (kısa açıklama)",
    "segment": "Önerilen segment (örneğin C-SUV, B-Hatchback vb.)"
  },
  {
    "model": "Diğer model",
    "why": "Açıklama",
    "segment": "Segment"
  }
]

Dikkat:
- "price_info" alanı kullanma, fiyatla ilgili hiçbir şey yazma.
- JSON dışında tek bir karakter bile yazma.
""";

    // 2) OpenAI API çağrısı
    final response = await http.post(
      Uri.parse("https://api.openai.com/v1/chat/completions"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $apiKey",
      },
      body: jsonEncode({
        "model": "gpt-4.1-mini",
        "messages": [
          {"role": "system", "content": "You are a car recommendation AI."},
          {"role": "user", "content": prompt},
        ],
        "temperature": 0.2,
      }),
    );

    // 3) Hata kontrolü
    if (response.statusCode != 200) {
      throw Exception(
        "OpenAI API error: ${response.statusCode} - ${response.body}",
      );
    }

    final body = jsonDecode(response.body);
    final content = body["choices"][0]["message"]["content"];

    // 4) Modelin döndürdüğü JSON'u parse et
    final parsed = jsonDecode(content);

    if (parsed is! List) {
      throw Exception(
        "Beklenen format: List, ama gelen: ${parsed.runtimeType}",
      );
    }

    // 5) JSON → Flutter Map
    return parsed.map<Map<String, String>>((e) {
      return {
        "model": e["model"]?.toString() ?? "",
        "why": e["why"]?.toString() ?? "",
        "segment": e["segment"]?.toString() ?? "",
      };
    }).toList();
  }
}
