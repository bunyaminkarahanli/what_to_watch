import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:what_to_watch/auth/signin/view/signin_view.dart';
import 'package:what_to_watch/auth/signout/services/signout_service.dart';
import 'package:what_to_watch/providers/theme_provider.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  final SignoutService _auth = SignoutService();
  final User? _user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            CircleAvatar(
              radius: 100,
              backgroundImage: AssetImage('assets/images/car_profile.png'),
            ),
            const SizedBox(height: 12),
            Text(
              _user?.displayName ?? 'Kullanıcı Adı',
              style: theme.textTheme.headlineMedium,
            ),

            Text(
              _user?.email ?? 'E-posta bulunamadı',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            const Divider(thickness: 1),
            const SizedBox(height: 24),
            _switchProfileItem(themeProvider),
            const SizedBox(height: 30),
            signOutButtonBuild(),
          ],
        ),
      ),
    );
  }

  SwitchListTile _switchProfileItem(dynamic themeProvider) => SwitchListTile(
    value: themeProvider.isDark,
    onChanged: (val) {
      context.read<ThemeProvider>().toggleTheme(val);
    },
    title: const Text('Karanlık Mod'),
  );

  ElevatedButton signOutButtonBuild() {
    return ElevatedButton.icon(
      onPressed: () async {
        try {
          await _auth.signOut();

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Başarıyla çıkış yapıldı.'),
                backgroundColor: Colors.green,
              ),
            );

            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const SigninView()),
              (route) => false,
            );
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(e.toString()),
                backgroundColor: Colors.redAccent,
              ),
            );
          }
        }
      },
      icon: const Icon(Icons.logout),
      label: const Text('Çıkış Yap'),
      style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
    );
  }
}
