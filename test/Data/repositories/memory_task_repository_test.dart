import 'package:flutter_test/flutter_test.dart';
import 'package:taskmanagementsystem/Core/error/exceptions.dart';
import 'package:taskmanagementsystem/Data/repository/memory_task_repository.dart';
import 'package:taskmanagementsystem/Domain/entities/task.dart';

void main() {
  late InMemoryTaskRepository repository;
  
  setUp(() {
    repository = InMemoryTaskRepository();
  });
  
  group('InMemoryTaskRepository', () {
    test('should start with empty task list', () async {
      // Act
      final tasks = await repository.getAllTasks();
      
      // Assert
      expect(tasks, isEmpty);
    });
    
    test('should add and retrieve a task', () async {
      // Arrange
      final task = Task(
        id: '1',
        title: 'Test Task',
        description: 'Test Description',
        dueDate: DateTime.now().add(const Duration(days: 1)),
        priority: Priority.medium,
        tags: ['test'],
      );
      
      // Act
      await repository.addTask(task);
      final retrievedTask = await repository.getTaskById('1');
      
      // Assert
      expect(retrievedTask, isNotNull);
      expect(retrievedTask?.id, task.id);
      expect(retrievedTask?.title, task.title);
    });
    
    test('should update a task', () async {
      // Arrange
      final task = Task(
        id: '1',
        title: 'Test Task',
        description: 'Test Description',
        dueDate: DateTime.now().add(const Duration(days: 1)),
        priority: Priority.medium,
        tags: ['test'],
      );
      
      await repository.addTask(task);
      
      final updatedTask = task.copyWith(
        title: 'Updated Task',
        description: 'Updated Description',
      );
      
      // Act
      await repository.updateTask(updatedTask);
      final retrievedTask = await repository.getTaskById('1');
      
      // Assert
      expect(retrievedTask?.title, 'Updated Task');
      expect(retrievedTask?.description, 'Updated Description');
    });
    
    test('should delete a task', () async {
      // Arrange
      final task = Task(
        id: '1',
        title: 'Test Task',
        description: 'Test Description',
        dueDate: DateTime.now().add(const Duration(days: 1)),
        priority: Priority.medium,
        tags: ['test'],
      );
      
      await repository.addTask(task);
      
      // Act
      await repository.deleteTask('1');
      final retrievedTask = await repository.getTaskById('1');
      
      // Assert
      expect(retrievedTask, isNull);
    });
    
    test('should throw exception when adding task with duplicate ID', () async {
      // Arrange
      final task = Task(
        id: '1',
        title: 'Test Task',
        description: 'Test Description',
        dueDate: DateTime.now().add(const Duration(days: 1)),
        priority: Priority.medium,
        tags: ['test'],
      );
      
      await repository.addTask(task);
      
      // Act & Assert
      expect(
        () => repository.addTask(task),
        throwsA(isA<TaskException>()),
      );
    });
    
    test('should throw exception when updating non-existent task', () async {
      // Arrange
      final task = Task(
        id: '1',
        title: 'Test Task',
        description: 'Test Description',
        dueDate: DateTime.now().add(const Duration(days: 1)),
        priority: Priority.medium,
        tags: ['test'],
      );
      
      // Act & Assert
      expect(
        () => repository.updateTask(task),
        throwsA(isA<TaskException>()),
      );
    });
    
    test('should throw exception when deleting non-existent task', () async {
      // Act & Assert
      expect(
        () => repository.deleteTask('1'),
        throwsA(isA<TaskException>()),
      );
    });
    
    test('should search tasks by title', () async {
      // Arrange
      final task1 = Task(
        id: '1',
        title: 'Flutter Development',
        description: 'Learn Flutter',
        dueDate: DateTime.now().add(const Duration(days: 1)),
        priority: Priority.medium,
        tags: ['flutter', 'mobile'],
      );
      
      final task2 = Task(
        id: '2',
        title: 'Web Development',
        description: 'Learn React',
        dueDate: DateTime.now().add(const Duration(days: 2)),
        priority: Priority.high,
        tags: ['web', 'react'],
      );
      
      await repository.addTask(task1);
      await repository.addTask(task2);
      
      // Act
      final results = await repository.searchTasks('flutter');
      
      // Assert
      expect(results.length, 1);
      expect(results[0].id, '1');
    });
  });
}
