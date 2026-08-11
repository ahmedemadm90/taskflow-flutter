import 'package:flutter/foundation.dart';

import '../models/task.model.dart';
import '../services/local_task_store.dart';
import '../services/task_api_service.dart';

class TaskProvider extends ChangeNotifier {
  TaskProvider({LocalTaskStore? store, TaskApiService? api})
      : _store = store ?? LocalTaskStore(),
        _api = api ?? TaskApiService();

  final LocalTaskStore _store;
  final TaskApiService _api;
  final List<Task> _tasks = [];
  String _searchQuery = '';
  TaskFilter _filter = TaskFilter.all;
  bool _isLoading = true;
  String? _errorMessage;

  List<Task> get tasks => List.unmodifiable(_tasks);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  TaskFilter get filter => _filter;
  String get searchQuery => _searchQuery;

  List<Task> get visibleTasks {
    final normalizedQuery = _searchQuery.trim().toLowerCase();
    return _tasks.where((task) {
      final matchesFilter = switch (_filter) {
        TaskFilter.all => true,
        TaskFilter.open => !task.isCompleted,
        TaskFilter.completed => task.isCompleted,
      };
      final matchesSearch = normalizedQuery.isEmpty ||
          task.title.toLowerCase().contains(normalizedQuery) ||
          task.description.toLowerCase().contains(normalizedQuery) ||
          task.tags.any((tag) => tag.toLowerCase().contains(normalizedQuery));
      return matchesFilter && matchesSearch;
    }).toList()
      ..sort((a, b) {
        if (a.isCompleted != b.isCompleted) return a.isCompleted ? 1 : -1;
        return a.dueDate.compareTo(b.dueDate);
      });
  }

  int get completedCount => _tasks.where((task) => task.isCompleted).length;
  int get openCount => _tasks.length - completedCount;
  double get completionRate => _tasks.isEmpty ? 0 : completedCount / _tasks.length;

  Future<void> syncFromApi() async {
    try {
      final remoteTasks = await _api.fetchTasks();
      _tasks
        ..clear()
        ..addAll(remoteTasks);
      await _store.writeTasks(_tasks);
      notifyListeners();
    } on TaskApiException catch (error) {
      _errorMessage = error.message;
      notifyListeners();
    }
  }

  Future<void> loadTasks() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final savedTasks = await _store.readTasks();
      _tasks
        ..clear()
        ..addAll(savedTasks.isEmpty ? _seedTasks() : savedTasks);
      if (savedTasks.isEmpty) await _store.writeTasks(_tasks);
    } catch (_) {
      _errorMessage = 'Could not load your tasks. Please try again.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setFilter(TaskFilter filter) {
    _filter = filter;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  Future<void> addTask({
    required String title,
    required String description,
    required DateTime dueDate,
    required TaskPriority priority,
    List<String> tags = const [],
  }) async {
    final task = Task(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      title: title.trim(),
      description: description.trim(),
      dueDate: dueDate,
      priority: priority,
      createdAt: DateTime.now(),
      tags: tags,
    );
    _tasks.add(task);
    await _persist();
  }

  Future<void> toggleTask(String id) async {
    final index = _tasks.indexWhere((task) => task.id == id);
    if (index == -1) return;
    _tasks[index] = _tasks[index].copyWith(isCompleted: !_tasks[index].isCompleted);
    await _persist();
  }

  Future<void> deleteTask(String id) async {
    _tasks.removeWhere((task) => task.id == id);
    await _persist();
  }

  Future<void> updateTask(Task updatedTask) async {
    final index = _tasks.indexWhere((task) => task.id == updatedTask.id);
    if (index == -1) return;
    _tasks[index] = updatedTask;
    await _persist();
  }

  Future<void> _persist() async {
    _errorMessage = null;
    notifyListeners();
    try {
      await _store.writeTasks(_tasks);
    } catch (_) {
      _errorMessage = 'Your task changed, but local storage failed.';
      notifyListeners();
    }
  }

  List<Task> _seedTasks() {
    final now = DateTime.now();
    return [
      Task(
        id: 'seed-1',
        title: 'Design API architecture',
        description: 'Define REST endpoints and authentication for the Laravel backend.',
        dueDate: now.add(const Duration(days: 1)),
        priority: TaskPriority.high,
        createdAt: now,
        isCompleted: true,
        tags: const ['backend', 'laravel'],
      ),
      Task(
        id: 'seed-2',
        title: 'Build Flutter dashboard',
        description: 'Implement the task list with filtering, search, and persistent state.',
        dueDate: now.add(const Duration(days: 2)),
        priority: TaskPriority.high,
        createdAt: now,
        tags: const ['mobile', 'flutter'],
      ),
      Task(
        id: 'seed-3',
        title: 'Connect n8n webhook',
        description: 'Send an event when a task is completed and notify the operations channel.',
        dueDate: now.add(const Duration(days: 4)),
        priority: TaskPriority.medium,
        createdAt: now,
        tags: const ['automation', 'n8n'],
      ),
    ];
  }
}

enum TaskFilter { all, open, completed }
