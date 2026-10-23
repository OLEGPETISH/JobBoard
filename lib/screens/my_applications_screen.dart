import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../models/applications_model.dart';
import '../models/jobs_model.dart';
import '../widgets/error_view.dart';
import '../widgets/status_badge.dart';

class MyApplicationsScreen extends StatelessWidget {
  const MyApplicationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final model = context.watch<ApplicationsModel>(); 
    final jobs = context.watch<JobsModel>(); 

    final Widget body;
    if (model.isLoading) {
      body = const Center(child: CircularProgressIndicator()); 
    } else if (model.error != null) {
      body = ErrorView(
        message: model.error!,
        onRetry: () => context.read<ApplicationsModel>().load(), 
      );
    } else if (model.applications.isEmpty) {
      body = Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.assignment_outlined, size: 64, color: scheme.outline),
              const SizedBox(height: 12),
              Text('Откликов пока нет', style: text.titleMedium),
              const SizedBox(height: 4),
              Text(
                'Откликнитесь на вакансию, и статус появится здесь',
                style: text.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    } else {
      final items = model.applications; 
      body = ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, i) {
          final application = items[i];
          final job = jobs.byId(application.jobPostId); 

          return Card(
            key: ValueKey(application.id), 
            child: ListTile(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              leading: CircleAvatar(
                backgroundColor: scheme.primaryContainer,
                foregroundColor: scheme.onPrimaryContainer,
                child: Text(job?.company[0] ?? '?'),
              ),
              title: Text(job?.title ?? 'Вакансия №${application.jobPostId}'),
              subtitle: Text('${job?.company ?? '—'} · ${application.sentDate}'),
              trailing: StatusBadge(status: application.status),
              onTap: () => context.push('/applications/${application.id}'),
            ),
          );
        },
      );
    }

    return Scaffold(appBar: AppBar(title: const Text('Мои отклики')), body: body);
  }
}