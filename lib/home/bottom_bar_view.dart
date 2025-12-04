import 'package:flutter/material.dart';
import 'package:what_to_watch/screens/discover/view/discover_view.dart';
import 'package:what_to_watch/screens/profile/view/profile_view.dart';
import 'package:what_to_watch/screens/favorite/view/car_favorite_view.dart';

class BottomBarView extends StatefulWidget {
  const BottomBarView({super.key});

  @override
  State<BottomBarView> createState() => _BottomBarViewState();
}

class _BottomBarViewState extends State<BottomBarView> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    DiscoverView(),
    CarFavoriteView(),
    ProfileView(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.explore), label: 'Keşfet'),
          BottomNavigationBarItem(
            icon: Icon(Icons.bookmark),
            label: 'Favoriler',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }
}
