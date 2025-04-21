import 'package:taskmanagementsystem/Core/error/exceptions.dart';
import 'package:taskmanagementsystem/Domain/entities/task.dart';
import 'package:taskmanagementsystem/Domain/repository/task_repository.dart';

class InMemoryTaskRepository implements TaskRepository {
  final Map<String, Task> _tasks = {};

  @override
  Future<List<Task>> getAllTasks() async {
    return _tasks.values.toList();
  }

  @override
  Future<Task?> getTaskById(String id) async {
    return _tasks[id];
  }

  @override
  Future<void> addTask(Task task) async {
    if (_tasks.containsKey(task.id)) {
      throw TaskException('Task with ID ${task.id} already exists');
    }
    _tasks[task.id] = task;
  }

  @override
  Future<void> updateTask(Task task) async {
    if (!_tasks.containsKey(task.id)) {
      throw TaskException('Task with ID ${task.id} not found');
    }
    _tasks[task.id] = task;
  }

  @override
  Future<void> deleteTask(String id) async {
    if (!_tasks.containsKey(id)) {
      throw TaskException('Task with ID $id not found');
    }
    _tasks.remove(id);
  }

  @override
  Future<List<Task>> searchTasks(String query) async {
    final lowercaseQuery = query.toLowerCase();
    
    return _tasks.values.where((task) {
      return task.title.toLowerCase().contains(lowercaseQuery) ||
             task.description.toLowerCase().contains(lowercaseQuery) ||
             task.tags.any((tag) => tag.toLowerCase().contains(lowercaseQuery));
    }).toList();
  }

  @override
  Future<void> saveAll() async {
    // No-op for in-memory repository
  }
}
