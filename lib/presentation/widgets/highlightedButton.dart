import 'package:flutter/material.dart';
import '../../constant.dart';

class Highlightedbutton extends StatelessWidget {
  final String value;
  final VoidCallback? onPressed;
  const Highlightedbutton({super.key, required this.value, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: Styles.highlightedButtonStyle,
      child: Text(
        value,
        style: Styles.buttonText
      ),
    );
  }
}
