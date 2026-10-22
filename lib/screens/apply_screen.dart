import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../data/mock_data.dart';

class ApplyScreen extends StatefulWidget {
  final int id;

  const ApplyScreen({super.key, required this.id});

  @override
  State<ApplyScreen> createState() => _ApplyScreenState();
}

class _ApplyScreenState extends State<ApplyScreen> {
  final _formKey = GlobalKey<FormState>();
  final _linkKey = GlobalKey<FormFieldState<String>>();
  final _linkCtrl = TextEditingController();
  final _messageCtrl = TextEditingController();

  static const _minMessageLength = 50;
  String? _attachedFile; 

  @override
  void dispose() {
    _linkCtrl.dispose(); 
    _messageCtrl.dispose();
    super.dispose();
  }

  void _attachFile() {
    setState(() => _attachedFile = 'CV_Student.pdf');
    _linkKey.currentState?.validate(); 
  }

  void _removeFile() {
    setState(() => _attachedFile = null);
  }

  void _submit(JobPost job) {
    if (!_formKey.currentState!.validate()) return; 
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Отклик отправлен: ${job.title}')),
    );
    context.pop(); 
  }

  @override
  Widget build(BuildContext context) {
    final job = mockJobs.firstWhere((j) => j.id == widget.id);
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Отклик на вакансию')),
      body: Form(
        key: _formKey,
        child: ListView(
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
            TextFormField(
              key: _linkKey,
              controller: _linkCtrl,
              keyboardType: TextInputType.url,
              textInputAction: TextInputAction.next,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              decoration: const InputDecoration(
                labelText: 'Ссылка на CV',
                hintText: 'https://drive.google.com/...',
                prefixIcon: Icon(Icons.link),
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                final link = value?.trim() ?? '';
                if (link.isEmpty) {
                  return _attachedFile != null
                      ? null 
                      : 'Укажите ссылку или прикрепите файл';
                }
                final uri = Uri.tryParse(link);
                final valid = uri != null &&
                    (uri.scheme == 'http' || uri.scheme == 'https') &&
                    uri.host.contains('.');
                return valid ? null : 'Введите корректную ссылку (https://...)';
              },
            ),
            const SizedBox(height: 12),
            Center(child: Text('или', style: text.bodyMedium)),
            const SizedBox(height: 12),
            if (_attachedFile == null)
              OutlinedButton.icon(
                onPressed: _attachFile,
                icon: const Icon(Icons.upload_file),
                label: const Text('Прикрепить файл (PDF)'),
              )
            else
              Card(
                child: ListTile(
                  leading: Icon(Icons.description_outlined, color: scheme.primary),
                  title: Text(_attachedFile!),
                  trailing: IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: _removeFile,
                  ),
                ),
              ),
            const SizedBox(height: 24),
            Text('Сопроводительное письмо', style: text.titleMedium),
            const SizedBox(height: 8),
            TextFormField(
              controller: _messageCtrl,
              maxLines: 6,
              keyboardType: TextInputType.multiline,
              decoration: const InputDecoration(
                labelText: 'Расскажите о себе',
                hintText:
                    'Почему вы хотите работать в этой компании и чем можете быть полезны',
                helperText: 'Не менее $_minMessageLength символов',
                alignLabelWithHint: true,
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                final message = value?.trim() ?? '';
                if (message.isEmpty) return 'Напишите сопроводительное письмо';
                if (message.length < _minMessageLength) {
                  return 'Слишком коротко: ${message.length} из $_minMessageLength символов';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => _submit(job),
              icon: const Icon(Icons.send),
              label: const Text('Отправить отклик'),
            ),
          ],
        ),
      ),
    );
  }
}