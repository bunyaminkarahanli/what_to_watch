import 'package:flutter/material.dart';
import 'package:what_to_watch/auth/forgotpassword/view/forgot_password_view.dart';
import 'package:lottie/lottie.dart';
import 'package:what_to_watch/auth/signin/services/signin_service.dart';
import 'package:what_to_watch/auth/signup/view/signup_view.dart';
import 'package:what_to_watch/home/bottom_bar_view.dart';
import 'package:what_to_watch/onboarding/service/onboarding_service.dart';

class SigninView extends StatefulWidget {
  const SigninView({super.key});

  @override
  State<SigninView> createState() => _SigninViewState();
}

class _SigninViewState extends State<SigninView> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final SigninService _signinService = SigninService();
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    final OnboardingService _onboardingService = OnboardingService();

    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Lottie.asset(
                  'assets/animations/signin.json',
                  height: 240,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 40),
                Text('Giriş yap', style: theme.textTheme.headlineLarge),
                const SizedBox(height: 12),
                Text(
                  'İçerikleri keşfetmeye başla.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 40),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      mailBuild(),
                      const SizedBox(height: 20),
                      passwordBuild(),
                      const SizedBox(height: 32),
                      signinButtonBuild(),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [forgotPasswordBuild(), SignupButtonBuild()],
                      ),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () async {
                            final success = await _onboardingService
                                .onGoogleContinue();
                            if (!context.mounted) return;
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
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  TextButton SignupButtonBuild() {
    return TextButton(
      onPressed: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const SignupView()),
      ),
      child: const Text('Kayıt Ol'),
    );
  }

  TextButton forgotPasswordBuild() {
    return TextButton(
      onPressed: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ForgotPasswordView()),
      ),
      child: const Text('Şifremi Unuttum'),
    );
  }

  ElevatedButton signinButtonBuild() {
    return ElevatedButton(
      onPressed: () async {
        if (_formKey.currentState!.validate()) {
          try {
            // Firebase ile kullanıcı girişi yap
            await _signinService.signInWithEmail(
              email: _emailController.text,
              password: _passwordController.text.trim(),
            );

            // Başarılı durumda kullanıcıya bilgi ver
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Giriş başarılı! Hoş geldiniz.'),
                  backgroundColor: Colors.green,
                ),
              );
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const BottomBarView()),
                (route) => false,
              );
            }
          } catch (e) {
            // Hata durumunda kullanıcıya hata mesajını göster
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(e.toString()),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        }
      },
      child: const Text('Giriş Yap'),
    );
  }

  TextFormField passwordBuild() {
    return TextFormField(
      controller: _passwordController,
      obscureText: _obscureText,
      decoration: InputDecoration(
        labelText: 'Şifre',
        prefixIcon: const Icon(Icons.lock_outline),
        suffixIcon: IconButton(
          icon: Icon(_obscureText ? Icons.visibility_off : Icons.visibility),
          onPressed: () {
            setState(() {
              _obscureText = !_obscureText;
            });
          },
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Lütfen şifrenizi girin';
        }
        return null;
      },
    );
  }

  TextFormField mailBuild() {
    return TextFormField(
      controller: _emailController,
      decoration: InputDecoration(
        labelText: 'E-posta',
        prefixIcon: const Icon(Icons.email_outlined),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
      ),
      keyboardType: TextInputType.emailAddress,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Lütfen e-posta adresinizi girin';
        }
        return null;
      },
    );
  }
}
