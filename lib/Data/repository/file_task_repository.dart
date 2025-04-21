import 'package:taskmanagementsystem/Core/error/exceptions.dart';
import 'package:taskmanagementsystem/Data/datasources/file_datasource.dart';
import 'package:taskmanagementsystem/Data/models/task_model.dart';
import 'package:taskmanagementsystem/Domain/entities/task.dart';
import 'package:taskmanagementsystem/Domain/repository/task_repository.dart';

class FileTaskRepository implements TaskRepository {
  final FileDataSource _dataSource;
  final Map<String, Task> _tasks = {};
  bool _loaded = false;

  FileTaskRepository(this._dataSource);

  Future<void> _loadTasksIfNeeded() async {
    if (_loaded) return;
    
    try {
      final taskModels = await _dataSource.readTasks();
      
      for (var model in taskModels) {
        final task = model.toDomain();
        _tasks[task.id] = task;
      }
      _loaded = true;
    } catch (e) {
      throw TaskException('Failed to load tasks: $e');
    }
  }

  @override
  Future<List<Task>> getAllTasks() async {
    await _loadTasksIfNeeded();
    return _tasks.values.toList();
  }

  @override
  Future<Task?> getTaskById(String id) async {
    await _loadTasksIfNeeded();
    return _tasks[id];
  }

  @override
  Future<void> addTask(Task task) async {
    await _loadTasksIfNeeded();
    if (_tasks.containsKey(task.id)) {
      throw TaskException('Task with ID ${task.id} already exists');
    }
    _tasks[task.id] = task;
    await saveAll();
  }

  @override
  Future<void> updateTask(Task task) async {
    await _loadTasksIfNeeded();
    if (!_tasks.containsKey(task.id)) {
      throw TaskException('Task with ID ${task.id} not found');
    }
    _tasks[task.id] = task;
    await saveAll();
  }

  @override
  Future<void> deleteTask(String id) async {
    await _loadTasksIfNeeded();
    if (!_tasks.containsKey(id)) {
      throw TaskException('Task with ID $id not found');
    }
    _tasks.remove(id);
    await saveAll();
  }

  @override
  Future<List<Task>> searchTasks(String query) async {
    await _loadTasksIfNeeded();
    final lowercaseQuery = query.toLowerCase();
    
    return _tasks.values.where((task) {
      return task.title.toLowerCase().contains(lowercaseQuery) ||
             task.description.toLowerCase().contains(lowercaseQuery) ||
             task.tags.any((tag) => tag.toLowerCase().contains(lowercaseQuery));
    }).toList();
  }

  @override
  Future<void> saveAll() async {
    try {
      final taskModels = _tasks.values
          .map((task) => TaskModel.fromDomain(task))
          .toList();
      
      await _dataSource.writeTasks(taskModels);
    } catch (e) {
      throw TaskException('Failed to save tasks: $e');
    }
  }
}