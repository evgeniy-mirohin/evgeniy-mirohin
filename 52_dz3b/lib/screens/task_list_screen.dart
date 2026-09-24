import 'package:flutter/material.dart';

import '../models/task.dart';
import '../widgets/empty_state.dart';
import '../widgets/task_tile.dart';

/// Экран со списком задач.
///
/// Реализует полный набор CRUD-операций:
/// * Create — добавление задачи из [TextField];
/// * Read — вывод задач через `ListView.builder`;
/// * Update — изменение текста (диалог) и статуса (чекбокс);
/// * Delete — удаление кнопкой или свайпом, с возможностью отменить удаление.
class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();
  final List<Task> _tasks = <Task>[];

  /// Счётчик, из которого выдаются уникальные идентификаторы задач.
  int _nextId = 1;

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  /// Количество выполненных задач.
  int get _doneCount => _tasks.where((Task task) => task.isDone).length;

  /// CREATE: добавляет задачу с текстом из поля ввода.
  void _addTask() {
    final String title = _controller.text.trim();
    if (title.isEmpty) {
      _showSnackBar('Введите текст задачи');
      return;
    }

    setState(() {
      _tasks.add(Task(id: _nextId, title: title));
      _nextId++;
    });

    _controller.clear();
    _focusNode.requestFocus();
    _scrollToBottom();
    _showSnackBar('Задача добавлена');
  }

  /// UPDATE: меняет текст задачи через диалог редактирования.
  Future<void> _editTask(Task task) async {
    final String? result = await showDialog<String>(
      context: context,
      builder: (BuildContext context) =>
          _EditTaskDialog(initialTitle: task.title),
    );

    if (!mounted || result == null) {
      return;
    }

    final String title = result.trim();
    if (title == task.title) {
      return;
    }

    setState(() {
      final int index = _tasks.indexWhere((Task item) => item.id == task.id);
      if (index == -1) {
        return;
      }
      _tasks[index] = _tasks[index].copyWith(title: title);
    });

    _showSnackBar('Задача изменена');
  }

  /// UPDATE: переключает признак выполнения задачи.
  void _toggleTask(int id, bool isDone) {
    setState(() {
      final int index = _tasks.indexWhere((Task task) => task.id == id);
      if (index == -1) {
        return;
      }
      _tasks[index] = _tasks[index].copyWith(isDone: isDone);
    });
  }

  /// DELETE: удаляет задачу, оставляя возможность вернуть её кнопкой «Отменить».
  void _deleteTask(int id) {
    final int index = _tasks.indexWhere((Task task) => task.id == id);
    if (index == -1) {
      return;
    }
    final Task removed = _tasks[index];

    setState(() => _tasks.removeAt(index));

    _showSnackBar(
      'Задача удалена',
      action: SnackBarAction(
        label: 'Отменить',
        onPressed: () {
          setState(() {
            final int restoreIndex =
                index > _tasks.length ? _tasks.length : index;
            _tasks.insert(restoreIndex, removed);
          });
        },
      ),
    );
  }

  /// DELETE: удаляет все выполненные задачи после подтверждения.
  Future<void> _clearCompleted() async {
    final int doneCount = _doneCount;
    if (doneCount == 0) {
      return;
    }

    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Очистить выполненные?'),
        content: Text('Будет удалено задач: $doneCount.'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Отмена'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Удалить'),
          ),
        ],
      ),
    );

    if (!mounted || confirmed != true) {
      return;
    }

    setState(() => _tasks.removeWhere((Task task) => task.isDone));
    _showSnackBar('Удалено выполненных: $doneCount');
  }

  /// Прокручивает список к последней добавленной задаче.
  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) {
        return;
      }
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  /// Показывает всплывающее уведомление (с необязательной кнопкой действия).
  void _showSnackBar(String message, {SnackBarAction? action}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          action: action,
          duration: const Duration(seconds: 3),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Мои задачи'),
        backgroundColor: theme.colorScheme.inversePrimary,
        actions: <Widget>[
          if (_doneCount > 0)
            IconButton(
              onPressed: _clearCompleted,
              icon: const Icon(Icons.playlist_remove),
              tooltip: 'Очистить выполненные',
            ),
        ],
      ),
      body: Column(
        children: <Widget>[
          _buildInputRow(theme),
          if (_tasks.isNotEmpty) _buildCounter(theme),
          Expanded(
            child: _tasks.isEmpty
                ? const EmptyState()
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: _tasks.length,
                    itemBuilder: (BuildContext context, int index) {
                      final Task task = _tasks[index];
                      return Dismissible(
                        key: ValueKey<int>(task.id),
                        direction: DismissDirection.endToStart,
                        background: _buildDismissBackground(theme),
                        onDismissed: (DismissDirection direction) =>
                            _deleteTask(task.id),
                        child: TaskTile(
                          task: task,
                          onToggle: (bool isDone) => _toggleTask(task.id, isDone),
                          onEdit: () => _editTask(task),
                          onDelete: () => _deleteTask(task.id),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  /// Поле ввода новой задачи и кнопка «Добавить».
  Widget _buildInputRow(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: <Widget>[
          Expanded(
            child: TextField(
              key: const Key('taskInput'),
              controller: _controller,
              focusNode: _focusNode,
              textInputAction: TextInputAction.done,
              onSubmitted: (String value) => _addTask(),
              decoration: const InputDecoration(
                labelText: 'Новая задача',
                hintText: 'Например: выучить Flutter',
                prefixIcon: Icon(Icons.task_alt),
                border: OutlineInputBorder(),
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            height: 56,
            child: FilledButton.icon(
              onPressed: _addTask,
              icon: const Icon(Icons.add),
              label: const Text('Добавить'),
            ),
          ),
        ],
      ),
    );
  }

  /// Строка со статистикой по задачам.
  Widget _buildCounter(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: <Widget>[
          Text(
            'Всего задач: ${_tasks.length}',
            style: theme.textTheme.bodyMedium,
          ),
          const Spacer(),
          Text(
            'Выполнено: $_doneCount из ${_tasks.length}',
            style: theme.textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  /// Красный фон, который виден при свайпе задачи влево.
  Widget _buildDismissBackground(ThemeData theme) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      alignment: Alignment.centerRight,
      decoration: BoxDecoration(
        color: theme.colorScheme.error,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(Icons.delete, color: theme.colorScheme.onError),
    );
  }
}

/// Диалог редактирования текста задачи.
///
/// Возвращает через `Navigator.pop` новый текст задачи или `null`, если
/// пользователь отказался от изменений.
class _EditTaskDialog extends StatefulWidget {
  const _EditTaskDialog({required this.initialTitle});

  /// Исходный текст задачи.
  final String initialTitle;

  @override
  State<_EditTaskDialog> createState() => _EditTaskDialogState();
}

class _EditTaskDialogState extends State<_EditTaskDialog> {
  late final TextEditingController _controller;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialTitle)
      ..selection = TextSelection(
        baseOffset: 0,
        extentOffset: widget.initialTitle.length,
      );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Закрывает диалог, возвращая новый текст задачи.
  void _submit() {
    final String title = _controller.text.trim();
    if (title.isEmpty) {
      setState(() => _errorText = 'Текст задачи не может быть пустым');
      return;
    }
    Navigator.of(context).pop(title);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Редактирование задачи'),
      content: TextField(
        key: const Key('editTaskInput'),
        controller: _controller,
        autofocus: true,
        maxLines: null,
        textInputAction: TextInputAction.done,
        onSubmitted: (String value) => _submit(),
        decoration: InputDecoration(
          labelText: 'Текст задачи',
          errorText: _errorText,
          border: const OutlineInputBorder(),
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Отмена'),
        ),
        FilledButton(onPressed: _submit, child: const Text('Сохранить')),
      ],
    );
  }
}
