import 'package:flutter/material.dart';

import 'screens/task_list_screen.dart';

void main() {
  runApp(const TaskApp());
}

/// Корневой виджет приложения «Список задач».
class TaskApp extends StatelessWidget {
  const TaskApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Список задач',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
      ),
      home: const TaskListScreen(),
    );
  }
}
