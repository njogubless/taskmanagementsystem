import 'dart:io';
import 'package:logging/logging.dart';

import 'package:taskmanagementsystem/Core/costants/app_constants.dart';
import 'package:taskmanagementsystem/Core/error/exceptions.dart';
import 'package:taskmanagementsystem/Core/utils/date_utils.dart';
import 'package:taskmanagementsystem/Presentation/controllers/task_controllers.dart';
import 'package:taskmanagementsystem/Presentation/view_models/task_view_model.dart';

class TaskCliApp {
  final TaskController _taskController;
  final Logger _logger = Logger('TaskCliApp');
  
  TaskCliApp(this._taskController) {
    // Initialize logging
    Logger.root.level = Level.INFO;
    Logger.root.onRecord.listen((record) {
      stdout.writeln('${record.level.name}: ${record.message}');
    });
  }
  
  void run() async {
    _printWelcomeMessage();
    
    bool running = true;
    while (running) {
      _displayMenu();
      
      final input = stdin.readLineSync()?.trim() ?? '';
      
      try {
        running = await _processCommand(input);
      } catch (e) {
        _logger.severe('Error: ${e.toString()}');
      }
    }
    
    _logger.info('\nThank you for using ${AppConstants.appName}!\n');
  }
  
  void _printWelcomeMessage() {
    _logger.info('\n========================================');
    _logger.info('  ${AppConstants.appName} v${AppConstants.appVersion}');
    _logger.info('========================================\n');
    _logger.info('Type "help" to see available commands.\n');
  }
  
  void _displayMenu() {
    stdout.write('What would you like to do?\n> ');
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
          _logger.warning('Usage: update <task-id>');
        } else {
          await _updateTask(parts[1]);
        }
        break;
      case 'delete':
        if (parts.length < 2) {
          _logger.warning('Usage: delete <task-id>');
        } else {
          await _deleteTask(parts[1]);
        }
        break;
      case 'complete':
        if (parts.length < 2) {
          _logger.warning('Usage: complete <task-id>');
        } else {
          await _toggleTaskCompletion(parts[1]);
        }
        break;
      case 'search':
        if (parts.length < 2) {
          _logger.warning('Usage: search <query>');
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
        _logger.warning('Unknown command. Type "help" to see available commands.');
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
          _logger.warning('Usage: list priority <low|medium|high|urgent>');
          return;
        }
        tasks = await _taskController.getTasksByPriority(args[1]);
        break;
      case 'tag':
        if (args.length < 2) {
          _logger.warning('Usage: list tag <tag-name>');
          return;
        }
        tasks = await _taskController.getTasksByTag(args[1]);
        break;
      default:
        _logger.warning('Unknown filter: $filter. Available filters: all, active, completed, priority, tag');
        return;
    }
    
    _displayTasks(tasks);
  }
  
  void _displayTasks(List<TaskViewModel> tasks) {
    if (tasks.isEmpty) {
      _logger.info('\nNo tasks found.\n');
      return;
    }
    
    _logger.info('\nFound ${tasks.length} tasks:\n');
    _logger.info('ID | Title | Due Date | Priority | Status | Tags');
    _logger.info('---------------------------------------------------------');
    
    for (var task in tasks) {
      final status = task.isCompleted ? '✓' : ' ';
      _logger.info('${task.id} | ${task.title} | ${task.formattedDueDate} | ${task.prioritySymbol} ${task.priorityName} | [$status] | ${task.formattedTags}');
    }
    
    _logger.info('\n');
  }
  
  Future<void> _addTask() async {
    _logger.info('\nEnter task details:');
    
    stdout.write('Title: ');
    final title = stdin.readLineSync()?.trim() ?? '';
    if (title.isEmpty) {
      _logger.warning('Title cannot be empty. Task creation cancelled.');
      return;
    }
    
    stdout.write('Description: ');
    final description = stdin.readLineSync()?.trim() ?? '';
    
    DateTime? dueDate;
    while (dueDate == null) {
      stdout.write('Due Date (YYYY-MM-DD): ');
      final dueDateStr = stdin.readLineSync()?.trim() ?? '';
      
      try {
        dueDate = DateUtils.parseDate(dueDateStr);
      } catch (e) {
        _logger.warning('Invalid date format. Please use YYYY-MM-DD.');
      }
    }
    
    stdout.write('Priority (low, medium, high, urgent) [medium]: ');
    final priorityStr = stdin.readLineSync()?.trim() ?? 'medium';
    
    stdout.write('Tags (comma-separated): ');
    final tags = stdin.readLineSync()?.trim() ?? '';
    
    await _taskController.createTask(
      title,
      description,
      dueDate,
      priorityStr,
      tags,
    );
    
    _logger.info('\nTask created successfully!\n');
  }
  
  Future<void> _updateTask(String id) async {
    final tasks = await _taskController.getAllTasks();
    final task = tasks.firstWhere(
      (t) => t.id == id,
      orElse: () => throw TaskException('Task with ID $id not found'),
    );
    
    _logger.info('\nUpdating task: ${task.title}');
    _logger.info('Leave fields empty to keep current values.\n');
    
    stdout.write('Title [${task.title}]: ');
    final titleInput = stdin.readLineSync()?.trim() ?? '';
    final title = titleInput.isEmpty ? task.title : titleInput;
    
    stdout.write('Description [${task.description}]: ');
    final descriptionInput = stdin.readLineSync()?.trim() ?? '';
    final description = descriptionInput.isEmpty ? task.description : descriptionInput;
    
    DateTime dueDate = task.dueDate;
    stdout.write('Due Date (YYYY-MM-DD) [${task.formattedDueDate}]: ');
    final dueDateStr = stdin.readLineSync()?.trim() ?? '';
    
    if (dueDateStr.isNotEmpty) {
      try {
        dueDate = DateUtils.parseDate(dueDateStr);
      } catch (e) {
        _logger.warning('Invalid date format. Using current due date.');
      }
    }
    
    stdout.write('Priority (low, medium, high, urgent) [${task.priorityName}]: ');
    final priorityInput = stdin.readLineSync()?.trim() ?? '';
    final priority = priorityInput.isEmpty ? task.priorityName : priorityInput;
    
    stdout.write('Tags (comma-separated) [${task.formattedTags}]: ');
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
    
    _logger.info('\nTask updated successfully!\n');
  }
  
  Future<void> _deleteTask(String id) async {
    stdout.write('\nAre you sure you want to delete task with ID $id? (y/n): ');
    final confirm = stdin.readLineSync()?.trim().toLowerCase() ?? '';
    
    if (confirm == 'y' || confirm == 'yes') {
      await _taskController.deleteTask(id);
      _logger.info('\nTask deleted successfully!\n');
    } else {
      _logger.info('\nTask deletion cancelled.\n');
    }
  }
  
  Future<void> _toggleTaskCompletion(String id) async {
    await _taskController.toggleTaskCompletion(id);
    _logger.info('\nTask completion status toggled!\n');
  }
  
  Future<void> _searchTasks(String query) async {
    final tasks = await _taskController.searchTasks(query);
    
    _logger.info('\nSearch results for "$query":\n');
    _displayTasks(tasks);
  }
  
  Future<void> _showScheduledTasks() async {
    final tasks = await _taskController.getScheduledTasks();
    
    _logger.info('\nTasks scheduled by priority and due date:\n');
    _displayTasks(tasks);
  }
  
  Future<void> _showTasksDueSoon() async {
    final tasks = await _taskController.getTasksDueSoon();
    
    _logger.info('\nTasks due in the next ${AppConstants.defaultDueSoonDays} days:\n');
    _displayTasks(tasks);
  }
  
  Future<void> _showOverdueTasks() async {
    final tasks = await _taskController.getOverdueTasks();
    
    _logger.info('\nOverdue tasks:\n');
    _displayTasks(tasks);
  }
  
  void _showHelp() {
    _logger.info('\nAvailable commands:');
    _logger.info('  list [all|active|completed|priority <level>|tag <tag>]');
    _logger.info('  add                   - Add a new task');
    _logger.info('  update <task-id>      - Update an existing task');
    _logger.info('  delete <task-id>      - Delete a task');
    _logger.info('  complete <task-id>    - Toggle task completion status');
    _logger.info('  search <query>        - Search for tasks');
    _logger.info('  schedule              - Show tasks scheduled by priority and due date');
    _logger.info('  due-soon              - Show tasks due in the next few days');
    _logger.info('  overdue               - Show overdue tasks');
    _logger.info('  help                  - Show this help message');
    _logger.info('  exit/quit             - Exit the application\n');
  }
}