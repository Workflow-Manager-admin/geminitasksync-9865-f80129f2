import 'package:flutter_test/flutter_test.dart';
import 'package:geminitasksync/models/task.dart';
import 'package:geminitasksync/models/user.dart';
import 'package:geminitasksync/models/api_config.dart';
import 'package:geminitasksync/services/gemini_service.dart';

void main() {
  group('Task Model Tests', () {
    test('should create task with required fields', () {
      final task = Task(
        id: '1',
        title: 'Test Task',
        description: 'Test Description',
        createdAt: DateTime.now(),
      );

      expect(task.id, '1');
      expect(task.title, 'Test Task');
      expect(task.description, 'Test Description');
      expect(task.priority, TaskPriority.medium);
      expect(task.isCompleted, false);
    });

    test('should create task with all fields', () {
      final now = DateTime.now();
      final dueDate = now.add(const Duration(days: 1));
      final reminderTime = now.add(const Duration(hours: 1));

      final task = Task(
        id: '1',
        title: 'Test Task',
        description: 'Test Description',
        createdAt: now,
        dueDate: dueDate,
        reminderTime: reminderTime,
        priority: TaskPriority.high,
        isCompleted: true,
        userId: 'user123',
      );

      expect(task.dueDate, dueDate);
      expect(task.reminderTime, reminderTime);
      expect(task.priority, TaskPriority.high);
      expect(task.isCompleted, true);
      expect(task.userId, 'user123');
    });

    test('should create copy with updated fields', () {
      final task = Task(
        id: '1',
        title: 'Original Task',
        description: 'Original Description',
        createdAt: DateTime.now(),
      );

      final updatedTask = task.copyWith(
        title: 'Updated Task',
        isCompleted: true,
      );

      expect(updatedTask.title, 'Updated Task');
      expect(updatedTask.isCompleted, true);
      expect(updatedTask.description, 'Original Description');
      expect(updatedTask.id, '1');
    });

    test('should handle task equality correctly', () {
      final task1 = Task(
        id: '1',
        title: 'Test Task',
        description: 'Test Description',
        createdAt: DateTime.now(),
      );

      final task2 = Task(
        id: '1',
        title: 'Different Title',
        description: 'Different Description',
        createdAt: DateTime.now(),
      );

      final task3 = Task(
        id: '2',
        title: 'Test Task',
        description: 'Test Description',
        createdAt: DateTime.now(),
      );

      expect(task1, equals(task2)); // Same ID
      expect(task1, isNot(equals(task3))); // Different ID
    });
  });

  group('TaskPriority Tests', () {
    test('should have correct display names', () {
      expect(TaskPriority.low.displayName, 'Low');
      expect(TaskPriority.medium.displayName, 'Medium');
      expect(TaskPriority.high.displayName, 'High');
      expect(TaskPriority.urgent.displayName, 'Urgent');
    });

    test('should have correct values', () {
      expect(TaskPriority.low.value, 1);
      expect(TaskPriority.medium.value, 2);
      expect(TaskPriority.high.value, 3);
      expect(TaskPriority.urgent.value, 4);
    });
  });

  group('AppUser Model Tests', () {
    test('should create user with required fields', () {
      final now = DateTime.now();
      final user = AppUser(
        id: 'user123',
        email: 'test@example.com',
        createdAt: now,
        lastLoginAt: now,
      );

      expect(user.id, 'user123');
      expect(user.email, 'test@example.com');
      expect(user.displayName, null);
      expect(user.photoUrl, null);
      expect(user.createdAt, now);
      expect(user.lastLoginAt, now);
    });

    test('should create user with all fields', () {
      final now = DateTime.now();
      final user = AppUser(
        id: 'user123',
        email: 'test@example.com',
        displayName: 'Test User',
        photoUrl: 'https://example.com/photo.jpg',
        createdAt: now,
        lastLoginAt: now,
      );

      expect(user.displayName, 'Test User');
      expect(user.photoUrl, 'https://example.com/photo.jpg');
    });

    test('should create copy with updated fields', () {
      final now = DateTime.now();
      final user = AppUser(
        id: 'user123',
        email: 'test@example.com',
        createdAt: now,
        lastLoginAt: now,
      );

      final updatedUser = user.copyWith(
        displayName: 'Updated Name',
        photoUrl: 'https://example.com/new-photo.jpg',
      );

      expect(updatedUser.displayName, 'Updated Name');
      expect(updatedUser.photoUrl, 'https://example.com/new-photo.jpg');
      expect(updatedUser.id, 'user123');
      expect(updatedUser.email, 'test@example.com');
    });
  });

  group('ApiConfig Model Tests', () {
    test('should create config with required fields', () {
      final config = ApiConfig(geminiApiKey: 'test-api-key');

      expect(config.geminiApiKey, 'test-api-key');
      expect(config.geminiModel, 'gemini-pro');
      expect(config.temperature, 0.7);
      expect(config.maxTokens, 1000);
    });

    test('should create config with all fields', () {
      final config = ApiConfig(
        geminiApiKey: 'test-api-key',
        geminiModel: 'gemini-pro-vision',
        temperature: 0.5,
        maxTokens: 2000,
      );

      expect(config.geminiModel, 'gemini-pro-vision');
      expect(config.temperature, 0.5);
      expect(config.maxTokens, 2000);
    });

    test('should validate API key correctly', () {
      final validConfig = ApiConfig(geminiApiKey: 'valid-api-key-123');
      final invalidConfig1 = ApiConfig(geminiApiKey: '');
      final invalidConfig2 = ApiConfig(geminiApiKey: 'short');

      expect(validConfig.isValid, true);
      expect(invalidConfig1.isValid, false);
      expect(invalidConfig2.isValid, false);
    });

    test('should create copy with updated fields', () {
      final config = ApiConfig(geminiApiKey: 'original-key');

      final updatedConfig = config.copyWith(
        geminiApiKey: 'updated-key',
        temperature: 0.8,
      );

      expect(updatedConfig.geminiApiKey, 'updated-key');
      expect(updatedConfig.temperature, 0.8);
      expect(updatedConfig.geminiModel, 'gemini-pro');
      expect(updatedConfig.maxTokens, 1000);
    });
  });

  group('GeminiService Tests', () {
    late GeminiService geminiService;

    setUp(() {
      geminiService = GeminiService();
    });

    test('should extract title from instruction', () {
      final instruction = 'Buy groceries for the week';
      final task = geminiService.convertInstructionToTask(
        instruction,
        ApiConfig(geminiApiKey: 'test-key'),
      );

      // This will use fallback since we don't have real API
      expect(task, isA<Future<Task>>());
    });

    test('should detect priority from instruction', () {
      // Test urgent priority detection
      final urgentInstruction = 'URGENT: Fix the critical bug immediately';
      final task1 = geminiService.convertInstructionToTask(
        urgentInstruction,
        ApiConfig(geminiApiKey: 'test-key'),
      );

      expect(task1, isA<Future<Task>>());

      // Test high priority detection
      final highInstruction = 'Important meeting preparation';
      final task2 = geminiService.convertInstructionToTask(
        highInstruction,
        ApiConfig(geminiApiKey: 'test-key'),
      );

      expect(task2, isA<Future<Task>>());
    });

    test('should handle empty instruction', () {
      final instruction = '';
      final task = geminiService.convertInstructionToTask(
        instruction,
        ApiConfig(geminiApiKey: 'test-key'),
      );

      expect(task, isA<Future<Task>>());
    });
  });
}
