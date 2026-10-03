import 'package:flutter/material.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Регистрация')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text('Создайте аккаунт', style: text.headlineSmall),
            const SizedBox(height: 4),
            Text(
              'Чтобы откликаться на вакансии и отслеживать статусы',
              style: text.bodyMedium,
            ),
            const SizedBox(height: 24),
            const TextField(
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(
                labelText: 'Имя и фамилия',
                prefixIcon: Icon(Icons.person_outline),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            const TextField(
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: 'E-mail',
                prefixIcon: Icon(Icons.email_outlined),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            DropdownMenu<String>(
              expandedInsets: EdgeInsets.zero,
              label: const Text('Курс'),
              leadingIcon: const Icon(Icons.school_outlined),
              dropdownMenuEntries: const [
                DropdownMenuEntry(value: '1', label: '1 курс'),
                DropdownMenuEntry(value: '2', label: '2 курс'),
                DropdownMenuEntry(value: '3', label: '3 курс'),
                DropdownMenuEntry(value: '4', label: '4 курс'),
                DropdownMenuEntry(value: 'master', label: 'Магистратура'),
              ],
            ),
            const SizedBox(height: 16),
            const TextField(
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Пароль',
                prefixIcon: Icon(Icons.lock_outline),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            const TextField(
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Повторите пароль',
                prefixIcon: Icon(Icons.lock_outline),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
              value: false,
              onChanged: (_) {},
              title: const Text('Согласен с условиями использования'),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () {},
              child: const Text('Зарегистрироваться'),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () {},
              child: const Text('Уже есть аккаунт? Войти'),
            ),
          ],
        ),
      ),
    );
  }
}