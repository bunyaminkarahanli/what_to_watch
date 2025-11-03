import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'What to Watch',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // appbar
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF3F51B5), // senin temadaki ana renk
          foregroundColor: Colors.white, // başlık & ikon rengi
          centerTitle: true,
          elevation: 2,
          titleTextStyle: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        // renk düzeni
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF3F51B5),
          primary: const Color(0xFF3F51B5), // senin mor-mavi tonun
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF8F9FF),
        //yazı tipi ve metin teması
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

        // buton teması
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
    );
  }
}
