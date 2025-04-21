import 'package:flutter_test/flutter_test.dart';
import 'package:taskmanagementsystem/Core/error/exceptions.dart';
import 'package:taskmanagementsystem/Data/repository/memory_task_repository.dart';
import 'package:taskmanagementsystem/Domain/entities/task.dart';
import 'package:taskmanagementsystem/Domain/repository/task_repository.dart';
import 'package:taskmanagementsystem/Domain/usecases/task_usecases.dart';

void main() {
  late TaskRepository repository;
  late CreateTaskUseCase createTaskUseCase;
  late GetAllTasksUseCase getAllTasksUseCase;
  late GetTaskByIdUseCase getTaskByIdUseCase;
  late UpdateTaskUseCase updateTaskUseCase;
  late DeleteTaskUseCase deleteTaskUseCase;
  late SearchTasksUseCase searchTasksUseCase;
  late ToggleTaskCompletionUseCase toggleTaskCompletionUseCase;
  
  setUp(() {
    repository = InMemoryTaskRepository();
    createTaskUseCase = CreateTaskUseCase(repository);
    getAllTasksUseCase = GetAllTasksUseCase(repository);
    getTaskByIdUseCase = GetTaskByIdUseCase(repository);
    updateTaskUseCase = UpdateTaskUseCase(repository);
    deleteTaskUseCase = DeleteTaskUseCase(repository);
    searchTasksUseCase = SearchTasksUseCase(repository);
    toggleTaskCompletionUseCase = ToggleTaskCompletionUseCase(repository);
  });
  
  group('CreateTaskUseCase', () {
    test('should create a task successfully', () async {
      // Arrange
      const title = 'Test Task';
      const description = 'Test Description';
      final dueDate = DateTime.now().add(const Duration(days: 1));
      const priority = Priority.high;
      final tags = ['test', 'task'];
      
      // Act
      await createTaskUseCase(
        title: title,
        description: description,
        dueDate: dueDate,
        priority: priority,
        tags: tags,
      );
      
      // Assert
      final tasks = await getAllTasksUseCase();
      expect(tasks.length, 1);
      expect(tasks[0].title, title);
      expect(tasks[0].description, description);
      expect(tasks[0].dueDate, dueDate);
      expect(tasks[0].priority, priority);
      expect(tasks[0].tags, tags);
      expect(tasks[0].isCompleted, false);
    });
    
    test('should throw TaskException when title is empty', () async {
      // Arrange
      const title = '';
      const description = 'Test Description';
      final dueDate = DateTime.now().add(const Duration(days: 1));
      const priority = Priority.high;
      final tags = ['test', 'task'];
      
      // Act & Assert
      expect(
        () => createTaskUseCase(
          title: title,
          description: description,
          dueDate: dueDate,
          priority: priority,
          tags: tags,
        ),
        throwsA(isA<TaskException>()),
      );
    });
  });
  
  group('GetAllTasksUseCase', () {
    test('should return empty list when no tasks exist', () async {
      // Act
      final tasks = await getAllTasksUseCase();
      
      // Assert
      expect(tasks, isEmpty);
    });
    
    test('should return all tasks', () async {
      // Arrange
      await createTaskUseCase(
        title: 'Task 1',
        description: 'Description 1',
        dueDate: DateTime.now().add(const Duration(days: 1)),
        priority: Priority.low,
        tags: ['tag1'],
      );
      
      await createTaskUseCase(
        title: 'Task 2',
        description: 'Description 2',
        dueDate: DateTime.now().add(const Duration(days: 2)),
        priority: Priority.high,
        tags: ['tag2'],
      );
      
      // Act
      final tasks = await getAllTasksUseCase();
      
      // Assert
      expect(tasks.length, 2);
      expect(tasks[0].title, 'Task 1');
      expect(tasks[1].title, 'Task 2');
    });
  });
  
  group('ToggleTaskCompletionUseCase', () {
    test('should toggle task completion status', () async {
      // Arrange
      await createTaskUseCase(
        title: 'Task 1',
        description: 'Description 1',
        dueDate: DateTime.now().add(const Duration(days: 1)),
        priority: Priority.low,
        tags: ['tag1'],
      );
      
      final tasks = await getAllTasksUseCase();
      final taskId = tasks[0].id;
      
      // Act - Toggle to completed
      await toggleTaskCompletionUseCase(taskId);
      
      // Assert
      final updatedTask = await getTaskByIdUseCase(taskId);
      expect(updatedTask?.isCompleted, true);
      
      // Act - Toggle back to incomplete
      await toggleTaskCompletionUseCase(taskId);
      
      // Assert
      final toggledBackTask = await getTaskByIdUseCase(taskId);
      expect(toggledBackTask?.isCompleted, false);
    });
    
    test('should throw TaskException when task does not exist', () async {
      // Arrange
      const nonExistentId = 'non-existent-id';
      // Act & Assert
      expect(
        () => toggleTaskCompletionUseCase(nonExistentId),
        throwsA(isA<TaskException>()),
      );
    });
  });
  
  group('SearchTasksUseCase', () {
    test('should return matching tasks by title', () async {
      // Arrange
      await createTaskUseCase(
        title: 'Study Flutter',
        description: 'Learn about widgets',
        dueDate: DateTime.now().add(const Duration(days: 1)),
        priority: Priority.medium,
        tags: ['study', 'flutter'],
      );
      
      await createTaskUseCase(
        title: 'Shopping',
        description: 'Buy groceries',
        dueDate: DateTime.now().add(const Duration(days: 2)),
        priority: Priority.low,
        tags: ['shopping'],
      );
      
      // Act
      final results = await searchTasksUseCase('flutter');
      
      // Assert
      expect(results.length, 1);
      expect(results[0].title, 'Study Flutter');
    });
    
    test('should return matching tasks by description', () async {
      // Arrange
      await createTaskUseCase(
        title: 'Study Flutter',
        description: 'Learn about widgets',
        dueDate: DateTime.now().add(const Duration(days: 1)),
        priority: Priority.medium,
        tags: ['study', 'flutter'],
      );
      
      await createTaskUseCase(
        title: 'Shopping',
        description: 'Buy groceries',
        dueDate: DateTime.now().add(const Duration(days: 2)),
        priority: Priority.low,
        tags: ['shopping'],
      );
      
      // Act
      final results = await searchTasksUseCase('groceries');
      
      // Assert
      expect(results.length, 1);
      expect(results[0].title, 'Shopping');
    });
    
    test('should return matching tasks by tags', () async {
      // Arrange
      await createTaskUseCase(
        title: 'Study Flutter',
        description: 'Learn about widgets',
        dueDate: DateTime.now().add(const Duration(days: 1)),
        priority: Priority.medium,
        tags: ['study', 'flutter'],
      );
      
      await createTaskUseCase(
        title: 'Shopping',
        description: 'Buy groceries',
        dueDate: DateTime.now().add(const Duration(days: 2)),
        priority: Priority.low,
        tags: ['shopping'],
      );
      
      // Act
      final results = await searchTasksUseCase('shopping');
      
      // Assert
      expect(results.length, 1);
      expect(results[0].title, 'Shopping');
    });
  });
}
