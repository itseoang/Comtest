import 'package:flutter/material.dart';

class NatureBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const NatureBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.white,
      selectedItemColor: const Color(0xFF2E7D32),
      unselectedItemColor: const Color(0xFF9E9E9E),
      selectedFontSize: 12,
      unselectedFontSize: 12,
      selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
      elevation: 8,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.collections_bookmark_outlined),
          activeIcon: Icon(Icons.collections_bookmark),
          label: '도감',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.camera_alt_outlined),
          activeIcon: Icon(Icons.camera_alt),
          label: '발견',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.auto_stories_outlined),
          activeIcon: Icon(Icons.auto_stories),
          label: '일기',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.people_outlined),
          activeIcon: Icon(Icons.people),
          label: '친구',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outlined),
          activeIcon: Icon(Icons.person),
          label: '나',
        ),
      ],
    );
  }
}
