import 'package:flutter/material.dart';

class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: scheme.primaryContainer,
                  foregroundColor: scheme.onPrimaryContainer,
                  child: const Icon(Icons.work_outline, size: 40),
                ),
                const SizedBox(height: 16),
                Text('JobBoard', style: text.headlineMedium),
                const SizedBox(height: 4),
                Text(
                  'IT-вакансии для студентов',
                  style: text.bodyMedium,
                ),
                const SizedBox(height: 32),
                const TextField(
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'E-mail',
                    prefixIcon: Icon(Icons.email_outlined),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                const TextField(
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Пароль',
                    prefixIcon: Icon(Icons.lock_outline),
                    suffixIcon: Icon(Icons.visibility_outlined),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () {},
                    child: const Text('Войти'),
                  ),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () {},
                  child: const Text('Нет аккаунта? Зарегистрируйтесь'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}