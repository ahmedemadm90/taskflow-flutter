import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/task.model.dart';

class LocalTaskStore {
  static const _storageKey = 'taskflow.tasks.v1';

  Future<List<Task>> readTasks() async {
    final preferences = await SharedPreferences.getInstance();
    final raw = preferences.getString(_storageKey);
    if (raw == null) return [];

    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded
        .map((item) => Task.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<void> writeTasks(List<Task> tasks) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(
      _storageKey,
      jsonEncode(tasks.map((task) => task.toJson()).toList()),
    );
  }
}
