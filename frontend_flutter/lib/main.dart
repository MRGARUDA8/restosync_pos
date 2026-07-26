import 'dart:io'; // Network SSL Overrides ke liye
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme.dart';
import 'screens/login_screen.dart';

// Android Release APK mein network request block hone se bachane ke liye
class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

void main() {
  // Global network override set karein
  HttpOverrides.global = MyHttpOverrides();

  runApp(const ProviderScope(child: RestoSyncApp()));
}

class RestoSyncApp extends StatelessWidget {
  const RestoSyncApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RestoSync POS',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark,
      home: const LoginScreen(),
    );
  }
}
