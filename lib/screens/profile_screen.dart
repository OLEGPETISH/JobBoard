import 'package:flutter/material.dart';
import '../widgets/info_row.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  // Данные профиля используются только на этом экране
  static const _name = 'Олег Петиш';
  static const _email = 'oleg.petis@isa.utm.md';
  static const _skills = [
    'Dart',
    'Flutter',
    'Java',
    'SQL',
    'Git',
    'Postman',
    'Figma',
  ];

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Профиль')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Column(
            children: [
              CircleAvatar(
                radius: 44,
                backgroundColor: scheme.primaryContainer,
                foregroundColor: scheme.onPrimaryContainer,
                child: Text(_name[0], style: text.headlineMedium),
              ),
              const SizedBox(height: 12),
              Text(_name, style: text.headlineSmall),
              Text(_email, style: text.bodyMedium),
            ],
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                children: const [
                  InfoRow(
                    icon: Icons.school_outlined,
                    label: 'Факультет',
                    value: 'FCIM, UTM',
                  ),
                  InfoRow(
                    icon: Icons.code,
                    label: 'Специальность',
                    value: 'Software Engineering',
                  ),
                  InfoRow(
                    icon: Icons.calendar_today_outlined,
                    label: 'Курс',
                    value: '3 курс',
                  ),
                  InfoRow(
                    icon: Icons.language,
                    label: 'Языки',
                    value: 'Русский, English B2',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: Text('Навыки', style: text.titleMedium)),
              TextButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.add),
                label: const Text('Добавить'),
              ),
            ],
          ),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [for (final skill in _skills) Chip(label: Text(skill))],
          ),
          const SizedBox(height: 16),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.description_outlined),
                  title: const Text('Моё CV'),
                  subtitle: const Text('CV_Student.pdf'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {},
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.bookmark_border),
                  title: const Text('Избранные вакансии'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {},
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.settings_outlined),
                  title: const Text('Настройки'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {},
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.edit_outlined),
            label: const Text('Редактировать профиль'),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () {},
            child: Text('Выйти', style: TextStyle(color: scheme.error)),
          ),
        ],
      ),
    );
  }
}