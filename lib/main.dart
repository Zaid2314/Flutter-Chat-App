// In lib/main.dart

import 'package:chat_app/screens/chat.dart';
import 'package:chat_app/screens/splash.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:chat_app/screens/auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FlutterChat',
      theme: ThemeData.from(
        colorScheme: ColorScheme.fromSeed(
          // ✅ Light theme colors for a fresh look
          seedColor: const Color.fromARGB(255, 120, 144, 230), // Lighter purple/blue
          primary: const Color.fromARGB(255, 120, 144, 230), // Primary light blue
          secondary: const Color.fromARGB(255, 207, 216, 220), // Light grey for secondary
          surface: Colors.white, // White background for cards/surfaces
          onPrimary: Colors.white, // Text on primary background
          onSecondary: Colors.black87, // Text on secondary background
          onSurface: Colors.black87, // Text on white background
        ),
        useMaterial3: true,
      ),
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SplashScreen();
          }
          if (snapshot.hasData) {
            return const ChatScreen();
          }
          return const AuthScreen();
        },
      ),
    );
  }
}