import 'package:flutter/material.dart';
import 'package:what_to_watch/auth/signup/services/signup_service.dart';

class SignupView extends StatefulWidget {
  const SignupView({super.key});

  @override
  State<SignupView> createState() => _SignupViewState();
}

class _SignupViewState extends State<SignupView> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final SignupService _signupService = SignupService();

  bool _obscureText = true;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 60),
              Image.asset('assets/images/onboar3.png', height: 200),
              const SizedBox(height: 40),
              Text('Kayıt Ol', style: theme.textTheme.headlineLarge),
              const SizedBox(height: 12),
              Text(
                'Yeni bir hesap oluştur ve içerikleri keşfetmeye başla.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 40),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    nameBuild(),
                    SizedBox(height: 16),
                    mailBuild(),
                    SizedBox(height: 16),
                    passwordBuild(),
                    SizedBox(height: 16),
                    confirmPasswordBuild(),
                    SizedBox(height: 32),
                    signupButtonBuild(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  ElevatedButton signupButtonBuild() {
    return ElevatedButton(
      onPressed: () async {
        if (_formKey.currentState!.validate()) {
          try {
            // Firebase ile kullanıcı kaydı oluştur
            await _signupService.signUpWithEmail(
              email: _emailController.text,
              password: _passwordController.text,
              name: _nameController.text,
            );

            // Başarılı durumda kullanıcıya bilgi ver
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Kayıt başarılı! Hoş geldiniz.'),
                  backgroundColor: Colors.green,
                ),
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
      child: const Text('Kayıt Ol'),
    );
  }

  TextFormField confirmPasswordBuild() {
    return TextFormField(
      controller: _confirmPasswordController,
      obscureText: _obscureText,
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.lock_outline),
        suffixIcon: IconButton(
          icon: Icon(_obscureText ? Icons.visibility_off : Icons.visibility),
          onPressed: () => setState(() => _obscureText = !_obscureText),
        ),
        labelText: 'Şifre Tekrar',
        hintText: 'Şifre Tekrar',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Lütfen bir şifre oluşturun';
        } else if (value != _passwordController.text) {
          return 'Şifreler eşleşmiyor';
        }
        return null;
      },
    );
  }

  TextFormField passwordBuild() {
    return TextFormField(
      controller: _passwordController,
      obscureText: _obscureText,
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.lock_outline),
        suffixIcon: IconButton(
          icon: Icon(_obscureText ? Icons.visibility_off : Icons.visibility),
          onPressed: () => setState(() => _obscureText = !_obscureText),
        ),
        labelText: 'Şifre',
        hintText: 'Şifre',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Lütfen bir şifre oluşturun';
        } else if (value.length < 6) {
          return 'Şifre en az 6 karakter olmalı';
        }
        return null;
      },
    );
  }

  TextFormField mailBuild() {
    return TextFormField(
      keyboardType: TextInputType.emailAddress,
      controller: _emailController,
      decoration: InputDecoration(
        prefixIcon: Icon(Icons.mail),
        labelText: 'E-posta',
        hintText: 'E-posta',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Lütfen e-posta adresinizi girin';
        }
        return null;
      },
    );
  }

  TextFormField nameBuild() {
    return TextFormField(
      keyboardType: TextInputType.name,
      controller: _nameController,
      decoration: InputDecoration(
        prefixIcon: Icon(Icons.person_outline),
        labelText: 'Ad Soyad',
        hintText: 'Ad Soyad',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Lütfen adınızı girin';
        }
        return null;
      },
    );
  }
}
