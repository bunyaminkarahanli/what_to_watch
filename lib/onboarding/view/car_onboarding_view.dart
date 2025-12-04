import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:what_to_watch/auth/signin/view/signin_view.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:what_to_watch/home/bottom_bar_view.dart';
import 'package:what_to_watch/onboarding/service/onboarding_service.dart';

class CarOnboardingView extends StatelessWidget {
  const CarOnboardingView({super.key});

  @override
  Widget build(BuildContext context) {
    final OnboardingService _onboardingService = OnboardingService();
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Column(
            children: [
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
                  onPressed: () async {
                    bool success = await _onboardingService.onGoogleContinue();

                    if (success) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const BottomBarView(),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Google ile giriş başarısız!"),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    backgroundColor: const Color(0xFF3F51B5),
                    foregroundColor: Colors.white,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        "assets/icons/google.png",
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

// Future<void> _onGoogleContinue(BuildContext context) async {
//   try {
//     // 1. Google hesabını seç
//     final GoogleSignInAccount? gUser = await GoogleSignIn().signIn();
//     if (gUser == null) {
//       // Kullanıcı iptal etti
//       return;
//     }

//     // 2. Google auth bilgilerini al
//     final GoogleSignInAuthentication gAuth = await gUser.authentication;

//     // 3. Firebase credential oluştur
//     final credential = GoogleAuthProvider.credential(
//       accessToken: gAuth.accessToken,
//       idToken: gAuth.idToken,
//     );

//     // 4. Firebase ile giriş yap
//     await FirebaseAuth.instance.signInWithCredential(credential);

//     // 5. Başarılı → uygulamaya geç
//     Navigator.pushReplacement(
//       context,
//       MaterialPageRoute(builder: (_) => const BottomBarView()),
//     );
//   } catch (e) {
//     ScaffoldMessenger.of(
//       context,
//     ).showSnackBar(SnackBar(content: Text('Google ile giriş hatası: $e')));
//   }
// }
