import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  static const _subscribedTech = ['Flutter', 'Java', 'QA'];
  static const _otherTech = ['Python', 'React', 'DevOps'];

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Настройки')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Оповещения о вакансиях', style: text.titleMedium),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  secondary: const Icon(Icons.notifications_active_outlined),
                  title: const Text('Новые вакансии по фильтру'),
                  subtitle: const Text('Сообщать, когда появится подходящая вакансия'),
                  value: true,
                  onChanged: (_) {},
                ),
                const Divider(height: 1),
                SwitchListTile(
                  secondary: const Icon(Icons.update),
                  title: const Text('Статус отклика'),
                  subtitle: const Text('Просмотрен, приглашение на интервью, отказ'),
                  value: true,
                  onChanged: (_) {},
                ),
                const Divider(height: 1),
                SwitchListTile(
                  secondary: const Icon(Icons.email_outlined),
                  title: const Text('Дублировать на почту'),
                  value: false,
                  onChanged: (_) {},
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text('Мои технологии', style: text.titleMedium),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              for (final tech in _subscribedTech)
                FilterChip(
                  label: Text(tech),
                  selected: true,
                  onSelected: (_) {},
                ),
              for (final tech in _otherTech)
                FilterChip(
                  label: Text(tech),
                  selected: false,
                  onSelected: (_) {},
                ),
            ],
          ),
          const SizedBox(height: 24),
          Text('График', style: text.titleMedium),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              FilterChip(label: const Text('Part-time'), selected: true, onSelected: (_) {}),
              FilterChip(label: const Text('Стажировка'), selected: true, onSelected: (_) {}),
              FilterChip(label: const Text('Remote'), selected: false, onSelected: (_) {}),
            ],
          ),
          const SizedBox(height: 24),
          Text('Как часто присылать', style: text.titleMedium),
          const SizedBox(height: 8),
          DropdownMenu<String>(
            expandedInsets: EdgeInsets.zero,
            initialSelection: 'daily',
            dropdownMenuEntries: const [
              DropdownMenuEntry(value: 'instant', label: 'Сразу'),
              DropdownMenuEntry(value: 'daily', label: 'Раз в день'),
              DropdownMenuEntry(value: 'weekly', label: 'Раз в неделю'),
            ],
          ),
          const SizedBox(height: 24),
          Card(
            child: ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('О приложении'),
              subtitle: const Text('JobBoard · версия 1.0.0'),
              onTap: () {},
            ),
          ),
        ],
      ),
    );
  }
}