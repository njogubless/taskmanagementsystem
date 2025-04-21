import 'package:taskmanagementsystem/Domain/entities/task.dart';

class TaskModel {
  final String id;
  final String title;
  final String description;
  final String dueDate;
  final String priority;
  final bool isCompleted;
  final List<String> tags;

  TaskModel({
    required this.id,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.priority,
    required this.isCompleted,
    required this.tags,
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id'],
      title: json['title'],
      description: json['description'] ?? '',
      dueDate: json['dueDate'],
      priority: json['priority'],
      isCompleted: json['isCompleted'] ?? false,
      tags: List<String>.from(json['tags'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'dueDate': dueDate,
      'priority': priority,
      'isCompleted': isCompleted,
      'tags': tags,
    };
  }

  Task toDomain() {
    return Task(
      id: id,
      title: title,
      description: description,
      dueDate: DateTime.parse(dueDate),
      priority: priority.toPriority(),
      isCompleted: isCompleted,
      tags: tags,
    );
  }

  factory TaskModel.fromDomain(Task task) {
    return TaskModel(
      id: task.id,
      title: task.title,
      description: task.description,
      dueDate: task.dueDate.toIso8601String(),
      priority: task.priority.toString().split('.').last,
      isCompleted: task.isCompleted,
      tags: task.tags,
    );
  }
}