import 'package:flutter_test/flutter_test.dart';
import 'package:taskmanagementsystem/Application/services/task_service_impl.dart';
import 'package:taskmanagementsystem/Data/repository/memory_task_repository.dart';
import 'package:taskmanagementsystem/Domain/entities/task.dart';
import 'package:taskmanagementsystem/Domain/repository/task_repository.dart';
import 'package:taskmanagementsystem/Domain/usecases/task_usecases.dart';

void main() {
  late TaskRepository repository;
  late TaskService taskService;
  
  setUp(() {
    repository = InMemoryTaskRepository();
    
    final getAllTasksUseCase = GetAllTasksUseCase(repository);
    final getTaskByIdUseCase = GetTaskByIdUseCase(repository);
    final createTaskUseCase = CreateTaskUseCase(repository);
    final updateTaskUseCase = UpdateTaskUseCase(repository);
    final deleteTaskUseCase = DeleteTaskUseCase(repository);
    final searchTasksUseCase = SearchTasksUseCase(repository);
    final toggleTaskCompletionUseCase = ToggleTaskCompletionUseCase(repository);
    final getTasksByPriorityUseCase = GetTasksByPriorityUseCase(repository);
    final getTasksByDueDateUseCase = GetTasksByDueDateUseCase(repository);
    final getTasksByTagUseCase = GetTasksByTagUseCase(repository);
    
    taskService = TaskServiceImpl(
      getAllTasksUseCase: getAllTasksUseCase,
      getTaskByIdUseCase: getTaskByIdUseCase,
      createTaskUseCase: createTaskUseCase,
      updateTaskUseCase: updateTaskUseCase,
      deleteTaskUseCase: deleteTaskUseCase,
      searchTasksUseCase: searchTasksUseCase,
      toggleTaskCompletionUseCase: toggleTaskCompletionUseCase,
      getTasksByPriorityUseCase: getTasksByPriorityUseCase,
      getTasksByDueDateUseCase: getTasksByDueDateUseCase,
      getTasksByTagUseCase: getTasksByTagUseCase,
    );
  });
  
  group('TaskServiceImpl', () {
    test('should create and retrieve a task', () async {
      // Arrange
      const title = 'Service Test Task';
      const description = 'Testing task service';
      final dueDate = DateTime.now().add(const Duration(days: 1));
      const priority = Priority.high;
      final tags = ['test', 'service'];
      
      // Act
      await taskService.createTask(
        title,
        description,
        dueDate,
        priority,
        tags,
      );
      
      final tasks = await taskService.getAllTasks();
      
      // Assert
      expect(tasks.length, 1);
      expect(tasks[0].title, title);
      expect(tasks[0].description, description);
      expect(tasks[0].priority, priority);
      expect(tasks[0].tags, tags);
    });
    
    test('should toggle task completion', () async {
      // Arrange
      await taskService.createTask(
        'Task to toggle',
        'Description',
        DateTime.now().add(const Duration(days: 1)),
        Priority.medium,
        ['toggle'],
      );
      
      final tasks = await taskService.getAllTasks();
      final taskId = tasks[0].id;
      
      // Act - Toggle to completed
      await taskService.toggleTaskCompletion(taskId);
      
      // Assert
      final updatedTask = await taskService.getTaskById(taskId);
      expect(updatedTask?.isCompleted, true);
      
      // Act - Toggle back to incomplete
      await taskService.toggleTaskCompletion(taskId);
      
      // Assert
      final toggledBackTask = await taskService.getTaskById(taskId);
      expect(toggledBackTask?.isCompleted, false);
    });
    
    test('should get tasks by priority', () async {
      // Arrange
      await taskService.createTask(
        'Low Priority Task',
        'Description',
        DateTime.now().add(const Duration(days: 1)),
        Priority.low,
        ['low'],
      );
      
      await taskService.createTask(
        'High Priority Task',
        'Description',
        DateTime.now().add(const Duration(days: 1)),
        Priority.high,
        ['high'],
      );
      
      await taskService.createTask(
        'Another High Priority Task',
        'Description',
        DateTime.now().add(const Duration(days: 2)),
        Priority.high,
        ['high'],
      );
      
      // Act
      final highPriorityTasks = await taskService.getTasksByPriority(Priority.high);
      
      // Assert
      expect(highPriorityTasks.length, 2);
      expect(highPriorityTasks[0].title, 'High Priority Task');
      expect(highPriorityTasks[1].title, 'Another High Priority Task');
    });
    
    test('should get tasks by due date range', () async {
      // Arrange
      final now = DateTime.now();
      final tomorrow = now.add(const Duration(days: 1));
      final nextWeek = now.add(const Duration(days: 7));
      final nextMonth = now.add(const Duration(days: 30));
      
      await taskService.createTask(
        'Tomorrow Task',
        'Description',
        tomorrow,
        Priority.medium,
        ['soon'],
      );
      
      await taskService.createTask(
        'Next Week Task',
        'Description',
        nextWeek,
        Priority.medium,
        ['soon'],
      );
      
      await taskService.createTask(
        'Next Month Task',
        'Description',
        nextMonth,
        Priority.medium,
        ['later'],
      );
      
      // Act
      final soonTasks = await taskService.getTasksByDueDate(
        startDate: now,
        endDate: now.add(const Duration(days: 10)),
      );
      
      // Assert
      expect(soonTasks.length, 2);
      expect(soonTasks[0].title, 'Tomorrow Task');
      expect(soonTasks[1].title, 'Next Week Task');
    });
    
    test('should get tasks by tag', () async {
      // Arrange
      await taskService.createTask(
        'Work Task',
        'Description',
        DateTime.now().add(const Duration(days: 1)),
        Priority.high,
        ['work', 'important'],
      );
      
      await taskService.createTask(
        'Personal Task',
        'Description',
        DateTime.now().add(const Duration(days: 2)),
        Priority.medium,
        ['personal', 'important'],
      );
      
      await taskService.createTask(
        'Shopping Task',
        'Description',
        DateTime.now().add(const Duration(days: 3)),
        Priority.low,
        ['personal', 'shopping'],
      );
      
      // Act
      final importantTasks = await taskService.getTasksByTag('important');
      final personalTasks = await taskService.getTasksByTag('personal');
      
      // Assert
      expect(importantTasks.length, 2);
      expect(personalTasks.length, 2);
      expect(importantTasks[0].title, 'Work Task');
      expect(importantTasks[1].title, 'Personal Task');
    });
  });
}