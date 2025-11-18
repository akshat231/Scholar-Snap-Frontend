import 'package:flutter/material.dart';
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
  LoginScreen({super.key});

  // Backend config text fields
  final TextEditingController hostController =
      TextEditingController(text: ServerConfig.backendServer['host']);
  final TextEditingController portController =
      TextEditingController(text: ServerConfig.backendServer['port'].toString());
  final TextEditingController protocolController =
      TextEditingController(text: ServerConfig.backendServer['protocol']);

  // ------------------------------------
  // BACKEND LOGIN WITH FIXED DUMMY DATA
  // ------------------------------------
  Future<void> loginWithDummyBackend(BuildContext context) async {
    final url = ServerConfig.demoLoginApiUrl;

    logger.i("Hitting backend login URL: $url");

    final Map<String, dynamic> dummyPayload = {
      "email": "demo@example.com",
      "name": "demo"
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(dummyPayload),
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        final userData = Map<String, dynamic>.from(body['data']);

        logger.i("Login successful: $userData");

        Provider.of<LoginProvider>(context, listen: false).setUser(userData);

        final themeString = userData["theme"] ?? "light";
        final themeMode =
            themeString == "dark" ? ThemeMode.dark : ThemeMode.light;

        Provider.of<ThemeProvider>(context, listen: false)
            .setThemeMode(themeMode);

        Provider.of<DocumentsProvider>(context, listen: false)
            .connectSocket(userData['id'].toString());

        Navigator.of(context)
            .pushNamedAndRemoveUntil('/home', (route) => false);
      } else {
        logger.e(
            "Backend login failed: ${response.statusCode} ${response.body}");
      }
    } catch (e) {
      logger.e("Backend login error: $e");
    }
  }

  // ------------------------------------
  // UPDATE BACKEND SERVER CONFIG
  // ------------------------------------
  void updateServerConfig() {
    final host = hostController.text.trim();
    final port = int.tryParse(portController.text.trim()) ?? 5000;
    final protocol = protocolController.text.trim().toLowerCase();

    ServerConfig.updateBackendServer(host, port, protocol);

    logger.i("Updated backend config → $protocol://$host:$port");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Header(value: 'ScholarSnap'),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 20),

              // -------------------------------
              // BACKEND SERVER CONFIG FIELDS
              // -------------------------------
              Text("Backend Server Config", style: Styles.boldText),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    TextField(
                      controller: hostController,
                      decoration: const InputDecoration(
                        labelText: "Host",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),

                    TextField(
                      controller: portController,
                      decoration: const InputDecoration(
                        labelText: "Port",
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 12),

                    TextField(
                      controller: protocolController,
                      decoration: const InputDecoration(
                        labelText: "Protocol (http / https)",
                        border: OutlineInputBorder(),
                      ),
                    ),

                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: updateServerConfig,
                      child: const Text("Update Backend Config"),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // -------------------------------
              // LOGIN SECTION
              // -------------------------------
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
                  "Unlock the full potential of your research",
                  textAlign: TextAlign.center,
                  style: Styles.normalText,
                ),
              ),

              const SizedBox(height: 20),

              Highlightedbutton(
                value: "🚀 Enter Demo App (Backend Login)",
                onPressed: () async {
                  await loginWithDummyBackend(context);
                },
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
