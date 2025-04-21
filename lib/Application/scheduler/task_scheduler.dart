class HeapPriorityQueue<T> {
  final List<T> _heap = [];
  final int Function(T, T) _compare;
  
  HeapPriorityQueue(this._compare);
  
  bool get isEmpty => _heap.isEmpty;
  int get length => _heap.length;
  
  void add(T element) {
    _heap.add(element);
    _siftUp(_heap.length - 1);
  }
  
  T removeFirst() {
    if (_heap.isEmpty) {
      throw StateError('Priority queue is empty');
    }
    
    final T result = _heap[0];
    final T last = _heap.removeLast();
    if (_heap.isNotEmpty) {
      _heap[0] = last;
      _siftDown(0);
    }
    return result;
  }
  
  void _siftUp(int index) {
    T element = _heap[index];
    while (index > 0) {
      int parentIndex = (index - 1) ~/ 2;
      T parent = _heap[parentIndex];
      if (_compare(element, parent) >= 0) break;
      _heap[index] = parent;
      index = parentIndex;
    }
    _heap[index] = element;
  }
  
  void _siftDown(int index) {
    int childIndex = 2 * index + 1;
    if (childIndex >= _heap.length) return;
    
    int rightIndex = childIndex + 1;
    if (rightIndex < _heap.length && 
        _compare(_heap[rightIndex], _heap[childIndex]) < 0) {
      childIndex = rightIndex;
    }
    
    if (_compare(_heap[childIndex], _heap[index]) >= 0) return;
    
    T tmp = _heap[index];
    _heap[index] = _heap[childIndex];
    _heap[childIndex] = tmp;
    _siftDown(childIndex);
  }
}

class TaskScheduler {
  final TaskService _taskService;
  
  TaskScheduler(this._taskService);
  
  Future<List<Task>> getScheduledTasks() async {
    final tasks = await _taskService.getAllTasks();
    
    final priorityQueue = HeapPriorityQueue<Task>((a, b) {
      if (a.isCompleted != b.isCompleted) {
        return a.isCompleted ? 1 : -1;
      }
      
      if (a.priority != b.priority) {
        return b.priority.index - a.priority.index;
      }
      
      return a.dueDate.compareTo(b.dueDate);
    });
    
    for (var task in tasks) {
      priorityQueue.add(task);
    }
    
    final scheduledTasks = <Task>[];
    while (priorityQueue.isNotEmpty) {
      scheduledTasks.add(priorityQueue.removeFirst());
    }
    
    return scheduledTasks;
  }
  
  Future<List<Task>> getTasksDueSoon({int days = 3}) async {
    final now = DateTime.now();
    final endDate = now.add(Duration(days: days));
    
    return await _taskService.getTasksByDueDate(
      startDate: now,
      endDate: endDate,
    );
  }
  
  Future<List<Task>> getOverdueTasks() async {
    final now = DateTime.now();
    final tasks = await _taskService.getAllTasks();
    
    return tasks.where((task) => 
      !task.isCompleted && task.dueDate.isBefore(now)
    ).toList();
  }
}