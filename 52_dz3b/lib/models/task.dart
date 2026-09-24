import 'package:flutter/foundation.dart';

/// Модель одной задачи в списке.
///
/// Класс неизменяемый: чтобы «изменить» задачу, нужно создать новый
/// экземпляр через [copyWith] — так состояние экрана остаётся предсказуемым.
@immutable
class Task {
  const Task({
    required this.id,
    required this.title,
    this.isDone = false,
  });

  /// Уникальный идентификатор задачи. Выдаётся экраном-списком.
  final int id;

  /// Текст задачи.
  final String title;

  /// Признак того, что задача выполнена.
  final bool isDone;

  /// Возвращает копию задачи с изменёнными полями.
  Task copyWith({int? id, String? title, bool? isDone}) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      isDone: isDone ?? this.isDone,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    return other is Task &&
        other.id == id &&
        other.title == title &&
        other.isDone == isDone;
  }

  @override
  int get hashCode => Object.hash(id, title, isDone);

  @override
  String toString() => 'Task(id: $id, title: "$title", isDone: $isDone)';
}
