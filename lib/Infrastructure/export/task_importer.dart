import 'dart:io';

import 'package:taskmanagementsystem/Core/error/exceptions.dart';
import 'package:taskmanagementsystem/Data/models/task_model.dart';
import 'package:taskmanagementsystem/Domain/repository/task_repository.dart';

class TaskImporter {
  final TaskRepository _repository;
  
  TaskImporter(this._repository);
  
  Future<int> importFromCsv(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        throw TaskException('File not found: $filePath');
      }
      
      final lines = await file.readAsLines();
      if (lines.isEmpty) {
        return 0;
      }
      
      // Skip header row
      int imported = 0;
      for (var i = 1; i < lines.length; i++) {
        final line = lines[i];
        if (line.trim().isEmpty) continue;
        
        // Parse CSV row
        final parts = _parseCsvRow(line);
        if (parts.length < 7) continue;
        
        final taskModel = TaskModel(
          id: parts[0],
          title: parts[1],
          description: parts[2],
          dueDate: parts[3],
          priority: parts[4],
          isCompleted: parts[5].toLowerCase() == 'true',
          tags: parts[6].split(';').map((tag) => tag.trim()).toList(),
        );
        
        try {
          final task = taskModel.toDomain();
          await _repository.addTask(task);
          imported++;
        } catch (e) {
          // Skip invalid task
          continue;
        }
      }
      
      return imported;
    } catch (e) {
      throw TaskException('Failed to import tasks: $e');
    }
  }
  
  List<String> _parseCsvRow(String line) {
    final List<String> result = [];
    bool inQuotes = false;
    StringBuffer currentField = StringBuffer();
    
    for (int i = 0; i < line.length; i++) {
      final char = line[i];
      
      if (char == '"') {
        if (i + 1 < line.length && line[i + 1] == '"') {
          currentField.write('"');
          i++;
        } else {
          inQuotes = !inQuotes;
        }
      } else if (char == ',' && !inQuotes) {
        result.add(currentField.toString());
        currentField = StringBuffer();
      } else {
        currentField.write(char);
      }
    }
    
    result.add(currentField.toString());
    return result;
  }
}