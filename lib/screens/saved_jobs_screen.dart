import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../data/mock_data.dart';
import '../models/saved_jobs_model.dart';
import '../widgets/job_card.dart';

class SavedJobsScreen extends StatelessWidget {
  const SavedJobsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final savedIds = context.watch<SavedJobsModel>().ids; // watch в build
    final saved = mockJobs.where((j) => savedIds.contains(j.id)).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Избранное')),
      body: saved.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.bookmark_border, size: 64, color: scheme.outline),
                    const SizedBox(height: 12),
                    Text('Пока ничего не сохранено', style: text.titleMedium),
                    const SizedBox(height: 4),
                    Text(
                      'Нажмите на закладку в карточке вакансии',
                      style: text.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: Text(
                    'Сохранено вакансий: ${saved.length}',
                    style: text.titleMedium,
                  ),
                ),
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: saved.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, i) => JobCard(
                      job: saved[i],
                      onTap: () => context.go('/jobs/${saved[i].id}'),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}