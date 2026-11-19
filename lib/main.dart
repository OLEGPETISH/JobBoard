import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'data/api_client.dart';
import 'data/auth_api.dart';
import 'data/http_application_repository.dart';
import 'data/http_job_post_repository.dart';
import 'data/token_store.dart';
import 'models/applications_model.dart';
import 'models/jobs_model.dart';
import 'models/saved_jobs_model.dart';
import 'router.dart';
import 'data/file_api.dart';

const apiBase = 'http://10.0.2.2:8080';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized(); // prefs до runApp
  final tokens = TokenStore();
  final loggedIn = await tokens.read() != null; // запуск решает по token-у
  router = createRouter(loggedIn: loggedIn);

  final api = ApiClient(
    apiBase,
    tokens,
    onUnauthorized: () => router.go('/login'), // 401 -> login, в одном месте
  );
  final jobRepository = HttpJobPostRepository(api);
  final applicationRepository = HttpApplicationRepository(api);

  runApp(
    MultiProvider(
      providers: [
        Provider(create: (_) => FileApi(api)),
        Provider(create: (_) => AuthApi(apiBase, tokens)),
        ChangeNotifierProvider(
          create: (_) {
            final model = JobsModel(jobRepository);
            if (loggedIn) model.load(); // без token-а грузить нечего: ждём вход
            return model;
          },
        ),
        ChangeNotifierProvider(
          create: (_) {
            final model = ApplicationsModel(applicationRepository);
            if (loggedIn) model.load();
            return model;
          },
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