// Flutter UI kütüphanesini projeye dahil ediyoruz
import 'package:flutter/material.dart';

// ✅ Firebase Auth import
import 'package:firebase_auth/firebase_auth.dart';

// Sonuç ekranını import ediyoruz
import 'package:what_to_watch/screens/car/view/result_car_view.dart';

// Soru modelimizi import ediyoruz
import '../models/question_model.dart';

// JSON’dan soruları okuyan servis dosyamızı import ediyoruz
import '../services/question_service.dart';

/// --------------------------------------------------------------
/// ARABA SORU EKRANI
/// Bu ekran:
/// 1) JSON'dan soruları yükler
/// 2) Kullanıcıya tek tek soruları gösterir
/// 3) Cevapları toplar
/// 4) Son soruda “Araba Bul” → Sonuç ekranına yollar
/// --------------------------------------------------------------
class CarView extends StatefulWidget {
  const CarView({super.key});

  @override
  State<CarView> createState() => _YoutubeViewState();
}

/// --------------------------------------------------------------
/// STATE SINIFI
/// Ekranın dinamik olarak değişen verileri burada saklanır.
/// --------------------------------------------------------------
class _YoutubeViewState extends State<CarView> {
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
    questions = await CarQuestionRepo.loadQuestions(); // Servisi çağır
    setState(() => loading = false); // Artık ekrana çizilebilir
  }

  /// --------------------------------------------------------------
  /// SORU İNPUT ALANI OLUŞTURMA
  /// Soru type: "select" → Seçenekler alt alta kart şeklinde
  /// Soru type: "text"   → TextField
  /// --------------------------------------------------------------
  Widget buildInput(QuestionModel q) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (q.type == "select") {
      final String? selected = answers[q.id] as String?;

      return Column(
        children: q.options!.map((option) {
          final bool isSelected = option == selected;

          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                setState(() {
                  answers[q.id] = option;
                });
                next();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? theme.colorScheme.primary
                        : theme.dividerColor,
                    width: 1.5,
                  ),
                  color: isSelected
                      ? theme.colorScheme.primary.withOpacity(0.12)
                      : (isDark ? theme.colorScheme.surface : Colors.white),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        option,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontSize: 16,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.w400,
                          color: isSelected
                              ? theme.colorScheme.onPrimary
                              : theme.colorScheme.onSurface,
                        ),
                      ),
                    ),
                    Icon(
                      isSelected ? Icons.check_circle : Icons.circle_outlined,
                      size: 22,
                      color: isSelected
                          ? theme.colorScheme.primary
                          : theme.iconTheme.color,
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      );
    }

    // text input
    return TextField(
      decoration: InputDecoration(
        hintText: q.placeholder ?? "",
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 16,
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
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
    if (q.required &&
        (answers[q.id] == null || answers[q.id].toString().isEmpty)) {
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
      // ✅ Firebase UID'yi cevaba ekliyoruz
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) {
        answers['userId'] = uid;
      }

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => CarResultView(answers: answers),
        ),
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
    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Araba Bul")),
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
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: questions.length,
                itemBuilder: (_, i) =>
                    SingleChildScrollView(child: buildInput(questions[index])),
              ),
            ),

            const SizedBox(height: 16),

            // 3) Alt butonlar
            Row(
              children: [
                if (index > 0)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: back,
                      child: const Text("Geri"),
                    ),
                  ),
                if (index > 0) const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: next,
                    child: Text(
                      index == questions.length - 1 ? "Araba Bul" : "İleri",
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
