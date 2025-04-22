import 'dart:io';
import 'package:logging/logging.dart';
import 'dart:math' as math;
import 'package:intl/intl.dart';

import 'package:taskmanagementsystem/Core/costants/app_constants.dart';
import 'package:taskmanagementsystem/Core/error/exceptions.dart';
import 'package:taskmanagementsystem/Core/utils/date_utils.dart';
import 'package:taskmanagementsystem/Presentation/controllers/task_controllers.dart';
import 'package:taskmanagementsystem/Presentation/view_models/task_view_model.dart';

// ANSI color codes
class AnsiColor {
  static const String reset = '\x1B[0m';
  static const String black = '\x1B[30m';
  static const String red = '\x1B[31m';
  static const String green = '\x1B[32m';
  static const String yellow = '\x1B[33m';
  static const String blue = '\x1B[34m';
  static const String magenta = '\x1B[35m';
  static const String cyan = '\x1B[36m';
  static const String white = '\x1B[37m';
  static const String brightBlack = '\x1B[90m';
  static const String brightRed = '\x1B[91m';
  static const String brightGreen = '\x1B[92m';
  static const String brightYellow = '\x1B[93m';
  static const String brightBlue = '\x1B[94m';
  static const String brightMagenta = '\x1B[95m';
  static const String brightCyan = '\x1B[96m';
  static const String brightWhite = '\x1B[97m';
  
  // Background colors
  static const String bgBlack = '\x1B[40m';
  static const String bgRed = '\x1B[41m';
  static const String bgGreen = '\x1B[42m';
  static const String bgYellow = '\x1B[43m';
  static const String bgBlue = '\x1B[44m';
  static const String bgMagenta = '\x1B[45m';
  static const String bgCyan = '\x1B[46m';
  static const String bgWhite = '\x1B[47m';
  
  // Text styles
  static const String bold = '\x1B[1m';
  static const String dim = '\x1B[2m';
  static const String italic = '\x1B[3m';
  static const String underline = '\x1B[4m';
}

class CustomLogPrinter {
  final bool useColors;
  
  CustomLogPrinter({this.useColors = true});
  
  void log(Level level, String message) {
    String prefix = '';
    String suffix = '';
    
    if (useColors) {
      switch (level.name) {
        case 'INFO':
          prefix = AnsiColor.cyan;
          break;
        case 'WARNING':
          prefix = AnsiColor.yellow;
          break;
        case 'SEVERE':
          prefix = AnsiColor.red;
          break;
        default:
          prefix = AnsiColor.white;
      }
      suffix = AnsiColor.reset;
    }
    
    stdout.writeln('$prefix$message$suffix');
  }
}

class TaskCliApp {
  final TaskController _taskController;
  final Logger _logger = Logger('TaskCliApp');
  final CustomLogPrinter _printer = CustomLogPrinter();
  final bool _useColors = true;
  
  TaskCliApp(this._taskController) {
    // Initialize logging
    Logger.root.level = Level.INFO;
    Logger.root.onRecord.listen((record) {
      _printer.log(record.level, record.message);
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
    
    _logger.info('${AnsiColor.green}${AnsiColor.bold}\nThank you for using ${AppConstants.appName}!\n${AnsiColor.reset}');
  }
  
  void _printWelcomeMessage() {
    final appNameDisplay = _useColors 
      ? '${AnsiColor.brightCyan}${AnsiColor.bold}${AppConstants.appName}${AnsiColor.reset}'
      : AppConstants.appName;
    
    final versionDisplay = _useColors
      ? '${AnsiColor.brightYellow}v${AppConstants.appVersion}${AnsiColor.reset}'
      : 'v${AppConstants.appVersion}';
    
    _logger.info('\n╭${'═' * (AppConstants.appName.length + 15)}╮');
    _logger.info('│  $appNameDisplay $versionDisplay  │');
    _logger.info('╰${'═' * (AppConstants.appName.length + 15)}╯\n');
    _logger.info('Type "${_colorText("help", AnsiColor.green)}" to see available commands.\n');
  }
  
  void _displayMenu() {
    stdout.write('${AnsiColor.brightWhite}${AnsiColor.bold}What would you like to do?${AnsiColor.reset}\n${AnsiColor.brightBlue}>${AnsiColor.reset} ');
  }
  
  String _colorText(String text, String color) {
    return _useColors ? '$color$text${AnsiColor.reset}' : text;
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
    String listTitle;
    
    switch (filter) {
      case 'all':
        tasks = await _taskController.getAllTasks();
        listTitle = 'All Tasks';
        break;
      case 'active':
        tasks = await _taskController.getActiveTasks();
        listTitle = 'Active Tasks';
        break;
      case 'completed':
        tasks = await _taskController.getCompletedTasks();
        listTitle = 'Completed Tasks';
        break;
      case 'priority':
        if (args.length < 2) {
          _logger.warning('Usage: list priority <low|medium|high|urgent>');
          return;
        }
        tasks = await _taskController.getTasksByPriority(args[1]);
        listTitle = '${args[1].toUpperCase()} Priority Tasks';
        break;
      case 'tag':
        if (args.length < 2) {
          _logger.warning('Usage: list tag <tag-name>');
          return;
        }
        tasks = await _taskController.getTasksByTag(args[1]);
        listTitle = 'Tasks with Tag: ${args[1]}';
        break;
      default:
        _logger.warning('Unknown filter: $filter. Available filters: all, active, completed, priority, tag');
        return;
    }
    
    _displayTasksInTable(tasks, listTitle);
  }
  
  String _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'urgent':
        return AnsiColor.brightRed;
      case 'high':
        return AnsiColor.red;
      case 'medium':
        return AnsiColor.yellow;
      case 'low':
        return AnsiColor.green;
      default:
        return AnsiColor.white;
    }
  }
  
  String _getPrioritySymbol(String priority) {
    switch (priority.toLowerCase()) {
      case 'urgent':
        return '🔴';
      case 'high':
        return '🟠';
      case 'medium':
        return '⏺️';
      case 'low':
        return '🟢';
      default:
        return '⚪';
    }
  }
  
  String _getStatusSymbol(bool isCompleted) {
    return isCompleted ? '${AnsiColor.green}✓${AnsiColor.reset}' : '❏';
  }
  
  String _getDueDateColor(DateTime dueDate) {
    final now = DateTime.now();
    final difference = dueDate.difference(now).inDays;
    
    if (difference < 0) {
      return AnsiColor.brightRed; // Overdue
    } else if (difference <= 2) {
      return AnsiColor.red; // Due soon
    } else if (difference <= 7) {
      return AnsiColor.yellow; // Due this week
    } else {
      return AnsiColor.green; // Due later
    }
  }
  
  void _displayTasksInTable(List<TaskViewModel> tasks, String title) {
    if (tasks.isEmpty) {
      _logger.info('\n${AnsiColor.yellow}No tasks found.${AnsiColor.reset}\n');
      return;
    }
    
    // Find max lengths for better formatting
    int maxIdLength = 2;
    int maxTitleLength = 5;
    int maxDateLength = 8;
    int maxPriorityLength = 8;
    int maxTagsLength = 4;
    
    for (var task in tasks) {
      maxIdLength = math.max(maxIdLength, task.id.length);
      maxTitleLength = math.max(maxTitleLength, task.title.length);
      maxDateLength = math.max(maxDateLength, task.formattedDueDate.length);
      maxPriorityLength = math.max(maxPriorityLength, task.priorityName.length);
      maxTagsLength = math.max(maxTagsLength, task.formattedTags.length);
    }
    
    // Cap lengths to reasonable values
    maxTitleLength = math.min(maxTitleLength, 30);
    maxTagsLength = math.min(maxTagsLength, 20);
    
    // Total width calculation
    final totalWidth = maxIdLength + maxTitleLength + maxDateLength + maxPriorityLength + maxTagsLength + 17;
    
    _logger.info('\n${AnsiColor.brightCyan}${AnsiColor.bold}$title (${tasks.length})${AnsiColor.reset}');
    _logger.info('╭${'─' * totalWidth}╮');
    
    // Header
    _logger.info('│ ${AnsiColor.bold}ID${' ' * (maxIdLength - 2)} │ Title${' ' * (maxTitleLength - 5)} │ Due Date${' ' * (maxDateLength - 8)} │ Priority${' ' * (maxPriorityLength - 8)} │ Status │ Tags${' ' * (maxTagsLength - 4)} │${AnsiColor.reset}');
    _logger.info('├${'─' * maxIdLength}─┼${'─' * maxTitleLength}─┼${'─' * maxDateLength}─┼${'─' * maxPriorityLength}─┼${'─' * 8}─┼${'─' * maxTagsLength}─┤');
    
    // Tasks
    for (var task in tasks) {
      final statusSymbol = _getStatusSymbol(task.isCompleted);
      final priorityColor = _getPriorityColor(task.priorityName);
      final dueDateColor = _getDueDateColor(task.dueDate);
      
      String title = task.title;
      if (title.length > maxTitleLength) {
        title = '${title.substring(0, maxTitleLength - 3)}...';
      }
      
      String tags = task.formattedTags;
      if (tags.length > maxTagsLength) {
        tags = '${tags.substring(0, maxTagsLength - 3)}...';
      }
      
      _logger.info(
        '│ ${task.id}${' ' * (maxIdLength - task.id.length)} │ ${task.isCompleted ? AnsiColor.dim : ''}$title${' ' * (maxTitleLength - title.length)} │ $dueDateColor${task.formattedDueDate}${AnsiColor.reset}${' ' * (maxDateLength - task.formattedDueDate.length)} │ $priorityColor${_getPrioritySymbol(task.priorityName)} ${task.priorityName}${AnsiColor.reset}${' ' * (maxPriorityLength - task.priorityName.length)} │ $statusSymbol       │ ${AnsiColor.brightBlue}$tags${AnsiColor.reset}${' ' * (maxTagsLength - tags.length)} │${task.isCompleted ? AnsiColor.reset : ''}'
      );
    }
    
    _logger.info('╰${'─' * maxIdLength}─┴${'─' * maxTitleLength}─┴${'─' * maxDateLength}─┴${'─' * maxPriorityLength}─┴${'─' * 8}─┴${'─' * maxTagsLength}─╯\n');
  }
  
  Future<void> _addTask() async {
    _logger.info('\n${AnsiColor.brightYellow}${AnsiColor.bold}Create New Task${AnsiColor.reset}');
    _logger.info('╭${'─' * 40}╮');
    
    stdout.write('│ ${AnsiColor.brightWhite}Title:${AnsiColor.reset} ');
    final title = stdin.readLineSync()?.trim() ?? '';
    if (title.isEmpty) {
      _logger.warning('${AnsiColor.yellow}Title cannot be empty. Task creation cancelled.${AnsiColor.reset}');
      return;
    }
    
    stdout.write('│ ${AnsiColor.brightWhite}Description:${AnsiColor.reset} ');
    final description = stdin.readLineSync()?.trim() ?? '';
    
    DateTime? dueDate;
    while (dueDate == null) {
      stdout.write('│ ${AnsiColor.brightWhite}Due Date (YYYY-MM-DD):${AnsiColor.reset} ');
      final dueDateStr = stdin.readLineSync()?.trim() ?? '';
      
      try {
        dueDate = DateUtils.parseDate(dueDateStr);
      } catch (e) {
        _logger.warning('${AnsiColor.yellow}Invalid date format. Please use YYYY-MM-DD.${AnsiColor.reset}');
      }
    }
    
    stdout.write('│ ${AnsiColor.brightWhite}Priority (low, medium, high, urgent) [medium]:${AnsiColor.reset} ');
    final priorityStr = stdin.readLineSync()?.trim() ?? 'medium';
    
    stdout.write('│ ${AnsiColor.brightWhite}Tags (comma-separated):${AnsiColor.reset} ');
    final tags = stdin.readLineSync()?.trim() ?? '';
    
    _logger.info('╰${'─' * 40}╯');
    
    await _taskController.createTask(
      title,
      description,
      dueDate,
      priorityStr,
      tags,
    );
    
    _logger.info('\n${AnsiColor.green}${AnsiColor.bold}✓ Task created successfully!${AnsiColor.reset}\n');
  }
  
  Future<void> _updateTask(String id) async {
    try {
      final tasks = await _taskController.getAllTasks();
      final task = tasks.firstWhere(
        (t) => t.id == id,
        orElse: () => throw TaskException('Task with ID $id not found'),
      );
      
      _logger.info('\n${AnsiColor.brightYellow}${AnsiColor.bold}Update Task${AnsiColor.reset}');
      _logger.info('╭${'─' * 60}╮');
      _logger.info('│ ${AnsiColor.dim}Leave fields empty to keep current values.${AnsiColor.reset}');
      _logger.info('│');
      
      _logger.info('│ ${AnsiColor.brightCyan}Current Title:${AnsiColor.reset} ${task.title}');
      stdout.write('│ ${AnsiColor.brightWhite}New Title:${AnsiColor.reset} ');
      final titleInput = stdin.readLineSync()?.trim() ?? '';
      final title = titleInput.isEmpty ? task.title : titleInput;
      
      _logger.info('│ ${AnsiColor.brightCyan}Current Description:${AnsiColor.reset} ${task.description}');
      stdout.write('│ ${AnsiColor.brightWhite}New Description:${AnsiColor.reset} ');
      final descriptionInput = stdin.readLineSync()?.trim() ?? '';
      final description = descriptionInput.isEmpty ? task.description : descriptionInput;
      
      DateTime dueDate = task.dueDate;
      _logger.info('│ ${AnsiColor.brightCyan}Current Due Date:${AnsiColor.reset} ${task.formattedDueDate}');
      stdout.write('│ ${AnsiColor.brightWhite}New Due Date (YYYY-MM-DD):${AnsiColor.reset} ');
      final dueDateStr = stdin.readLineSync()?.trim() ?? '';
      
      if (dueDateStr.isNotEmpty) {
        try {
          dueDate = DateUtils.parseDate(dueDateStr);
        } catch (e) {
          _logger.warning('${AnsiColor.yellow}Invalid date format. Using current due date.${AnsiColor.reset}');
        }
      }
      
      _logger.info('│ ${AnsiColor.brightCyan}Current Priority:${AnsiColor.reset} ${task.priorityName}');
      stdout.write('│ ${AnsiColor.brightWhite}New Priority (low, medium, high, urgent):${AnsiColor.reset} ');
      final priorityInput = stdin.readLineSync()?.trim() ?? '';
      final priority = priorityInput.isEmpty ? task.priorityName : priorityInput;
      
      _logger.info('│ ${AnsiColor.brightCyan}Current Tags:${AnsiColor.reset} ${task.formattedTags}');
      stdout.write('│ ${AnsiColor.brightWhite}New Tags (comma-separated):${AnsiColor.reset} ');
      final tagsInput = stdin.readLineSync()?.trim() ?? '';
      final tags = tagsInput.isEmpty ? task.formattedTags : tagsInput;
      
      _logger.info('╰${'─' * 60}╯');
      
      await _taskController.updateTask(
        id,
        title,
        description,
        dueDate,
        priority,
        tags,
      );
      
      _logger.info('\n${AnsiColor.green}${AnsiColor.bold}✓ Task updated successfully!${AnsiColor.reset}\n');
    } catch (e) {
      _logger.severe('${AnsiColor.red}Error: ${e.toString()}${AnsiColor.reset}');
    }
  }
  
  Future<void> _deleteTask(String id) async {
    try {
      final task = await _taskController.getTaskById(id);
 
      
      _logger.info('\n${AnsiColor.red}${AnsiColor.bold}⚠ Delete Task${AnsiColor.reset}');
      _logger.info('╭${'─' * 60}╮');
      _logger.info('│ You are about to delete the following task:');
      _logger.info('│');
      _logger.info('│ ${AnsiColor.brightWhite}Title:${AnsiColor.reset} ${task.title}');
      _logger.info('│ ${AnsiColor.brightWhite}Due Date:${AnsiColor.reset} ${DateFormat('yyyy-MM-dd').format(task.dueDate)}');
      _logger.info('│');
      stdout.write('│ ${AnsiColor.red}Are you sure you want to delete this task? (y/n):${AnsiColor.reset} ');
      
      final confirm = stdin.readLineSync()?.trim().toLowerCase() ?? '';
      _logger.info('╰${'─' * 60}╯');
      
      if (confirm == 'y' || confirm == 'yes') {
        await _taskController.deleteTask(id);
        _logger.info('\n${AnsiColor.green}${AnsiColor.bold}✓ Task deleted successfully!${AnsiColor.reset}\n');
      } else {
        _logger.info('\n${AnsiColor.yellow}Task deletion cancelled.${AnsiColor.reset}\n');
      }
    } catch (e) {
      _logger.severe('${AnsiColor.red}Error: ${e.toString()}${AnsiColor.reset}');
    }
  }
  
  Future<void> _toggleTaskCompletion(String id) async {
    try {
      final task = await _taskController.getTaskById(id);
      // Task existence is guaranteed; no need for null check.
      
      await _taskController.toggleTaskCompletion(id);
      
      final updatedTask = await _taskController.getTaskById(id);
      final status = updatedTask.isCompleted ? 'completed' : 'active';
      _logger.info('\n${AnsiColor.green}${AnsiColor.bold}✓ Task "${task.title}" marked as $status!${AnsiColor.reset}\n');
    } catch (e) {
      _logger.severe('${AnsiColor.red}Error: ${e.toString()}${AnsiColor.reset}');
    }
  }
  
  Future<void> _searchTasks(String query) async {
    final tasks = await _taskController.searchTasks(query);
    
    _logger.info('\n${AnsiColor.brightCyan}${AnsiColor.bold}Search Results for "${AnsiColor.brightYellow}$query${AnsiColor.brightCyan}"${AnsiColor.reset}');
    _displayTasksInTable(tasks, 'Search Results');
  }
  
  Future<void> _showScheduledTasks() async {
    final tasks = await _taskController.getScheduledTasks();
    _displayTasksInTable(tasks, 'Scheduled Tasks');
  }
  
  Future<void> _showTasksDueSoon() async {
    final tasks = await _taskController.getTasksDueSoon();
    _displayTasksInTable(tasks, 'Tasks Due Soon');
  }
  
  Future<void> _showOverdueTasks() async {
    final tasks = await _taskController.getOverdueTasks();
    _displayTasksInTable(tasks, 'Overdue Tasks');
  }
  
  void _showHelp() {
    _logger.info('\n${AnsiColor.brightCyan}${AnsiColor.bold}Available Commands${AnsiColor.reset}');
    _logger.info('╭${'─' * 60}╮');
    _logger.info('│ ${AnsiColor.brightYellow}list${AnsiColor.reset} [all|active|completed|priority <level>|tag <tag>]');
    _logger.info('│    - List tasks with optional filters');
    _logger.info('│');
    _logger.info('│ ${AnsiColor.brightGreen}add${AnsiColor.reset}');
    _logger.info('│    - Add a new task');
    _logger.info('│');
    _logger.info('│ ${AnsiColor.brightBlue}update${AnsiColor.reset} <task-id>');
    _logger.info('│    - Update an existing task');
    _logger.info('│');
    _logger.info('│ ${AnsiColor.brightRed}delete${AnsiColor.reset} <task-id>');
    _logger.info('│    - Delete a task');
    _logger.info('│');
    _logger.info('│ ${AnsiColor.brightMagenta}complete${AnsiColor.reset} <task-id>');
    _logger.info('│    - Toggle task completion status');
    _logger.info('│');
    _logger.info('│ ${AnsiColor.brightCyan}search${AnsiColor.reset} <query>');
    _logger.info('│    - Search for tasks by title, description, or tags');
    _logger.info('│');
    _logger.info('│ ${AnsiColor.yellow}schedule${AnsiColor.reset}');
    _logger.info('│    - Show tasks scheduled by priority and due date');
    _logger.info('│');
    _logger.info('│ ${AnsiColor.yellow}due-soon${AnsiColor.reset}');
    _logger.info('│    - Show tasks due in the next few days');
    _logger.info('│');
    _logger.info('│ ${AnsiColor.red}overdue${AnsiColor.reset}');
    _logger.info('│    - Show overdue tasks');
    _logger.info('│');
    _logger.info('│ ${AnsiColor.green}help${AnsiColor.reset}');
    _logger.info('│    - Show this help message');
    _logger.info('│');
    _logger.info('│ ${AnsiColor.brightBlack}exit${AnsiColor.reset} / ${AnsiColor.brightBlack}quit${AnsiColor.reset}');
    _logger.info('│    - Exit the application');
    _logger.info('╰${'─' * 60}╯\n');
  }
}