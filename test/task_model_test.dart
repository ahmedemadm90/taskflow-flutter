import 'package:flutter_test/flutter_test.dart';
import 'package:taskflow_flutter/models/task.model.dart';

void main() {
  test('task serializes and restores all business fields', () {
    final original = Task(
      id: 'task-1',
      title: 'Ship release',
      description: 'Publish the production build.',
      priority: TaskPriority.high,
      dueDate: DateTime(2026, 8, 20),
      createdAt: DateTime(2026, 8, 11),
      tags: const ['release', 'mobile'],
    );

    final restored = Task.fromJson(original.toJson());

    expect(restored.id, original.id);
    expect(restored.title, original.title);
    expect(restored.description, original.description);
    expect(restored.priority, TaskPriority.high);
    expect(restored.tags, containsAll(['release', 'mobile']));
  });
}
