import 'package:flutter/material.dart';
import 'presentation/screens/landingScreen.dart';
import 'presentation/screens/loginScreen.dart';
import 'presentation/screens/homeScreen.dart';
import 'package:provider/provider.dart';

import './providers/loginProvider.dart';
import './providers/themeProvider.dart';
import './providers/documentProvider.dart';
import './utils/globalKeys.dart'; // 👈 Import the global key

import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LoginProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => DocumentsProvider()),
      ],
      child: ScholarSnap(),
    ),
  );
}

class ScholarSnap extends StatelessWidget {
  const ScholarSnap({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Scholar-Snap',
      navigatorKey: navigatorKey, // 👈 Use global navigatorKey here
      initialRoute: '/',
      routes: {
        '/': (context) => const LandingScreen(),
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreen()
      },
    );
  }
}
