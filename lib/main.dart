import 'package:flutter/material.dart';
import 'router.dart';

void main() => runApp(const JobBoardApp());

class JobBoardApp extends StatelessWidget {
  const JobBoardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'JobBoard',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1565C0), 
        ),
      ),
      routerConfig: router,
    );
  }
}