import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:logger/logger.dart';
import 'package:http/http.dart' as http;
import 'package:scholar_snap_frontend/utils/serverConfig.dart';
import '../widgets/header.dart';
import '../../constant.dart';
import '../widgets/highlightedButton.dart';
import '../../providers/loginProvider.dart';
import '../../providers/themeProvider.dart';
import '../../providers/documentProvider.dart';
import 'dart:convert';

final logger = Logger();

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  Future<void> signInWithGoogle(BuildContext context) async {
    final googleSignIn = GoogleSignIn.instance;

    // Initialize with your config
    await googleSignIn.initialize(serverClientId: ServerConfig.googleClientId);

    try {
      final account = await googleSignIn.authenticate(
        scopeHint: ['email', 'profile', 'openid'],
      );
      logger.i("Signed in account is $account");
      final url = ServerConfig.loginApiUrl;

      logger.i('Login url is: $url');
      logger.i('token is: ${account.authentication.idToken}');
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'id_token': account.authentication.idToken}),
      );
      if (response.statusCode == 200) {
        // Assuming response has a session token or user info
        final data = jsonDecode(response.body);

        logger.i("Login success: $data");

        //Storing data in state
        final userData = Map<String, dynamic>.from(data['data']);
        Provider.of<LoginProvider>(context, listen: false).setUser(userData);
        ThemeMode mode;
        final String themeStr = userData['theme'] ?? 'light';
        if (themeStr == 'dark') {
          mode = ThemeMode.dark;
        } else if (themeStr == 'light') {
          mode = ThemeMode.light;
        } else {
          mode = ThemeMode.light;
        }
        Provider.of<ThemeProvider>(context, listen: false).setThemeMode(mode);
        final documentsProvider = Provider.of<DocumentsProvider>(
          context,
          listen: false,
        );
        documentsProvider.connectSocket(userData['id'].toString()); // 👈 Connect WebSocket

        final navigator = Navigator.of(context); // capture before async gap

        // Navigate to dashboard
        navigator.pushNamedAndRemoveUntil('/home', (route) => false);
      } else {
        logger.e("Login failed: ${response.statusCode} ${response.body}");
        // Show error to user
      }
    } catch (e) {
      logger.e("Google Sign In failed: $e");
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Header(value: 'ScholarSnap'),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 40),
            Center(
              child: Text(
                "Welcome to ScholarSnap",
                textAlign: TextAlign.center,
                style: Styles.boldText,
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: Text(
                "Unlock the full potential of your research with ScholarSnap",
                textAlign: TextAlign.center,
                style: Styles.normalText,
              ),
            ),
            const SizedBox(height: 20),
            Highlightedbutton(
              value: 'G  Login With Google',
              onPressed: () async {
                await signInWithGoogle(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
