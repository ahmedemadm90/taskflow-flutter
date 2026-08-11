class Task {
  final String id;
  final String title;
  final String description;
  bool isCompleted;
  final DateTime dueDate;

  Task({
    required this.id,
    required this.title,
    required this.description,
    this.isCompleted = false,
    required this.dueDate,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'].toString(),
      title: json['title'],
      description: json['description'] ?? '',
      isCompleted: json['is_completed'] ?? false,
      dueDate: DateTime.parse(json['due_date'] ?? DateTime.now().toString()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'is_completed': isCompleted,
      'due_date': dueDate.toIso8601String(),
    };
  }
}
