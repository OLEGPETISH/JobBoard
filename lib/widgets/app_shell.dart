import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../models/saved_jobs_model.dart';

class AppShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const AppShell({super.key, required this.navigationShell});

  static Widget _savedIcon(IconData icon) => Consumer<SavedJobsModel>(
        builder: (context, saved, child) => Badge(
          isLabelVisible: saved.count > 0,
          label: Text('${saved.count}'),
          child: child!,
        ),
        child: Icon(icon),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: navigationShell.goBranch,
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.work_outline),
            selectedIcon: Icon(Icons.work),
            label: 'Вакансии',
          ),
          NavigationDestination(
            icon: _savedIcon(Icons.bookmark_border),
            selectedIcon: _savedIcon(Icons.bookmark),
            label: 'Избранное',
          ),
          const NavigationDestination(
            icon: Icon(Icons.assignment_outlined),
            selectedIcon: Icon(Icons.assignment),
            label: 'Отклики',
          ),
          const NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Профиль',
          ),
        ],
      ),
    );
  }
}