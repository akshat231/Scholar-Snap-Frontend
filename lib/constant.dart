import 'package:flutter/material.dart';

class Styles {
  static final highlightedButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: const Color(0xFFE3EAF4),
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    elevation: 0,
  );

  static final buttonText = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: Colors.black,
    letterSpacing: 0.2,
  );

  static final nonHighlightedButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: const Color(0x00e9edf1),
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    elevation: 0,
  );

  static final boldText = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w800,
    letterSpacing: 0.3,
  );

  static final normalText = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.3,
  );
}
