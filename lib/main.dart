import 'package:flutter/material.dart';
import 'package:universal_tv_remote/screens/home%20screen/home_screen.dart';

void main() {
  runApp(const UniversalTvRemoteApp());
}

class UniversalTvRemoteApp extends StatelessWidget {
  const UniversalTvRemoteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Universal TV Remote',

      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.indigo,
        ),
        scaffoldBackgroundColor: const Color(0xFFF7F8FC),
      ),

      home: const HomeScreen(),
    );
  }
}