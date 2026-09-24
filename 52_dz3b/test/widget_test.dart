import 'package:dz3ball/main.dart';
import 'package:dz3ball/widgets/empty_state.dart';
import 'package:dz3ball/widgets/task_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Ключ текстового поля для добавления новой задачи.
const Key _taskInputKey = Key('taskInput');

/// Ключ текстового поля в диалоге редактирования.
const Key _editInputKey = Key('editTaskInput');

/// Поднимает приложение «Список задач» и дожидается отрисовки первого кадра.
Future<void> _pumpApp(WidgetTester tester) async {
  await tester.pumpWidget(const TaskApp());
  await tester.pumpAndSettle();
}

/// Добавляет задачу через поле ввода и кнопку «Добавить».
Future<void> _addTask(WidgetTester tester, String title) async {
  await tester.enterText(find.byKey(_taskInputKey), title);
  await tester.tap(find.text('Добавить'));
  await tester.pumpAndSettle();
}

/// Даёт показанному SnackBar исчезнуть, чтобы в тесте не осталось таймеров.
Future<void> _dismissSnackBar(WidgetTester tester) async {
  await tester.pumpAndSettle(const Duration(seconds: 4));
}

void main() {
  group('Экран списка задач', () {
    testWidgets('показывает заглушку, когда задач нет', (
      WidgetTester tester,
    ) async {
      await _pumpApp(tester);

      expect(find.byType(EmptyState), findsOneWidget);
      expect(find.text('Задач пока нет'), findsOneWidget);
      expect(find.byType(TaskTile), findsNothing);
    });

    testWidgets('добавляет задачу по кнопке и очищает поле ввода', (
      WidgetTester tester,
    ) async {
      await _pumpApp(tester);

      await _addTask(tester, 'Купить хлеб');

      expect(find.byType(TaskTile), findsOneWidget);
      expect(find.text('Купить хлеб'), findsOneWidget);
      expect(find.text('Задача добавлена'), findsOneWidget);
      expect(find.text('Всего задач: 1'), findsOneWidget);
      expect(find.byType(EmptyState), findsNothing);

      final TextField input = tester.widget<TextField>(
        find.byKey(_taskInputKey),
      );
      expect(input.controller?.text, isEmpty);

      await _dismissSnackBar(tester);
    });

    testWidgets('добавляет задачу по нажатию Enter', (
      WidgetTester tester,
    ) async {
      await _pumpApp(tester);

      await tester.enterText(find.byKey(_taskInputKey), 'Сделать зарядку');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      expect(find.text('Сделать зарядку'), findsOneWidget);

      await _dismissSnackBar(tester);
    });

    testWidgets('не добавляет задачу из пустой строки', (
      WidgetTester tester,
    ) async {
      await _pumpApp(tester);

      await _addTask(tester, '   ');

      expect(find.byType(TaskTile), findsNothing);
      expect(find.text('Введите текст задачи'), findsOneWidget);

      await _dismissSnackBar(tester);
    });

    testWidgets('выводит несколько задач в порядке добавления', (
      WidgetTester tester,
    ) async {
      await _pumpApp(tester);

      await _addTask(tester, 'Первая');
      await _addTask(tester, 'Вторая');
      await _addTask(tester, 'Третья');

      final Finder tiles = find.byType(TaskTile);
      expect(tiles, findsNWidgets(3));
      expect(tester.widgetList<TaskTile>(tiles).first.task.title, 'Первая');
      expect(tester.widgetList<TaskTile>(tiles).last.task.title, 'Третья');
      expect(find.text('Всего задач: 3'), findsOneWidget);

      await _dismissSnackBar(tester);
    });
    testWidgets('редактирует текст задачи через диалог', (
      WidgetTester tester,
    ) async {
      await _pumpApp(tester);
      await _addTask(tester, 'Старый текст');
      await _dismissSnackBar(tester);

      await tester.tap(find.byTooltip('Редактировать'));
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text('Редактирование задачи'), findsOneWidget);

      await tester.enterText(find.byKey(_editInputKey), 'Новый текст');
      await tester.tap(find.text('Сохранить'));
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsNothing);
      expect(find.text('Новый текст'), findsOneWidget);
      expect(find.text('Старый текст'), findsNothing);
      expect(find.text('Задача изменена'), findsOneWidget);

      await _dismissSnackBar(tester);
    });

    testWidgets('отмена редактирования не меняет задачу', (
      WidgetTester tester,
    ) async {
      await _pumpApp(tester);
      await _addTask(tester, 'Оставить как есть');
      await _dismissSnackBar(tester);

      await tester.tap(find.byTooltip('Редактировать'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(_editInputKey), 'Что-то другое');
      await tester.tap(find.text('Отмена'));
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsNothing);
      expect(find.text('Оставить как есть'), findsOneWidget);
      expect(find.text('Что-то другое'), findsNothing);
    });

    testWidgets('не сохраняет пустой текст в диалоге редактирования', (
      WidgetTester tester,
    ) async {
      await _pumpApp(tester);
      await _addTask(tester, 'Задача с текстом');
      await _dismissSnackBar(tester);

      await tester.tap(find.byTooltip('Редактировать'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(_editInputKey), '   ');
      await tester.tap(find.text('Сохранить'));
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text('Текст задачи не может быть пустым'), findsOneWidget);

      await tester.tap(find.text('Отмена'));
      await tester.pumpAndSettle();

      expect(find.text('Задача с текстом'), findsOneWidget);
    });

    testWidgets('чекбокс помечает задачу выполненной', (
      WidgetTester tester,
    ) async {
      await _pumpApp(tester);
      await _addTask(tester, 'Сделать домашку');
      await _dismissSnackBar(tester);

      expect(find.text('Выполнено: 0 из 1'), findsOneWidget);

      await tester.tap(find.byType(Checkbox));
      await tester.pumpAndSettle();

      expect(find.text('Выполнено: 1 из 1'), findsOneWidget);
      expect(_titleOf(tester, 'Сделать домашку').style?.decoration,
          TextDecoration.lineThrough);

      await tester.tap(find.byType(Checkbox));
      await tester.pumpAndSettle();

      expect(find.text('Выполнено: 0 из 1'), findsOneWidget);
      expect(_titleOf(tester, 'Сделать домашку').style?.decoration,
          isNot(TextDecoration.lineThrough));
    });

    testWidgets('удаляет задачу кнопкой и возвращает её кнопкой «Отменить»', (
      WidgetTester tester,
    ) async {
      await _pumpApp(tester);
      await _addTask(tester, 'Удалить меня');
      await _dismissSnackBar(tester);

      await tester.tap(find.byTooltip('Удалить'));
      await tester.pumpAndSettle();

      expect(find.byType(TaskTile), findsNothing);
      expect(find.byType(EmptyState), findsOneWidget);
      expect(find.text('Задача удалена'), findsOneWidget);

      await tester.tap(find.text('Отменить'));
      await tester.pumpAndSettle();

      expect(find.byType(TaskTile), findsOneWidget);
      expect(find.text('Удалить меня'), findsOneWidget);

      await _dismissSnackBar(tester);
    });

    testWidgets('удаляет задачу свайпом влево', (WidgetTester tester) async {
      await _pumpApp(tester);
      await _addTask(tester, 'Свайп-задача');
      await _dismissSnackBar(tester);

      await tester.drag(find.byType(TaskTile), const Offset(-600, 0));
      await tester.pumpAndSettle();

      expect(find.byType(TaskTile), findsNothing);
      expect(find.byType(EmptyState), findsOneWidget);

      await _dismissSnackBar(tester);
    });

    testWidgets('удаляет только выполненные задачи', (
      WidgetTester tester,
    ) async {
      await _pumpApp(tester);
      await _addTask(tester, 'Сделано');
      await _addTask(tester, 'Не сделано');
      await _dismissSnackBar(tester);

      await tester.tap(find.byType(Checkbox).first);
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('Очистить выполненные'));
      await tester.pumpAndSettle();

      expect(find.text('Очистить выполненные?'), findsOneWidget);

      await tester.tap(find.text('Удалить'));
      await tester.pumpAndSettle();

      expect(find.byType(TaskTile), findsOneWidget);
      expect(find.text('Не сделано'), findsOneWidget);
      expect(find.text('Сделано'), findsNothing);
      expect(find.text('Всего задач: 1'), findsOneWidget);

      await _dismissSnackBar(tester);
    });
  });
}

/// Возвращает виджет текста задачи из списка, чтобы проверить его стиль.
Text _titleOf(WidgetTester tester, String title) {
  return tester.widget<Text>(
    find.descendant(of: find.byType(TaskTile), matching: find.text(title)),
  );
}
