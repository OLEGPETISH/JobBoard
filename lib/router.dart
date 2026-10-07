import 'package:go_router/go_router.dart';
import 'screens/application_details_screen.dart';
import 'screens/apply_screen.dart';
import 'screens/auth_screen.dart';
import 'screens/job_details_screen.dart';
import 'screens/jobs_screen.dart';
import 'screens/my_applications_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/register_screen.dart';
import 'screens/saved_jobs_screen.dart';
import 'screens/settings_screen.dart';
import 'widgets/app_shell.dart';

final router = GoRouter(
  initialLocation: '/login',
  routes: [
    GoRoute(
      path: '/login',
      builder: (context, state) => const AuthScreen(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterScreen(),
    ),
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) =>
          AppShell(navigationShell: navigationShell),
      branches: [
        StatefulShellBranch(routes: [
          GoRoute(
            path: '/jobs',
            builder: (context, state) => const JobsScreen(),
            routes: [
              GoRoute(
                path: ':id', 
                builder: (context, state) {
                  final id = int.parse(state.pathParameters['id']!);
                  return JobDetailsScreen(id: id);
                },
                routes: [
                  GoRoute(
                    path: 'apply', 
                    builder: (context, state) {
                      final id = int.parse(state.pathParameters['id']!);
                      return ApplyScreen(id: id);
                    },
                  ),
                ],
              ),
            ],
          ),
        ]),
        
        StatefulShellBranch(routes: [
          GoRoute(
            path: '/saved',
            builder: (context, state) => const SavedJobsScreen(),
          ),
        ]),
        
        StatefulShellBranch(routes: [
          GoRoute(
            path: '/applications',
            builder: (context, state) => const MyApplicationsScreen(),
            routes: [
              GoRoute(
                path: ':id', 
                builder: (context, state) {
                  final id = int.parse(state.pathParameters['id']!);
                  return ApplicationDetailsScreen(id: id);
                },
              ),
            ],
          ),
        ]),
        
        StatefulShellBranch(routes: [
          GoRoute(
            path: '/profile',
            builder: (context, state) => const ProfileScreen(),
            routes: [
              GoRoute(
                path: 'settings', 
                builder: (context, state) => const SettingsScreen(),
              ),
            ],
          ),
        ]),
      ],
    ),
  ],
);