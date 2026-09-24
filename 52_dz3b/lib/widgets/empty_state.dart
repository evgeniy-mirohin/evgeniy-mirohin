import 'package:flutter/material.dart';

/// Заглушка, которая показывается, когда список задач пуст.
class EmptyState extends StatelessWidget {
  const EmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(
            Icons.checklist_rtl,
            size: 72,
            color: theme.colorScheme.primary.withValues(alpha: 0.6),
          ),
          const SizedBox(height: 16),
          Text('Задач пока нет', style: theme.textTheme.titleMedium),
          const SizedBox(height: 4),
          Text(
            'Добавьте первую задачу в поле выше',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
