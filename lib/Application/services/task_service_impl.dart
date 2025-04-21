import 'package:taskmanagementsystem/Domain/entities/task.dart';
import 'package:taskmanagementsystem/Domain/usecases/task_usecases.dart';

abstract class TaskService {
  Future<List<Task>> getAllTasks();
  Future<Task?> getTaskById(String id);
  Future<void> createTask(String title, String description, DateTime dueDate, Priority priority, List<String> tags);
  Future<void> updateTask(Task task);
  Future<void> deleteTask(String id);
  Future<void> toggleTaskCompletion(String id);
  Future<List<Task>> searchTasks(String query);
  Future<List<Task>> getTasksByPriority(Priority priority);
  Future<List<Task>> getTasksByDueDate({required DateTime startDate, DateTime? endDate});
  Future<List<Task>> getTasksByTag(String tag);
}

class TaskServiceImpl implements TaskService {
  final GetAllTasksUseCase _getAllTasksUseCase;
  final GetTaskByIdUseCase _getTaskByIdUseCase;
  final CreateTaskUseCase _createTaskUseCase;
  final UpdateTaskUseCase _updateTaskUseCase;
  final DeleteTaskUseCase _deleteTaskUseCase;
  final SearchTasksUseCase _searchTasksUseCase;
  final ToggleTaskCompletionUseCase _toggleTaskCompletionUseCase;
  final GetTasksByPriorityUseCase _getTasksByPriorityUseCase;
  final GetTasksByDueDateUseCase _getTasksByDueDateUseCase;
  final GetTasksByTagUseCase _getTasksByTagUseCase;
  
  TaskServiceImpl({
    required GetAllTasksUseCase getAllTasksUseCase,
    required GetTaskByIdUseCase getTaskByIdUseCase,
    required CreateTaskUseCase createTaskUseCase,
    required UpdateTaskUseCase updateTaskUseCase,
    required DeleteTaskUseCase deleteTaskUseCase,
    required SearchTasksUseCase searchTasksUseCase,
    required ToggleTaskCompletionUseCase toggleTaskCompletionUseCase,
    required GetTasksByPriorityUseCase getTasksByPriorityUseCase,
    required GetTasksByDueDateUseCase getTasksByDueDateUseCase,
    required GetTasksByTagUseCase getTasksByTagUseCase,
  }) : 
    _getAllTasksUseCase = getAllTasksUseCase,
    _getTaskByIdUseCase = getTaskByIdUseCase,
    _createTaskUseCase = createTaskUseCase,
    _updateTaskUseCase = updateTaskUseCase,
    _deleteTaskUseCase = deleteTaskUseCase,
    _searchTasksUseCase = searchTasksUseCase,
    _toggleTaskCompletionUseCase = toggleTaskCompletionUseCase,
    _getTasksByPriorityUseCase = getTasksByPriorityUseCase,
    _getTasksByDueDateUseCase = getTasksByDueDateUseCase,
    _getTasksByTagUseCase = getTasksByTagUseCase;

  @override
  Future<List<Task>> getAllTasks() async {
    return await _getAllTasksUseCase();
  }

  @override
  Future<Task?> getTaskById(String id) async {
    return await _getTaskByIdUseCase(id);
  }

  @override
  Future<void> createTask(
      String title, 
      String description, 
      DateTime dueDate, 
      Priority priority, 
      List<String> tags) async {
    
    await _createTaskUseCase(
      title: title,
      description: description,
      dueDate: dueDate,
      priority: priority,
      tags: tags,
    );
  }

  @override
  Future<void> updateTask(Task task) async {
    await _updateTaskUseCase(task);
  }

  @override
  Future<void> deleteTask(String id) async {
    await _deleteTaskUseCase(id);
  }

  @override
  Future<void> toggleTaskCompletion(String id) async {
    await _toggleTaskCompletionUseCase(id);
  }

  @override
  Future<List<Task>> searchTasks(String query) async {
    return await _searchTasksUseCase(query);
  }

  @override
  Future<List<Task>> getTasksByPriority(Priority priority) async {
    return await _getTasksByPriorityUseCase(priority);
  }

  @override
  Future<List<Task>> getTasksByDueDate({required DateTime startDate, DateTime? endDate}) async {
    return await _getTasksByDueDateUseCase(startDate: startDate, endDate: endDate);
  }

  @override
  Future<List<Task>> getTasksByTag(String tag) async {
    return await _getTasksByTagUseCase(tag);
  }
}