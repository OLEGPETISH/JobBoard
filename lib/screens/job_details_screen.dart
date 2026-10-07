import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../data/mock_data.dart';
import '../widgets/info_row.dart';

class JobDetailsScreen extends StatelessWidget {
  final int id;

  const JobDetailsScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    final job = mockJobs.firstWhere((j) => j.id == id);
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Вакансия'),
        actions: [
          IconButton(
            icon: const Icon(Icons.bookmark_border),
            onPressed: () {},
          ),
        ],
      ),
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
                    Text(job.title, style: text.headlineSmall),
                    Text(job.company, style: text.bodyLarge),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                children: [
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
                  InfoRow(
                    icon: Icons.place_outlined,
                    label: 'Формат',
                    value: job.location,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text('Технологии', style: text.titleMedium),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [for (final tech in job.techStack) Chip(label: Text(tech))],
          ),
          const SizedBox(height: 16),
          Text('О вакансии', style: text.titleMedium),
          const SizedBox(height: 8),
          Text(job.description, style: text.bodyMedium),
          const SizedBox(height: 16),
          Text('Требования', style: text.titleMedium),
          for (final r in job.requirements)
            ListTile(
              contentPadding: EdgeInsets.zero,
              dense: true,
              leading: Icon(Icons.check_circle_outline, color: scheme.primary),
              title: Text(r),
            ),
        ],
      ),
            bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: FilledButton(
            onPressed: () => context.push('/jobs/$id/apply'),
            child: const Text('Откликнуться'),
          ),
        ),
      ),
    );
  }
}