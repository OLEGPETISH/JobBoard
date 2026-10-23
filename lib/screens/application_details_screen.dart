import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../data/job_application.dart';
import '../models/applications_model.dart';
import '../models/jobs_model.dart';
import '../widgets/error_view.dart';
import '../widgets/info_row.dart';
import '../widgets/status_badge.dart';

class ApplicationDetailsScreen extends StatelessWidget {
  final int id;

  const ApplicationDetailsScreen({super.key, required this.id});

  static const _steps = ['Отправлен', 'Просмотрен', 'Интервью'];

  Future<void> _withdraw(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context); 
    final ok = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Отозвать отклик?'),
        content: const Text('Отклик будет удалён, это действие нельзя отменить.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx, false),
            child: const Text('Нет'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogCtx, true),
            child: const Text('Да, отозвать'),
          ),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;

    final error = await context.read<ApplicationsModel>().remove(id);
    if (!context.mounted) return; 
    if (error != null) {
      messenger.showSnackBar(SnackBar(content: Text(error)));
      return;
    }
    messenger.showSnackBar(const SnackBar(content: Text('Отклик отозван')));
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final applications = context.watch<ApplicationsModel>();
    final jobs = context.watch<JobsModel>();

    final application = applications.byId(id);
    if (application == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Отклик')),
        body: applications.isLoading
            ? const Center(child: CircularProgressIndicator())
            : applications.error != null
                ? ErrorView(
                    message: applications.error!,
                    onRetry: () => context.read<ApplicationsModel>().load(),
                  )
                : Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('Отклик не существует'),
                        const SizedBox(height: 12),
                        FilledButton(
                          onPressed: () => context.go('/applications'),
                          child: const Text('К списку откликов'),
                        ),
                      ],
                    ),
                  ),
      );
    }

    final job = jobs.byId(application.jobPostId); 
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
                child: Text(job?.company[0] ?? '?', style: text.titleLarge),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(job?.title ?? 'Вакансия №${application.jobPostId}',
                        style: text.titleLarge),
                    Text(job?.company ?? '—', style: text.bodyLarge),
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
                    value: job?.salaryRange ?? '—',
                  ),
                  InfoRow(
                    icon: Icons.schedule,
                    label: 'График',
                    value: job?.schedule ?? '—',
                  ),
                  InfoRow(
                    icon: Icons.description_outlined,
                    label: 'CV',
                    value: application.cvUrl, 
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
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: () => _withdraw(context),
            icon: Icon(Icons.delete_outline, color: scheme.error),
            label: Text('Отозвать отклик', style: TextStyle(color: scheme.error)),
          ),
        ],
      ),
    );
  }
}