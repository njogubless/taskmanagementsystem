import 'dart:convert';
import 'dart:io';

import 'package:taskmanagementsystem/Core/error/exceptions.dart';
import 'package:taskmanagementsystem/Data/models/task_model.dart';

class FileDataSource {
  final String filePath;
  
  FileDataSource({required this.filePath});
  
  Future<List<TaskModel>> readTasks() async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        return [];
      }
      
      final contents = await file.readAsString();
      final List<dynamic> jsonList = jsonDecode(contents);
      
      return jsonList.map((json) => TaskModel.fromJson(json)).toList();
    } catch (e) {
      throw TaskException('Failed to read tasks from file: $e');
    }
  }
  
  Future<void> writeTasks(List<TaskModel> tasks) async {
    try {
      final file = File(filePath);
      final jsonList = tasks.map((task) => task.toJson()).toList();
      
      await file.writeAsString(jsonEncode(jsonList));
    } catch (e) {
      throw TaskException('Failed to write tasks to file: $e');
    }
  }
}