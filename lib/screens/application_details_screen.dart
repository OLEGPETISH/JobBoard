import 'package:flutter/material.dart';
import '../data/mock_data.dart';
import '../widgets/info_row.dart';
import '../widgets/status_badge.dart';

class ApplicationDetailsScreen extends StatelessWidget {
  final int id;

  const ApplicationDetailsScreen({super.key, required this.id});

  static const _steps = ['Отправлен', 'Просмотрен', 'Интервью'];

  @override
  Widget build(BuildContext context) {
    final application = mockApplications.firstWhere((a) => a.id == id);
    final job = mockJobs.firstWhere((j) => j.id == application.jobPostId);
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final rejected = application.status == ApplicationStatus.rejected;

    return Scaffold(
      appBar: AppBar(title: const Text('Отклик')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: scheme.primaryContainer,
                foregroundColor: scheme.onPrimaryContainer,
                child: Text(job.company[0], style: text.titleLarge),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(job.title, style: text.titleLarge),
                    Text(job.company, style: text.bodyLarge),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerLeft,
            child: StatusBadge(status: application.status),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                children: [
                  InfoRow(
                    icon: Icons.event,
                    label: 'Дата отправки',
                    value: application.sentDate,
                  ),
                  InfoRow(
                    icon: Icons.payments_outlined,
                    label: 'Зарплата',
                    value: job.salaryRange,
                  ),
                  InfoRow(
                    icon: Icons.schedule,
                    label: 'График',
                    value: job.schedule,
                  ),
                  const InfoRow(
                    icon: Icons.description_outlined,
                    label: 'CV',
                    value: 'CV_Student.pdf',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text('Этапы', style: text.titleMedium),
          for (var i = 0; i < _steps.length; i++)
            ListTile(
              contentPadding: EdgeInsets.zero,
              dense: true,
              leading: Icon(
                (rejected ? i < 2 : i <= application.status.index)
                    ? Icons.check_circle
                    : Icons.radio_button_unchecked,
                color: scheme.primary,
              ),
              title: Text(_steps[i]),
            ),
          if (rejected)
            ListTile(
              contentPadding: EdgeInsets.zero,
              dense: true,
              leading: Icon(Icons.cancel, color: scheme.error),
              title: const Text('Отказ'),
            ),
          const SizedBox(height: 16),
          Text('Ваше письмо', style: text.titleMedium),
          const SizedBox(height: 8),
          Card(
            color: scheme.surfaceContainerHighest,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(application.message, style: text.bodyMedium),
            ),
          ),
        ],
      ),
    );
  }
}