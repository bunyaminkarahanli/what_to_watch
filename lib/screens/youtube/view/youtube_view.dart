// Flutter UI kütüphanesini projeye dahil ediyoruz
import 'package:flutter/material.dart';

// Sonuç ekranını import ediyoruz
import 'package:what_to_watch/screens/youtube/view/result_youtube_view.dart';

// Soru modelimizi import ediyoruz
import '../models/question_model.dart';

// JSON’dan soruları okuyan servis dosyamızı import ediyoruz
import '../services/question_service.dart';

/// --------------------------------------------------------------
/// YOUTUBE VIEW EKRANI
/// Bu ekran:
/// 1) JSON'dan soruları yükler
/// 2) Kullanıcıya tek tek soruları gösterir
/// 3) Cevapları toplar
/// 4) Son soruda “Kanal Bul” → Sonuç ekranına yollar
/// --------------------------------------------------------------
class YoutubeView extends StatefulWidget {
  const YoutubeView({super.key});

  @override
  State<YoutubeView> createState() => _YoutubeViewState();
}

/// --------------------------------------------------------------
/// STATE SINIFI
/// Ekranın dinamik olarak değişen verileri burada saklanır.
/// --------------------------------------------------------------
class _YoutubeViewState extends State<YoutubeView> {
  // JSON'dan gelecek soru listesi
  List<QuestionModel> questions = [];

  // Sorular arasında geçiş için PageController
  final PageController _pageController = PageController();

  // Kullanıcının verdiği cevaplar (id → cevap)
  final Map<String, dynamic> answers = {};

  // Sorular yüklenirken loading animasyonu göstermek için
  bool loading = true;

  // Kaçıncı soruda olduğumuzu tutar
  int index = 0;

  /// --------------------------------------------------------------
  /// initState()
  /// Ekran açıldığında soru verilerini JSON'dan yükler
  /// --------------------------------------------------------------
  @override
  void initState() {
    super.initState();
    loadQuestions(); // JSON yükle
  }

  /// --------------------------------------------------------------
  /// JSON'daki soruları yükleyen fonksiyon
  /// Servis sınıfından soruları çekip listeye atar
  /// --------------------------------------------------------------
  Future<void> loadQuestions() async {
    questions = await YoutubeQuestionRepo.loadQuestions(); // Servisi çağır
    setState(() => loading = false); // Artık ekrana çizilebilir
  }

  /// --------------------------------------------------------------
  /// SORU İNPUT ALANI OLUŞTURMA
  /// Soru type: "select" → Dropdown
  /// Soru type: "text" → TextField
  /// --------------------------------------------------------------
  Widget buildInput(QuestionModel q) {
    // Eğer soru dropdown tipi ise
    if (q.type == "select") {
      return DropdownButtonFormField<String>(
        value:
            answers[q
                .id], // Eğer bu soruya daha önce cevap verilmişse o gözüksün

        decoration: InputDecoration(
          hintText: "Seçim yap", // Placeholder
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 16,
          ),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),

        // JSON’daki seçenekleri dropdown içine ekle
        items: q.options!
            .map((e) => DropdownMenuItem(value: e, child: Text(e)))
            .toList(),

        // Kullanıcı seçim yaptığında cevap kaydet
        onChanged: (v) => setState(() => answers[q.id] = v),
      );
    }

    // Eğer soru text input ise
    return TextField(
      decoration: InputDecoration(
        hintText: q.placeholder ?? "", // JSON’daki placeholder
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 16,
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),

      // Kullanıcı yazdıkça cevabı kaydeder
      onChanged: (v) => answers[q.id] = v,
    );
  }

  /// --------------------------------------------------------------
  /// İLERİ BUTONU FONKSİYONU
  /// - Zorunlu soru cevapsızsa uyarır
  /// - Sonraki soruya geçer
  /// - Son sorudaysa sonuç ekranına geçer
  /// --------------------------------------------------------------
  void next() {
    // Şu anki soruyu al
    final q = questions[index];

    // Eğer soru required ise ve cevap yoksa uyarı göster
    if (q.required && answers[q.id] == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("${q.label} gerekli")));
      return; // İleri gitme
    }

    // Eğer son soru değilse bir sonraki soruya geç
    if (index < questions.length - 1) {
      setState(() => index++); // Soru indexini artır
      _pageController.nextPage(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    }
    // Eğer son sorudaysa → Sonuç ekranına geç
    else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => YoutubeResultView(answers: answers)),
      );
    }
  }

  /// --------------------------------------------------------------
  /// GERİ BUTONU FONKSİYONU
  /// Bir önceki soruya döner
  /// --------------------------------------------------------------
  void back() {
    if (index > 0) {
      setState(() => index--); // index azalt
      _pageController.previousPage(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    }
  }

  /// --------------------------------------------------------------
  /// ANA EKRAN
  /// --------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    // Eğer sorular hala yükleniyorsa loading göster
    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // Eğer sorular yüklendiyse ekranı çiz
    return Scaffold(
      appBar: AppBar(title: const Text("YouTube Kanal Bul")), // Sayfa başlığı

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1) Soru başlığı
            Text(
              questions[index].label,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 20),

            // 2) Input alanı PageView içinde tek tek gösterilir
            SizedBox(
              height: 180,
              child: PageView.builder(
                controller: _pageController, // PageController
                physics:
                    const NeverScrollableScrollPhysics(), // Kullanıcı kaydıramaz
                itemCount: questions.length, // toplam soru sayısı
                // Sadece o anki index’in inputu gösterilir
                itemBuilder: (_, i) => buildInput(questions[index]),
              ),
            ),

            const Spacer(), // Boşluk bırakır
            // 3) Alt butonlar
            Row(
              children: [
                // Geri butonu (ilk soruda gösterilmez)
                if (index > 0)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: back,
                      child: const Text("Geri"),
                    ),
                  ),

                if (index > 0) const SizedBox(width: 12),

                // İleri veya Kanal Bul butonu
                Expanded(
                  child: ElevatedButton(
                    onPressed: next,
                    child: Text(
                      index == questions.length - 1
                          ? "Kanal Bul" // Son soru
                          : "İleri", // Diğer sorular
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
