class TaskException implements Exception {
  final String message;
  TaskException(this.message);
  @override
  String toString() => 'TaskException: $message';
}
