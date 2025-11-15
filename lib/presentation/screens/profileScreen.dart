import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:scholar_snap_frontend/utils/serverConfig.dart';
import 'package:logger/logger.dart';
import '../widgets/header.dart';
import '../../constant.dart';
import '../../providers/loginProvider.dart';
import '../../providers/themeProvider.dart';

final logger = Logger();

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<LoginProvider>(context).user;
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;

    // Theme-aware colors
    final borderColor = isDark
        ? const Color(0xFF555555)
        : const Color(0xFFD6D6D6);
    final iconColor = isDark
        ? const Color(0xFFFFFFFF)
        : const Color(0xFF000000);
    final textColor = isDark
        ? const Color(0xFFFFFFFF)
        : const Color(0xFF000000);
    final subtitleColor = isDark
        ? const Color(0xB3FFFFFF)
        : const Color(0x8A000000); // white70 / black54

    Future<void> toggleTheme(id, theme) async {
      try {
        final url = ServerConfig.toggleThemeUrl;
        await http.post(
          Uri.parse(url),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'id': id, 'theme': theme}),
        );
        logger.i('successfully updated theme to $theme for email $id');
      } catch (e) {
        logger.e("Google Sign In failed: $e");
        rethrow;
      }
    }

    return Scaffold(
      appBar: Header(value: 'Profile'),
      backgroundColor: isDark
          ? const Color(0xFF121212)
          : const Color(0xFFFFFFFF),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Profile
            CircleAvatar(
              radius: 50,
              backgroundImage: (user?['picture']?.isNotEmpty ?? false)
                  ? NetworkImage(user!['picture']!)
                  : const AssetImage('assets/silhoutte.avif') as ImageProvider,
            ),

            const SizedBox(height: 12),
            Text(
              user?['name'] ?? 'Unknown User',
              style: Styles.boldText.copyWith(color: textColor),
            ),
            Text(
              user?['email'] ?? 'email@notdefined.com',
              style: Styles.normalText.copyWith(color: subtitleColor),
            ),
            const SizedBox(height: 30),

            // Logout Button
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  border: Border.all(color: borderColor),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.logout, color: iconColor),
              ),
              title: Text(
                "Logout",
                style: Styles.normalText.copyWith(color: textColor),
              ),
              onTap: () async {
                final navigator = Navigator.of(
                  context,
                ); // capture before async gap
                try {
                  await GoogleSignIn.instance.signOut();
                  Provider.of<LoginProvider>(
                    context,
                    listen: false,
                  ).clearUser();

                  navigator.pushNamedAndRemoveUntil('/login', (route) => false);
                } catch (e) {
                  logger.e("Logout failed: $e");
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Logout failed. Please try again."),
                    ),
                  );
                }
              },
            ),
            const Divider(),

            // Theme Toggle
            SwitchListTile(
              title: Text(
                "Theme",
                style: Styles.boldText.copyWith(color: textColor),
              ),
              subtitle: Text(
                isDark ? "Dark" : "Light",
                style: Styles.normalText.copyWith(color: subtitleColor),
              ),
              value: isDark,
              onChanged: (value) async{
                Provider.of<ThemeProvider>(
                  context,
                  listen: false,
                ).toggleTheme(value);
                final themeValue = value ? 'dark': 'light';
                await toggleTheme(user?['id'], themeValue);
              },
            ),
          ],
        ),
      ),
    );
  }
}
