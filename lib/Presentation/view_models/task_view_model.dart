
enum TaskViewMode {all, active, completed, priority, dueDate}

class TaskViewModel {
  final String id;
  final String title;
  final String description;
  final DateTime dueDate;
  final Priority priority;
  final bool isCompleted;
  final List<String> tags;
  
  TaskViewModel({
    required this.id,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.priority,
    required this.isCompleted,
    required this.tags,
  });
  
  factory TaskViewModel.fromDomain(Task task) {
    return TaskViewModel(
      id: task.id,
      title: task.title,
      description: task.description,
      dueDate: task.dueDate,
      priority: task.priority,
      isCompleted: task.isCompleted,
      tags: task.tags,
    );
  }
  
  String get formattedDueDate {
    return '${dueDate.year}-${dueDate.month.toString().padLeft(2, '0')}-${dueDate.day.toString().padLeft(2, '0')}';
  }
  
  String get formattedTags {
    return tags.join(', ');
  }
  
  String get priorityName {
    return priority.toString().split('.').last;
  }
  
  String get prioritySymbol {
    switch (priority) {
      case Priority.low:
        return '⬇️';
      case Priority.medium:
        return '⏺️';
      case Priority.high:
        return '⬆️';
      case Priority.urgent:
        return '🔥';
    }
  }
}