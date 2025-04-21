
enum Priority { low, medium, high, urgent }

extension PriorityParsing on String {
  Priority toPriority() {
    return Priority.values.firstWhere(
      (e) => e.toString().split('.').last.toLowerCase() == this.toLowerCase(),
      orElse: () => Priority.medium,
    );
  }
}

class Task {
  final String id;
  String title;
  String description;
  DateTime dueDate;
  Priority priority;
  bool isCompleted;
  List<String> tags;

  Task({
    required this.id,
    required this.title,
    this.description = '',
    required this.dueDate,
    this.priority = Priority.medium,
    this.isCompleted = false,
    this.tags = const [],
  });

  Task copyWith({
    String? title,
    String? description,
    DateTime? dueDate,
    Priority? priority,
    bool? isCompleted,
    List<String>? tags,
  }) {
    return Task(
      id: this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      priority: priority ?? this.priority,
      isCompleted: isCompleted ?? this.isCompleted,
      tags: tags ?? List.from(this.tags),
    );
  }
}