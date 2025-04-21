class GetAllTasksUseCase {
  final TaskRepository repository;
  
  GetAllTasksUseCase(this.repository);
  
  Future<List<Task>> call() async {
    return await repository.getAllTasks();
  }
}

class GetTaskByIdUseCase {
  final TaskRepository repository;
  
  GetTaskByIdUseCase(this.repository);
  
  Future<Task?> call(String id) async {
    return await repository.getTaskById(id);
  }
}

class CreateTaskUseCase {
  final TaskRepository repository;
  
  CreateTaskUseCase(this.repository);
  
  String _generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString() + 
           Random().nextInt(1000).toString();
  }
  
  Future<void> call({
    required String title,
    required String description,
    required DateTime dueDate,
    required Priority priority,
    required List<String> tags,
  }) async {
    if (title.isEmpty) {
      throw TaskException('Task title cannot be empty');
    }
    
    final task = Task(
      id: _generateId(),
      title: title,
      description: description,
      dueDate: dueDate,
      priority: priority,
      tags: tags,
    );
    
    await repository.addTask(task);
  }
}

class UpdateTaskUseCase {
  final TaskRepository repository;
  
  UpdateTaskUseCase(this.repository);
  
  Future<void> call(Task task) async {
    await repository.updateTask(task);
  }
}

class DeleteTaskUseCase {
  final TaskRepository repository;
  
  DeleteTaskUseCase(this.repository);
  
  Future<void> call(String id) async {
    await repository.deleteTask(id);
  }
}

class SearchTasksUseCase {
  final TaskRepository repository;
  
  SearchTasksUseCase(this.repository);
  
  Future<List<Task>> call(String query) async {
    return await repository.searchTasks(query);
  }
}

class ToggleTaskCompletionUseCase {
  final TaskRepository repository;
  
  ToggleTaskCompletionUseCase(this.repository);
  
  Future<void> call(String id) async {
    final task = await repository.getTaskById(id);
    if (task == null) {
      throw TaskException('Task with ID $id not found');
    }
    
    final updatedTask = task.copyWith(isCompleted: !task.isCompleted);
    await repository.updateTask(updatedTask);
  }
}

class GetTasksByPriorityUseCase {
  final TaskRepository repository;
  
  GetTasksByPriorityUseCase(this.repository);
  
  Future<List<Task>> call(Priority priority) async {
    final tasks = await repository.getAllTasks();
    return tasks.where((task) => task.priority == priority).toList();
  }
}

class GetTasksByDueDateUseCase {
  final TaskRepository repository;
  
  GetTasksByDueDateUseCase(this.repository);
  
  Future<List<Task>> call({required DateTime startDate, DateTime? endDate}) async {
    final tasks = await repository.getAllTasks();
    final end = endDate ?? DateTime.now().add(Duration(days: 365));
    
    return tasks.where((task) {
      final date = task.dueDate;
      return date.isAfter(startDate.subtract(Duration(days: 1))) && 
             date.isBefore(end.add(Duration(days: 1)));
    }).toList();
  }
}

class GetTasksByTagUseCase {
  final TaskRepository repository;
  
  GetTasksByTagUseCase(this.repository);
  
  Future<List<Task>> call(String tag) async {
    final tasks = await repository.getAllTasks();
    final lowercaseTag = tag.toLowerCase();
    
    return tasks.where((task) => 
      task.tags.any((t) => t.toLowerCase() == lowercaseTag)
    ).toList();
  }
}