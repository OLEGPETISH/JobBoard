import 'package:flutter/material.dart';

void main() => runApp(const JobBoardApp());

class JobBoardApp extends StatelessWidget {
  const JobBoardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'JobBoard',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1565C0), // деловой синий: карьера, работа
        ),
      ),
      home: const Scaffold(body: Center(child: Text('JobBoard'))),
    );
  }
}