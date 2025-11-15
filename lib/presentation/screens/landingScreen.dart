import 'package:flutter/material.dart';
import '../widgets/header.dart';
import '../widgets/highlightedButton.dart';
import '../../constant.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Header(value: 'ScholarSnap',),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 40),
            // Heading
            Center(
              child: Text(
                "Understand More, Read Less",
                textAlign: TextAlign.center,
                style: Styles.boldText
              ),
            ),
            const SizedBox(height: 20),
            Highlightedbutton(value: 'Get Started', 
            onPressed: () {
              Navigator.pushNamed(context, '/login');
            })
          ],
        ),
      ),
    );
  }
}
