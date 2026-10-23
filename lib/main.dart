import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'data/mock_application_repository.dart';
import 'data/mock_job_post_repository.dart';
import 'models/applications_model.dart';
import 'models/jobs_model.dart';
import 'models/saved_jobs_model.dart';
import 'router.dart';

void main() {
  final jobRepository = MockJobPostRepository(); 
  final applicationRepository = MockApplicationRepository();

  runApp(
    MultiProvider(
      providers: [
        Provider<MockJobPostRepository>.value(value: jobRepository),
        Provider<MockApplicationRepository>.value(value: applicationRepository),
        ChangeNotifierProvider(
          create: (_) => JobsModel(jobRepository)..load(), 
        ),
        ChangeNotifierProvider(
          create: (_) => ApplicationsModel(applicationRepository)..load(),
        ),
        ChangeNotifierProvider(create: (_) => SavedJobsModel()),
      ],
      child: const JobBoardApp(),
    ),
  );
}

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