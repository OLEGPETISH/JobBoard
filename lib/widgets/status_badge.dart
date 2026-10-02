import 'package:flutter/material.dart';
import '../data/mock_data.dart';

class StatusBadge extends StatelessWidget {
  final ApplicationStatus status;

  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    final (label, icon, background, foreground) = switch (status) {
      ApplicationStatus.sent => (
          'Отправлен',
          Icons.send,
          scheme.secondaryContainer,
          scheme.onSecondaryContainer,
        ),
      ApplicationStatus.viewed => (
          'Просмотрен',
          Icons.visibility,
          scheme.tertiaryContainer,
          scheme.onTertiaryContainer,
        ),
      ApplicationStatus.interview => (
          'Интервью',
          Icons.event_available,
          scheme.primaryContainer,
          scheme.onPrimaryContainer,
        ),
      ApplicationStatus.rejected => (
          'Отказ',
          Icons.cancel_outlined,
          scheme.errorContainer,
          scheme.onErrorContainer,
        ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: foreground),
          const SizedBox(width: 4),
          Text(
            label,
            style: Theme.of(context)
                .textTheme
                .labelMedium
                ?.copyWith(color: foreground),
          ),
        ],
      ),
    );
  }
}