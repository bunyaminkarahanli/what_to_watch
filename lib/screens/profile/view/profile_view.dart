import 'package:flutter/material.dart';
import 'package:what_to_watch/auth/signin/view/signin_view.dart';
import 'package:what_to_watch/auth/signout/services/signout_service.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  final SignoutService _auth = SignoutService();
  @override
  Widget build(BuildContext context) {
    //final user = authService.firebaseAuth.currentUser;
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
              backgroundImage: AssetImage('assets/images/gamer.png'),
            ),
            const SizedBox(height: 12),
            Text(
              //user?.displayName ??
              'Kullanıcı Adı',
              style: theme.textTheme.headlineMedium,
            ),

            Text(
              //user?.email ??
              'E-posta bulunamadı',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            const Divider(thickness: 1),
            const SizedBox(height: 24),
            _profileItem(Icons.person, 'Hesap Bilgileri', () {}),
            const SizedBox(height: 30),
            signOutButtonBuild(),
          ],
        ),
      ),
    );
  }

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

  _profileItem(IconData icon, String text, VoidCallback onTap) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Icon(icon, size: 28, color: theme.colorScheme.primary),
            const SizedBox(width: 16),
            Text(text, style: theme.textTheme.bodyLarge),
          ],
        ),
      ),
    );
  }
}
