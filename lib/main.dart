import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:what_to_watch/app.dart';
import 'package:what_to_watch/auth/local/auth_local_service.dart';
import 'package:what_to_watch/firebase_options.dart';
import 'package:what_to_watch/providers/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  final bool isLoggedIn = await AuthLocalService().isLoggedIn();
  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => ThemeProvider())],
      child: MyApp(isLoggedIn: isLoggedIn),
    ),
  );
}
