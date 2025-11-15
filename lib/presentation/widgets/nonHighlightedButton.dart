import 'package:flutter/material.dart';
import '../../constant.dart';

class Highlightedbutton extends StatelessWidget {
  final String value;
  const Highlightedbutton({super.key, required this.value});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {},
      style: Styles.highlightedButtonStyle,
      child: Text(
        value,
        style: Styles.buttonText
      ),
    );
  }
}
