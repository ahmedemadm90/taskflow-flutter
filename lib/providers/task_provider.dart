import 'package:flutter/foundation.dart';
import '../models/task.model.dart';

class TaskProvider with ChangeNotifier {
  final List<Task> _tasks = [
    Task(
      id: '1',
      title: 'Design API Architecture',
      description: 'Define REST endpoints and Sanctum authentication for Laravel backend.',
      dueDate: DateTime.now().add(const Duration(days: 1)),
      isCompleted: true,
    ),
    Task(
      id: '2',
      title: 'Build Flutter UI',
      description: 'Implement Material 3 clean architecture UI with Provider state management.',
      dueDate: DateTime.now().add(const Duration(days: 2)),
      isCompleted: false,
    ),
    Task(
      id: '3',
      title: 'Configure n8n Webhooks',
      description: 'Setup automated notification workflow for completed tasks.',
      dueDate: DateTime.now().add(const Duration(days: 3)),
      isCompleted: false,
    ),
  ];

  List<Task> get tasks => _tasks;

  void toggleTaskStatus(String id) {
    final index = _tasks.indexWhere((task) => task.id == id);
    if (index != -1) {
      _tasks[index].isCompleted = !_tasks[index].isCompleted;
      notifyListeners();
    }
  }

  void addTask(String title, String description) {
    final newTask = Task(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      description: description,
      dueDate: DateTime.now().add(const Duration(days: 5)),
    );
    _tasks.add(newTask);
    notifyListeners();
  }

  void deleteTask(String id) {
    _tasks.removeWhere((task) => task.id == id);
    notifyListeners();
  }
}
