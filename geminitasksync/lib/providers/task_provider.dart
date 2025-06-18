import 'package:flutter/foundation.dart';
import '../models/task.dart';
import '../models/api_config.dart';
import '../services/gemini_service.dart';
import '../services/storage_service.dart';
import '../services/notification_service.dart';

class TaskProvider with ChangeNotifier {
  final GeminiService _geminiService = GeminiService();
  final StorageService _storageService = StorageService();
  
  List<Task> _tasks = [];
  bool _isLoading = false;
  String? _error;
  String? _currentUserId;

  List<Task> get tasks => _tasks;
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<Task> get completedTasks => _tasks.where((task) => task.isCompleted).toList();
  List<Task> get pendingTasks => _tasks.where((task) => !task.isCompleted).toList();
  List<Task> get todayTasks {
    final today = DateTime.now();
    return _tasks.where((task) {
      if (task.dueDate == null) return false;
      final dueDate = task.dueDate!;
      return dueDate.year == today.year && 
             dueDate.month == today.month && 
             dueDate.day == today.day;
    }).toList();
  }

  // PUBLIC_INTERFACE
  /// Sets the current user ID
  void setCurrentUser(String? userId) {
    _currentUserId = userId;
    loadTasks();
  }

  // PUBLIC_INTERFACE
  /// Loads tasks from storage
  Future<void> loadTasks() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _tasks = await _storageService.getTasks(_currentUserId);
      _sortTasks();
    } catch (e) {
      _error = 'Failed to load tasks: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // PUBLIC_INTERFACE
  /// Creates a task from instruction using Gemini API
  Future<void> createTaskFromInstruction(String instruction, ApiConfig apiConfig) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final task = await _geminiService.convertInstructionToTask(instruction, apiConfig);
      final taskWithUser = task.copyWith(userId: _currentUserId);
      
      await _storageService.saveTask(taskWithUser);
      _tasks.add(taskWithUser);
      _sortTasks();
      
      // Schedule notification if reminder is set
      if (taskWithUser.reminderTime != null) {
        await NotificationService.scheduleTaskReminder(taskWithUser);
      }
    } catch (e) {
      _error = 'Failed to create task: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // PUBLIC_INTERFACE
  /// Adds a new task manually
  Future<void> addTask(Task task) async {
    try {
      final taskWithUser = task.copyWith(userId: _currentUserId);
      await _storageService.saveTask(taskWithUser);
      _tasks.add(taskWithUser);
      _sortTasks();
      
      // Schedule notification if reminder is set
      if (taskWithUser.reminderTime != null) {
        await NotificationService.scheduleTaskReminder(taskWithUser);
      }
      
      notifyListeners();
    } catch (e) {
      _error = 'Failed to add task: $e';
      notifyListeners();
    }
  }

  // PUBLIC_INTERFACE
  /// Updates an existing task
  Future<void> updateTask(Task task) async {
    try {
      await _storageService.updateTask(task);
      final index = _tasks.indexWhere((t) => t.id == task.id);
      if (index != -1) {
        _tasks[index] = task;
        _sortTasks();
        
        // Update notification
        await NotificationService.cancelNotification(task.id.hashCode);
        if (task.reminderTime != null && !task.isCompleted) {
          await NotificationService.scheduleTaskReminder(task);
        }
        
        notifyListeners();
      }
    } catch (e) {
      _error = 'Failed to update task: $e';
      notifyListeners();
    }
  }

  // PUBLIC_INTERFACE
  /// Toggles task completion status
  Future<void> toggleTaskCompletion(String taskId) async {
    final task = _tasks.firstWhere((t) => t.id == taskId);
    final updatedTask = task.copyWith(isCompleted: !task.isCompleted);
    await updateTask(updatedTask);
  }

  // PUBLIC_INTERFACE
  /// Deletes a task
  Future<void> deleteTask(String taskId) async {
    try {
      await _storageService.deleteTask(taskId);
      await NotificationService.cancelNotification(taskId.hashCode);
      _tasks.removeWhere((task) => task.id == taskId);
      notifyListeners();
    } catch (e) {
      _error = 'Failed to delete task: $e';
      notifyListeners();
    }
  }

  // PUBLIC_INTERFACE
  /// Gets tasks by priority
  List<Task> getTasksByPriority(TaskPriority priority) {
    return _tasks.where((task) => task.priority == priority).toList();
  }

  // PUBLIC_INTERFACE
  /// Searches tasks by query
  List<Task> searchTasks(String query) {
    if (query.isEmpty) return _tasks;
    
    final lowercaseQuery = query.toLowerCase();
    return _tasks.where((task) {
      return task.title.toLowerCase().contains(lowercaseQuery) ||
             task.description.toLowerCase().contains(lowercaseQuery);
    }).toList();
  }

  // PUBLIC_INTERFACE
  /// Clears error message
  void clearError() {
    _error = null;
    notifyListeners();
  }

  void _sortTasks() {
    _tasks.sort((a, b) {
      // First, sort by completion status (incomplete first)
      if (a.isCompleted != b.isCompleted) {
        return a.isCompleted ? 1 : -1;
      }
      
      // Then by priority (highest first)
      if (a.priority != b.priority) {
        return b.priority.value.compareTo(a.priority.value);
      }
      
      // Then by due date (earliest first)
      if (a.dueDate != null && b.dueDate != null) {
        return a.dueDate!.compareTo(b.dueDate!);
      } else if (a.dueDate != null) {
        return -1;
      } else if (b.dueDate != null) {
        return 1;
      }
      
      // Finally by creation date (newest first)
      return b.createdAt.compareTo(a.createdAt);
    });
  }
}
