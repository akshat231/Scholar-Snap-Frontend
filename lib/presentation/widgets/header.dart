import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/themeProvider.dart';

class Header extends StatelessWidget implements PreferredSizeWidget {
  final String value;
  final PreferredSizeWidget? bottom;

  const Header({
    super.key,
    required this.value,
    this.bottom,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    final backgroundColor =
        isDark ? const Color(0xFF000000) : const Color(0xFFFFFFFF);
    final textColor =
        isDark ? const Color(0xFFFFFFFF) : const Color(0xDE000000);

    return AppBar(
      backgroundColor: backgroundColor,
      iconTheme: IconThemeData(color: textColor),
      title: Text(
        value,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.2,
          color: textColor,
        ),
      ),
      centerTitle: true,
      bottom: bottom, // <-- now supports TabBar, etc.
    );
  }

  @override
  Size get preferredSize {
    final bottomHeight = bottom?.preferredSize.height ?? 0;
    return Size.fromHeight(kToolbarHeight + bottomHeight);
  }
}

