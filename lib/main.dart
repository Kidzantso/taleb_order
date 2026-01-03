import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'pages/auth/login_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

final ThemeData appTheme = ThemeData(
  primaryColor: const Color(0xFFFF0022), // Bold Red
  scaffoldBackgroundColor: const Color(0xFFedfdfb), // Soft White
  colorScheme: ColorScheme.light(
    primary: const Color(0xFFFF0022),
    secondary: const Color(0xFFb9bab8), // Neutral Gray
    surface: const Color(0xFFf8e9f2), // Light Pinkish
    onPrimary: const Color(0xFF04030f), // Dark Text
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFFFF0022),
      foregroundColor: const Color(0xFFedfdfb),
      textStyle: const TextStyle(fontWeight: FontWeight.bold),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
  ),
  inputDecorationTheme: const InputDecorationTheme(
    border: OutlineInputBorder(),
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Color(0xFFFF0022), width: 2),
    ),
    labelStyle: TextStyle(color: Color(0xFF04030f)),
  ),
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Food Ordering App',
      theme: appTheme,
      home: LoginPage(), // Start with LoginPage
    );
  }
}
