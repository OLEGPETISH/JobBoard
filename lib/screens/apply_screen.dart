import 'package:flutter/material.dart';
import '../data/mock_data.dart';

class ApplyScreen extends StatelessWidget {
  final int id;

  const ApplyScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    final job = mockJobs.firstWhere((j) => j.id == id);
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Отклик на вакансию')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            color: scheme.surfaceContainerHighest,
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: scheme.primaryContainer,
                foregroundColor: scheme.onPrimaryContainer,
                child: Text(job.company[0]),
              ),
              title: Text(job.title),
              subtitle: Text('${job.company} · ${job.salaryRange}'),
            ),
          ),
          const SizedBox(height: 24),
          Text('Ваше CV', style: text.titleMedium),
          const SizedBox(height: 8),
          const TextField(
            keyboardType: TextInputType.url,
            decoration: InputDecoration(
              labelText: 'Ссылка на CV',
              hintText: 'https://drive.google.com/...',
              prefixIcon: Icon(Icons.link),
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          Center(child: Text('или', style: text.bodyMedium)),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.upload_file),
            label: const Text('Прикрепить файл (PDF)'),
          ),
          const SizedBox(height: 24),
          Text('Сопроводительное письмо', style: text.titleMedium),
          const SizedBox(height: 8),
          const TextField(
            maxLines: 6,
            keyboardType: TextInputType.multiline,
            decoration: InputDecoration(
              labelText: 'Расскажите о себе',
              hintText: 'Почему вы хотите работать в этой компании и чем можете быть полезны',
              helperText: 'Не менее 100 символов',
              alignLabelWithHint: true,
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.send),
            label: const Text('Отправить отклик'),
          ),
        ],
      ),
    );
  }
}