import 'package:flutter/material.dart';
import 'loading_screen2.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ministry of Revenues POS',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Ag', 
        scaffoldBackgroundColor: Colors.white,
      ),
      // The first screen to be displayed is the LoadingScreen
      home: const LoadingScreen(),
      debugShowCheckedModeBanner: false, // This removes the debug banner
    );
  }
}