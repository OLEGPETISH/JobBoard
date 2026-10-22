import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'models/saved_jobs_model.dart';
import 'router.dart';

void main() => runApp(
      ChangeNotifierProvider(
        create: (_) => SavedJobsModel(), // фабрика: Provider создаёт лениво и сам делает dispose
        child: const JobBoardApp(),
      ),
    );

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
          seedColor: const Color(0xFF1565C0), // деловой синий: карьера, работа
        ),
      ),
      routerConfig: router,
    );
  }
}