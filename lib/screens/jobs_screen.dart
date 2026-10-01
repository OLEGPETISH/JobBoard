import 'package:flutter/material.dart';
import '../data/mock_data.dart';
import '../widgets/job_card.dart';
import 'job_details_screen.dart';

class JobsScreen extends StatelessWidget {
  const JobsScreen({super.key});

  static const _techFilters = ['Flutter', 'Java', 'Python', 'React', 'QA', 'DevOps'];
  static const _scheduleFilters = ['Part-time', 'Стажировка', 'Remote'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Вакансии')),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: SearchBar(
              hintText: 'Название, компания или технология',
              leading: Icon(Icons.search),
            ),
          ),
          const _FilterRow(labels: _techFilters),
          const _FilterRow(labels: _scheduleFilters),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: mockJobs.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, i) => JobCard(
  job: mockJobs[i],
  onTap: () => Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => JobDetailsScreen(job: mockJobs[i]),
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

class _FilterRow extends StatelessWidget {
  final List<String> labels;
  const _FilterRow({required this.labels});

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
          selected: false,
          onSelected: (_) {},
        ),
      ),
    );
  }
}