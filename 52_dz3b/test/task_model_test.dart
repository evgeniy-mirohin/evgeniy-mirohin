import 'package:dz3ball/models/task.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Task', () {
    test('по умолчанию задача считается невыполненной', () {
      const Task task = Task(id: 1, title: 'Купить хлеб');

      expect(task.id, 1);
      expect(task.title, 'Купить хлеб');
      expect(task.isDone, isFalse);
    });

    test('copyWith меняет только переданные поля', () {
      const Task task = Task(id: 7, title: 'Старый текст');

      final Task renamed = task.copyWith(title: 'Новый текст');
      expect(renamed.id, 7);
      expect(renamed.title, 'Новый текст');
      expect(renamed.isDone, isFalse);

      final Task completed = task.copyWith(isDone: true);
      expect(completed.id, 7);
      expect(completed.title, 'Старый текст');
      expect(completed.isDone, isTrue);
    });

    test('copyWith не изменяет исходную задачу', () {
      const Task task = Task(id: 2, title: 'Исходная');

      task.copyWith(title: 'Изменённая', isDone: true);

      expect(task.title, 'Исходная');
      expect(task.isDone, isFalse);
    });

    test('copyWith без аргументов возвращает равную задачу', () {
      const Task task = Task(id: 3, title: 'Задача');

      expect(task.copyWith(), task);
      expect(task.copyWith().hashCode, task.hashCode);
    });

    test('равенство учитывает все поля', () {
      const Task task = Task(id: 4, title: 'Текст');

      expect(task, const Task(id: 4, title: 'Текст'));
      expect(task, isNot(const Task(id: 5, title: 'Текст')));
      expect(task, isNot(const Task(id: 4, title: 'Другой текст')));
      expect(task, isNot(const Task(id: 4, title: 'Текст', isDone: true)));
    });
  });
}
