// footer.dart
import 'package:flutter/material.dart';

class Footer extends StatelessWidget {
  final int currentIndex;
  final void Function(int) onTap;

  const Footer({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.upload), label: 'Upload'),
        BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Profile'),
      ],
    );
  }
}
