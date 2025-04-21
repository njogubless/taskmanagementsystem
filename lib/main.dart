import 'package:taskmanagementsystem/Infrastructure/export/task_exporter.dart';
import 'package:taskmanagementsystem/Presentation/cli/task_cli_app.dart';

void main(List<String> args) {
  // Parse command line arguments
  String? filePath;
  bool useInMemory = false;
  
  for (int i = 0; i < args.length; i++) {
    if (args[i] == '--file' && i + 1 < args.length) {
      filePath = args[i + 1];
      i++;
    } else if (args[i] == '--memory') {
      useInMemory = true;
    }
  }
  
  // Initialize service locator
  final serviceLocator = ServiceLocator();
  serviceLocator.initialize(
    useInMemoryRepository: useInMemory,
    filePath: filePath,
  );
  
  // Run the CLI app
  final cliApp = TaskCliApp(serviceLocator.taskController);
  cliApp.run();
}