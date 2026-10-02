import 'package:flutter/material.dart';
import '../data/mock_data.dart';
import '../widgets/status_badge.dart';

class MyApplicationsScreen extends StatelessWidget {
  const MyApplicationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Мои отклики')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: mockApplications.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, i) {
          final application = mockApplications[i];
          final job = mockJobs.firstWhere((j) => j.id == application.jobPostId);

          return Card(
            child: ListTile(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              leading: CircleAvatar(
                backgroundColor: scheme.primaryContainer,
                foregroundColor: scheme.onPrimaryContainer,
                child: Text(job.company[0]),
              ),
              title: Text(job.title),
              subtitle: Text('${job.company} · ${application.sentDate}'),
              trailing: StatusBadge(status: application.status),
            ),
          );
        },
      ),
    );
  }
}