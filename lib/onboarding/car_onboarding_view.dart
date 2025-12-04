import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:what_to_watch/auth/signin/view/signin_view.dart';

class CarOnboardingView extends StatelessWidget {
  const CarOnboardingView({super.key});

  void _onGoogleContinue(BuildContext context) {
    // TODO: Buraya Google ile giriş akışını ekle
    // İşlem başarılı olunca:
    // _goToApp(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Column(
            children: [
              // Orta kısım: ikon + başlık + açıklama (sadece 1. sayfa içeriği)
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Lottie.asset(
                      'assets/animations/car.json',
                      height: 280,
                      fit: BoxFit.contain,
                    ),

                    const SizedBox(height: 30),

                    const Text(
                      "Sana En Uygun Arabayı Bul",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 16),

                    Text(
                      "Birkaç basit soruya cevap ver, ihtiyaçlarına göre sana en uygun araba önerilerini gösterelim.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.grey[700],
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Alt kısım: Google ile devam et & Kayıt ol
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _onGoogleContinue(context),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    backgroundColor: const Color(
                      0xFF3F51B5,
                    ), // Google butonları genelde beyaz olur
                    foregroundColor: Colors.white,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        "assets/icons/google.png", // ikon dosyan
                        height: 22,
                        width: 22,
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        "Google ile devam et",
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),

              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SigninView()),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    backgroundColor: const Color(
                      0xFF3F51B5,
                    ), // Google butonları genelde beyaz olur
                    foregroundColor: Colors.white,
                  ),
                  child: const Text("Kayıt ol", style: TextStyle(fontSize: 16)),
                ),
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
