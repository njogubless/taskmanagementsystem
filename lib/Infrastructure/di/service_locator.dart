import 'package:taskmanagementsystem/Application/scheduler/task_scheduler.dart';
import 'package:taskmanagementsystem/Application/services/task_service_impl.dart';
import 'package:taskmanagementsystem/Core/costants/app_constants.dart';
import 'package:taskmanagementsystem/Data/datasources/file_datasource.dart';
import 'package:taskmanagementsystem/Data/repository/file_task_repository.dart';
import 'package:taskmanagementsystem/Data/repository/memory_task_repository.dart';
import 'package:taskmanagementsystem/Domain/repository/task_repository.dart';
import 'package:taskmanagementsystem/Domain/usecases/task_usecases.dart';
import 'package:taskmanagementsystem/Presentation/controllers/task_controllers.dart';

class ServiceLocator {
  // Singleton instance
  static final ServiceLocator _instance = ServiceLocator._internal();
  
  factory ServiceLocator() {
    return _instance;
  }
  
  ServiceLocator._internal();
  
  late final TaskRepository taskRepository;
  late final GetAllTasksUseCase getAllTasksUseCase;
  late final GetTaskByIdUseCase getTaskByIdUseCase;
  late final CreateTaskUseCase createTaskUseCase;
  late final UpdateTaskUseCase updateTaskUseCase;
  late final DeleteTaskUseCase deleteTaskUseCase;
  late final SearchTasksUseCase searchTasksUseCase;
  late final ToggleTaskCompletionUseCase toggleTaskCompletionUseCase;
  late final GetTasksByPriorityUseCase getTasksByPriorityUseCase;
  late final GetTasksByDueDateUseCase getTasksByDueDateUseCase;
  late final GetTasksByTagUseCase getTasksByTagUseCase;
  late final TaskService taskService;
  late final TaskScheduler taskScheduler;
  late final TaskController taskController;
  
  void initialize({bool useInMemoryRepository = false, String? filePath}) {
    // Set up repository
    if (useInMemoryRepository) {
      taskRepository = InMemoryTaskRepository();
    } else {
      final dataSource = FileDataSource(
        filePath: filePath ?? AppConstants.defaultFilePath,
      );
      taskRepository = FileTaskRepository(dataSource);
    }
    
    // Set up use cases
    getAllTasksUseCase = GetAllTasksUseCase(taskRepository);
    getTaskByIdUseCase = GetTaskByIdUseCase(taskRepository);
    createTaskUseCase = CreateTaskUseCase(taskRepository);
    updateTaskUseCase = UpdateTaskUseCase(taskRepository);
    deleteTaskUseCase = DeleteTaskUseCase(taskRepository);
    searchTasksUseCase = SearchTasksUseCase(taskRepository);
    toggleTaskCompletionUseCase = ToggleTaskCompletionUseCase(taskRepository);
    getTasksByPriorityUseCase = GetTasksByPriorityUseCase(taskRepository);
    getTasksByDueDateUseCase = GetTasksByDueDateUseCase(taskRepository);
    getTasksByTagUseCase = GetTasksByTagUseCase(taskRepository);
    
    // Set up service
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
    
    // Set up scheduler
    taskScheduler = TaskScheduler(taskService);
    
    // Set up controller
    taskController = TaskController(taskService, taskScheduler);
  }
}