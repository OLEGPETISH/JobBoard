import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'data/auth_api.dart';
import 'data/mock_application_repository.dart';
import 'data/mock_job_post_repository.dart';
import 'data/token_store.dart';
import 'models/applications_model.dart';
import 'models/jobs_model.dart';
import 'models/saved_jobs_model.dart';
import 'router.dart';


const apiBase = 'http://10.0.2.2:8080';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized(); // prefs до runApp
  final tokens = TokenStore();
  final loggedIn = await tokens.read() != null; // запуск решает по tokenu
  router = createRouter(loggedIn: loggedIn);

  final jobRepository = MockJobPostRepository();
  final applicationRepository = MockApplicationRepository();

  runApp(
    MultiProvider(
      providers: [
        Provider(create: (_) => AuthApi(apiBase, tokens)),
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