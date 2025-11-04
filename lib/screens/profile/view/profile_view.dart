import 'package:flutter/material.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
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
            const Divider(),
            ListTile(),
            ListTile(),
            ListTile(),
            ListTile(),

            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.logout),
              label: const Text('Çıkış Yap'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
