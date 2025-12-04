import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart'; // ✅ EKLENDİ

import 'package:what_to_watch/home/bottom_bar_view.dart';
import 'package:what_to_watch/onboarding/view/car_onboarding_view.dart';
import 'package:what_to_watch/providers/theme_provider.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key}); // ✅ isLoggedIn parametresi KALDIRILDI

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    return MaterialApp(
      title: 'What to Watch',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF3F51B5),
          foregroundColor: Colors.white,
          centerTitle: true,
          elevation: 2,
          titleTextStyle: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF3F51B5),
          primary: const Color(0xFF3F51B5),
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF8F9FF),
        textTheme: GoogleFonts.outfitTextTheme().copyWith(
          headlineLarge: const TextStyle(
            fontSize: 45,
            fontWeight: FontWeight.w700,
            color: Color(0xFF3F51B5),
            letterSpacing: 0.5,
          ),
          titleMedium: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
          bodyMedium: const TextStyle(
            fontSize: 16,
            color: Colors.black54,
            height: 1.5,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF3F51B5),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            textStyle: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1E1E2C),
          foregroundColor: Colors.white,
          centerTitle: true,
          elevation: 0,
          titleTextStyle: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF3F51B5),
          brightness: Brightness.dark,
          primary: const Color(0xFF3F51B5),
          secondary: Colors.deepPurpleAccent,
        ),
        scaffoldBackgroundColor: const Color(0xFF121212),
        textTheme: GoogleFonts.outfitTextTheme().copyWith(
          headlineLarge: const TextStyle(
            fontSize: 45,
            fontWeight: FontWeight.w700,
            color: Color(0xFFD1D5FF),
            letterSpacing: 0.5,
          ),
          titleMedium: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
          bodyMedium: const TextStyle(
            fontSize: 16,
            color: Colors.white70,
            height: 1.5,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF3F51B5),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            textStyle: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
      themeMode: themeProvider.isDark ? ThemeMode.dark : ThemeMode.light,

      // ✅ ESKİ: home: CarOnboardingView(),
      // ✅ YENİ:
      home: const RootController(),
    );
  }
}

/// ✅ Firebase durumuna göre hangi ekranın açılacağını belirleyen widget
class RootController extends StatelessWidget {
  const RootController({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Firebase dinlenirken loading göstermek için
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Kullanıcı giriş yapmışsa → direkt ana sayfa
        if (snapshot.hasData) {
          return const BottomBarView();
        }

        // Kullanıcı giriş yapmamışsa → onboarding göster
        return const CarOnboardingView();
      },
    );
  }
}
