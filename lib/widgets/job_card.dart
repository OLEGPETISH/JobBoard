import 'package:flutter/material.dart';
import '../data/mock_data.dart';

class JobCard extends StatelessWidget {
  final JobPost job;
  final VoidCallback? onTap;

  const JobCard({super.key, required this.job, this.onTap});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: scheme.primaryContainer,
                    foregroundColor: scheme.onPrimaryContainer,
                    child: Text(job.company[0]),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(job.title, style: text.titleMedium),
                        Text(job.company, style: text.bodyMedium),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  for (final tech in job.techStack)
                    Chip(
                      label: Text(tech),
                      visualDensity: VisualDensity.compact,
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.schedule, size: 18, color: scheme.primary),
                  const SizedBox(width: 4),
                  Expanded(child: Text(job.schedule)),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.payments_outlined, size: 18, color: scheme.primary),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(job.salaryRange, style: text.titleSmall),
                  ),
                  Icon(Icons.place_outlined, size: 18, color: scheme.primary),
                  const SizedBox(width: 4),
                  Text(job.location.split(' ').first),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}