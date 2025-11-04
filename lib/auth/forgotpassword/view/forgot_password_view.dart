import 'package:flutter/material.dart';

class ForgotPasswordView extends StatefulWidget {
  const ForgotPasswordView({super.key});

  @override
  State<ForgotPasswordView> createState() => _ForgotPasswordViewState();
}

class _ForgotPasswordViewState extends State<ForgotPasswordView> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              Image.asset('assets/images/onboar2.png', height: 180),
              const SizedBox(height: 30),
              Text("Şifreni mi unuttun?", style: theme.textTheme.headlineLarge),
              const SizedBox(height: 12),
              Text(
                "E-posta adresini gir, sana şifre sıfırlama bağlantısı gönderelim.",
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 40),
              Form(
                key: _formKey,
                child: mailBuild(),
              ),
              const SizedBox(height: 32),
              sendButtonBuild(),
              const SizedBox(height: 16),
              comeBackButtonBuild(context),
            ],
          ),
        ),
      ),
    );
  }

  TextButton comeBackButtonBuild(BuildContext context) {
    return TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Geri Dön"),
            );
  }

  ElevatedButton sendButtonBuild() {
    return ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {}
              },
              child: const Text("Sıfırlama Maili Gönder"),
            );
  }

  TextFormField mailBuild() {
    return TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'E-posta',
                  prefixIcon: const Icon(Icons.email_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Lütfen e-posta adresinizi girin';
                  } else if (!value.contains('@')) {
                    return 'Geçerli bir e-posta girin';
                  }
                  return null;
                },
              );
  }
}
