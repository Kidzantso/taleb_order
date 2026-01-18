import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'pages/auth/login_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // ✅ Riverpod import

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await dotenv.load(fileName: ".env");

  // Initialize Firebase
  await Firebase.initializeApp();

  // Initialize Supabase
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  // ✅ Wrap app in ProviderScope for Riverpod
  runApp(const ProviderScope(child: MyApp()));
}

final ThemeData appTheme = ThemeData(
  colorScheme: const ColorScheme.light(
    primary: Color(0xFFFF0022), // Bold Red
    secondary: Color(0xFFb9bab8), // Neutral Gray
    surface: Color(0xFFf8e9f2), // Light Pinkish
    onPrimary: Color(0xFF04030f), // Dark Text
  ),
  scaffoldBackgroundColor: const Color(0xFFedfdfb), // Soft White
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
  textTheme: const TextTheme(
    titleLarge: TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.bold,
      color: Color(0xFF04030f),
    ),
    bodyMedium: TextStyle(fontSize: 16, color: Color(0xFF04030f)),
  ),
  cardTheme: CardThemeData(
    color: Colors.white,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    elevation: 4,
    shadowColor: Colors.black26,
  ),
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Taleb Order',
      theme: appTheme,
      home: const LoginPage(), // ✅ Start with LoginPage
    );
  }
}
