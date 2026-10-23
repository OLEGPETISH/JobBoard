import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../models/jobs_model.dart';
import '../widgets/error_view.dart';
import '../widgets/job_card.dart';

class JobsScreen extends StatefulWidget {
  const JobsScreen({super.key});

  @override
  State<JobsScreen> createState() => _JobsScreenState();
}

class _JobsScreenState extends State<JobsScreen> {
  late final TextEditingController _searchCtrl;

  @override
  void initState() {
    super.initState();
    _searchCtrl = TextEditingController(text: context.read<JobsModel>().query);
  }

  @override
  void dispose() {
    _searchCtrl.dispose(); 
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final model = context.watch<JobsModel>(); 
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    final Widget body;
    if (model.isLoading) {
      body = const Center(child: CircularProgressIndicator()); 
    } else if (model.error != null) {
      body = ErrorView(
        message: model.error!, 
        onRetry: () => context.read<JobsModel>().load(), 
      );
    } else {
      final jobs = model.visibleJobs; 
      body = jobs.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.search_off, size: 56, color: scheme.outline),
                    const SizedBox(height: 12),
                    Text('Ничего не найдено', style: text.titleMedium),
                    if (model.hasFilters) ...[
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: () {
                          context.read<JobsModel>().clearFilters();
                          _searchCtrl.clear();
                        },
                        child: const Text('Сбросить фильтры'),
                      ),
                    ],
                  ],
                ),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: jobs.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, i) => JobCard(
                key: ValueKey(jobs[i].id), 
                job: jobs[i],
                onTap: () => context.push('/jobs/${jobs[i].id}'),
              ),
            );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Вакансии')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: SearchBar(
              controller: _searchCtrl,
              hintText: 'Название, компания или технология',
              leading: const Icon(Icons.search),
              onChanged: (value) => context.read<JobsModel>().setQuery(value),
            ),
          ),
          _FilterRow(
            labels: JobsModel.techFilters,
            isSelected: model.isTechSelected,
            onToggle: (label) => context.read<JobsModel>().toggleTech(label),
          ),
          _FilterRow(
            labels: JobsModel.scheduleFilters,
            isSelected: model.isScheduleSelected,
            onToggle: (label) => context.read<JobsModel>().toggleSchedule(label),
          ),
          Expanded(child: body),
        ],
      ),
    );
  }
}

class _FilterRow extends StatelessWidget {
  final List<String> labels;
  final bool Function(String label) isSelected;
  final void Function(String label) onToggle;

  const _FilterRow({
    required this.labels,
    required this.isSelected,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: labels.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) => FilterChip(
          label: Text(labels[i]),
          selected: isSelected(labels[i]),
          onSelected: (_) => onToggle(labels[i]),
        ),
      ),
    );
  }
}