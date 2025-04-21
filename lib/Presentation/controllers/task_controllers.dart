class TaskController {
  final TaskService _taskService;
  final TaskScheduler _taskScheduler;
  
  TaskController(this._taskService, this._taskScheduler);
  
  Future<void> createTask(
      String title, 
      String description, 
      DateTime dueDate, 
      String priorityStr, 
      String tags) async {
    
    final priority = priorityStr.toPriority();
    final tagList = StringUtils.parseTags(tags);
    
    await _taskService.createTask(
      title, 
      description, 
      dueDate, 
      priority, 
      tagList
    );
  }
  
  Future<void> updateTask(
      String id,
      String title, 
      String description, 
      DateTime dueDate, 
      String priorityStr, 
      String tags) async {
    
    final task = await _taskService.getTaskById(id);
    if (task == null) {
      throw TaskException('Task with ID $id not found');
    }
    
    final priority = priorityStr.toPriority();
    final tagList = StringUtils.parseTags(tags);
    
    final updatedTask = task.copyWith(
      title: title,
      description: description,
      dueDate: dueDate,
      priority: priority,
      tags: tagList,
    );
    
    await _taskService.updateTask(updatedTask);
  }
  
  Future<void> deleteTask(String id) async {
    await _taskService.deleteTask(id);
  }
  
  Future<void> toggleTaskCompletion(String id) async {
    await _taskService.toggleTaskCompletion(id);
  }
  
  Future<List<TaskViewModel>> getAllTasks() async {
    final tasks = await _taskService.getAllTasks();
    return tasks.map((task) => TaskViewModel.fromDomain(task)).toList();
  }
  
  Future<List<TaskViewModel>> getCompletedTasks() async {
    final tasks = await _taskService.getAllTasks();
    final completedTasks = tasks.where((task) => task.isCompleted).toList();
    return completedTasks.map((task) => TaskViewModel.fromDomain(task)).toList();
  }
  
  Future<List<TaskViewModel>> getActiveTasks() async {
    final tasks = await _taskService.getAllTasks();
    final activeTasks = tasks.where((task) => !task.isCompleted).toList();
    return activeTasks.map((task) => TaskViewModel.fromDomain(task)).toList();
  }
  
  Future<List<TaskViewModel>> searchTasks(String query) async {
    final tasks = await _taskService.searchTasks(query);
    return tasks.map((task) => TaskViewModel.fromDomain(task)).toList();
  }
  
  Future<List<TaskViewModel>> getTasksByPriority(String priorityStr) async {
    final priority = priorityStr.toPriority();
    final tasks = await _taskService.getTasksByPriority(priority);
    return tasks.map((task) => TaskViewModel.fromDomain(task)).toList();
  }
  
  Future<List<TaskViewModel>> getTasksByTag(String tag) async {
    final tasks = await _taskService.getTasksByTag(tag);
    return tasks.map((task) => TaskViewModel.fromDomain(task)).toList();
  }
  
  Future<List<TaskViewModel>> getScheduledTasks() async {
    final tasks = await _taskScheduler.getScheduledTasks();
    return tasks.map((task) => TaskViewModel.fromDomain(task)).toList();
  }
  
  Future<List<TaskViewModel>> getTasksDueSoon({int days = 3}) async {
    final tasks = await _taskScheduler.getTasksDueSoon(days: days);
    return tasks.map((task) => TaskViewModel.fromDomain(task)).toList();
  }
  
  Future<List<TaskViewModel>> getOverdueTasks() async {
    final tasks = await _taskScheduler.getOverdueTasks();
    return tasks.map((task) => TaskViewModel.fromDomain(task)).toList();
  }
}