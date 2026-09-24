import 'package:flutter/material.dart';

import '../models/task.dart';

/// Одна строка списка задач: чекбокс, текст и кнопки «изменить»/«удалить».
class TaskTile extends StatelessWidget {
  const TaskTile({
    super.key,
    required this.task,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
  });

  /// Отображаемая задача.
  final Task task;

  /// Вызывается при переключении чекбокса (или нажатии на строку).
  final ValueChanged<bool> onToggle;

  /// Вызывается при нажатии на кнопку «Редактировать».
  final VoidCallback onEdit;

  /// Вызывается при нажатии на кнопку «Удалить».
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return ListTile(
      contentPadding: const EdgeInsets.only(left: 4, right: 8),
      onTap: () => onToggle(!task.isDone),
      leading: Checkbox(
        value: task.isDone,
        onChanged: (bool? value) => onToggle(value ?? false),
      ),
      title: Text(
        task.title,
        style: TextStyle(
          decoration:
              task.isDone ? TextDecoration.lineThrough : TextDecoration.none,
          color: task.isDone
              ? theme.colorScheme.onSurfaceVariant
              : theme.colorScheme.onSurface,
        ),
      ),
      subtitle: Text('#${task.id}'),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          IconButton(
            onPressed: onEdit,
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Редактировать',
          ),
          IconButton(
            onPressed: onDelete,
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Удалить',
          ),
        ],
      ),
    );
  }
}
