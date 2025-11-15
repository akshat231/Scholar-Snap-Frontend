// home_screen.dart
import 'package:flutter/material.dart';
import './libraryScreen.dart';
import './uploadPDFScreen.dart';
import './profileScreen.dart';
import '../widgets/footer.dart'; // adjust path if needed

class HomeScreen extends StatefulWidget {

  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int currentIndex = 0;


  List<Widget> get pages => [
        LibraryScreen(),
        UploadPDFScreen(),
        ProfileScreen(),
      ];

  void onTabTapped(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[currentIndex],
    bottomNavigationBar: Footer(
        currentIndex: currentIndex,
        onTap: onTabTapped,
      ),
    );
  }
}
