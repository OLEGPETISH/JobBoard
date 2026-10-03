import 'package:flutter/material.dart';
import '../data/mock_data.dart';
import '../widgets/job_card.dart';
import 'job_details_screen.dart';

class SavedJobsScreen extends StatelessWidget {
  const SavedJobsScreen({super.key});

  // Идентификаторы вакансий, сохранённых пользователем (данные только для этого экрана)
  static const _savedIds = [1, 3, 4, 6, 7, 8];

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final saved = mockJobs.where((j) => _savedIds.contains(j.id)).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Избранное')),
      body: Column(
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
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => JobDetailsScreen(job: saved[i]),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}