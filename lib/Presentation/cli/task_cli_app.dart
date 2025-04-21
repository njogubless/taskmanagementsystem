class TaskCliApp {
  final TaskController _taskController;
  
  TaskCliApp(this._taskController);
  
  void run() async {
    _printWelcomeMessage();
    
    bool running = true;
    while (running) {
      _displayMenu();
      
      final input = stdin.readLineSync()?.trim() ?? '';
      
      try {
        running = await _processCommand(input);
      } catch (e) {
        print('\nError: ${e.toString()}\n');
      }
    }
    
    print('\nThank you for using ${AppConstants.appName}!\n');
  }
  
  void _printWelcomeMessage() {
    print('\n========================================');
    print('  ${AppConstants.appName} v${AppConstants.appVersion}');
    print('========================================\n');
    print('Type "help" to see available commands.\n');
  }
  
  void _displayMenu() {
    print('What would you like to do?');
    print('> ');
  }
  
  Future<bool> _processCommand(String input) async {
    final parts = input.split(' ');
    final command = parts.isNotEmpty ? parts[0].toLowerCase() : '';
    
    switch (command) {
      case 'list':
        await _listTasks(parts.sublist(1));
        break;
      case 'add':
        await _addTask();
        break;
      case 'update':
        if (parts.length < 2) {
          print('Usage: update <task-id>');
        } else {
          await _updateTask(parts[1]);
        }
        break;
      case 'delete':
        if (parts.length < 2) {
          print('Usage: delete <task-id>');
        } else {
          await _deleteTask(parts[1]);
        }
        break;
      case 'complete':
        if (parts.length < 2) {
          print('Usage: complete <task-id>');
        } else {
          await _toggleTaskCompletion(parts[1]);
        }
        break;
      case 'search':
        if (parts.length < 2) {
          print('Usage: search <query>');
        } else {
          await _searchTasks(parts.sublist(1).join(' '));
        }
        break;
      case 'schedule':
        await _showScheduledTasks();
        break;
      case 'due-soon':
        await _showTasksDueSoon();
        break;
      case 'overdue':
        await _showOverdueTasks();
        break;
      case 'help':
        _showHelp();
        break;
      case 'exit':
      case 'quit':
        return false;
      default:
        print('Unknown command. Type "help" to see available commands.');
    }
    
    return true;
  }
  
  Future<void> _listTasks(List<String> args) async {
    String filter = 'all';
    if (args.isNotEmpty) {
      filter = args[0].toLowerCase();
    }
    
    List<TaskViewModel> tasks;
    
    switch (filter) {
      case 'all':
        tasks = await _taskController.getAllTasks();
        break;
      case 'active':
        tasks = await _taskController.getActiveTasks();
        break;
      case 'completed':
        tasks = await _taskController.getCompletedTasks();
        break;
      case 'priority':
        if (args.length < 2) {
          print('Usage: list priority <low|medium|high|urgent>');
          return;
        }
        tasks = await _taskController.getTasksByPriority(args[1]);
        break;
      case 'tag':
        if (args.length < 2) {
          print('Usage: list tag <tag-name>');
          return;
        }
        tasks = await _taskController.getTasksByTag(args[1]);
        break;
      default:
        print('Unknown filter: $filter. Available filters: all, active, completed, priority, tag');
        return;
    }
    
    _displayTasks(tasks);
  }
  
  void _displayTasks(List<TaskViewModel> tasks) {
    if (tasks.isEmpty) {
      print('\nNo tasks found.\n');
      return;
    }
    
    print('\nFound ${tasks.length} tasks:\n');
    print('ID | Title | Due Date | Priority | Status | Tags');
    print('---------------------------------------------------------');
    
    for (var task in tasks) {
      final status = task.isCompleted ? '✓' : ' ';
      print('${task.id} | ${task.title} | ${task.formattedDueDate} | ${task.prioritySymbol} ${task.priorityName} | [$status] | ${task.formattedTags}');
    }
    
    print('\n');
  }
  
  Future<void> _addTask() async {
    print('\nEnter task details:');
    
    print('Title: ');
    final title = stdin.readLineSync()?.trim() ?? '';
    if (title.isEmpty) {
      print('Title cannot be empty. Task creation cancelled.');
      return;
    }
    
    print('Description: ');
    final description = stdin.readLineSync()?.trim() ?? '';
    
    DateTime? dueDate;
    while (dueDate == null) {
      print('Due Date (YYYY-MM-DD): ');
      final dueDateStr = stdin.readLineSync()?.trim() ?? '';
      
      try {
        dueDate = DateUtils.parseDate(dueDateStr);
      } catch (e) {
        print('Invalid date format. Please use YYYY-MM-DD.');
      }
    }
    
    print('Priority (low, medium, high, urgent) [medium]: ');
    final priorityStr = stdin.readLineSync()?.trim() ?? 'medium';
    
    print('Tags (comma-separated): ');
    final tags = stdin.readLineSync()?.trim() ?? '';
    
    await _taskController.createTask(
      title,
      description,
      dueDate,
      priorityStr,
      tags,
    );
    
    print('\nTask created successfully!\n');
  }
  
  Future<void> _updateTask(String id) async {
    final tasks = await _taskController.getAllTasks();
    final task = tasks.firstWhere(
      (t) => t.id == id,
      orElse: () => throw TaskException('Task with ID $id not found'),
    );
    
    print('\nUpdating task: ${task.title}');
    print('Leave fields empty to keep current values.\n');
    
    print('Title [${task.title}]: ');
    final titleInput = stdin.readLineSync()?.trim() ?? '';
    final title = titleInput.isEmpty ? task.title : titleInput;
    
    print('Description [${task.description}]: ');
    final descriptionInput = stdin.readLineSync()?.trim() ?? '';
    final description = descriptionInput.isEmpty ? task.description : descriptionInput;
    
    DateTime dueDate = task.dueDate;
    print('Due Date (YYYY-MM-DD) [${task.formattedDueDate}]: ');
    final dueDateStr = stdin.readLineSync()?.trim() ?? '';
    
    if (dueDateStr.isNotEmpty) {
      try {
        dueDate = DateUtils.parseDate(dueDateStr);
      } catch (e) {
        print('Invalid date format. Using current due date.');
      }
    }
    
    print('Priority (low, medium, high, urgent) [${task.priorityName}]: ');
    final priorityInput = stdin.readLineSync()?.trim() ?? '';
    final priority = priorityInput.isEmpty ? task.priorityName : priorityInput;
    
    print('Tags (comma-separated) [${task.formattedTags}]: ');
    final tagsInput = stdin.readLineSync()?.trim() ?? '';
    final tags = tagsInput.isEmpty ? task.formattedTags : tagsInput;
    
    await _taskController.updateTask(
      id,
      title,
      description,
      dueDate,
      priority,
      tags,
    );
    
    print('\nTask updated successfully!\n');
  }
  
  Future<void> _deleteTask(String id) async {
    print('\nAre you sure you want to delete task with ID $id? (y/n): ');
    final confirm = stdin.readLineSync()?.trim().toLowerCase() ?? '';
    
    if (confirm == 'y' || confirm == 'yes') {
      await _taskController.deleteTask(id);
      print('\nTask deleted successfully!\n');
    } else {
      print('\nTask deletion cancelled.\n');
    }
  }
  
  Future<void> _toggleTaskCompletion(String id) async {
    await _taskController.toggleTaskCompletion(id);
    print('\nTask completion status toggled!\n');
  }
  
  Future<void> _searchTasks(String query) async {
    final tasks = await _taskController.searchTasks(query);
    
    print('\nSearch results for "$query":\n');
    _displayTasks(tasks);
  }
  
  Future<void> _showScheduledTasks() async {
    final tasks = await _taskController.getScheduledTasks();
    
    print('\nTasks scheduled by priority and due date:\n');
    _displayTasks(tasks);
  }
  
  Future<void> _showTasksDueSoon() async {
    final tasks = await _taskController.getTasksDueSoon();
    
    print('\nTasks due in the next ${AppConstants.defaultDueSoonDays} days:\n');
    _displayTasks(tasks);
  }
  
  Future<void> _showOverdueTasks() async {
    final tasks = await _taskController.getOverdueTasks();
    
    print('\nOverdue tasks:\n');
    _displayTasks(tasks);
  }
  
  void _showHelp() {
    print('\nAvailable commands:');
    print('  list [all|active|completed|priority <level>|tag <tag>]');
    print('  add                   - Add a new task');
    print('  update <task-id>      - Update an existing task');
    print('  delete <task-id>      - Delete a task');
    print('  complete <task-id>    - Toggle task completion status');
    print('  search <query>        - Search for tasks');
    print('  schedule              - Show tasks scheduled by priority and due date');
    print('  due-soon              - Show tasks due in the next few days');
    print('  overdue               - Show overdue tasks');
    print('  help                  - Show this help message');
    print('  exit/quit             - Exit the application\n');
  }
}