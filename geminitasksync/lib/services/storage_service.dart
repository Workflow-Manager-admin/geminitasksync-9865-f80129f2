import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/task.dart';
import '../models/user.dart';
import '../models/api_config.dart';

class StorageService {
  static Database? _database;
  static SharedPreferences? _prefs;

  // PUBLIC_INTERFACE
  /// Initializes the storage service
  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    _database = await _initDatabase();
  }

  Future<Database> _initDatabase() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, 'geminitasksync.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDatabase,
    );
  }

  Future<void> _createDatabase(Database db, int version) async {
    await db.execute('''
      CREATE TABLE tasks (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        createdAt TEXT NOT NULL,
        dueDate TEXT,
        reminderTime TEXT,
        priority TEXT NOT NULL,
        isCompleted INTEGER NOT NULL DEFAULT 0,
        userId TEXT,
        syncStatus INTEGER NOT NULL DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE users (
        id TEXT PRIMARY KEY,
        email TEXT NOT NULL,
        displayName TEXT,
        photoUrl TEXT,
        createdAt TEXT NOT NULL,
        lastLoginAt TEXT NOT NULL
      )
    ''');
  }

  // Task operations
  // PUBLIC_INTERFACE
  /// Saves a task to local storage
  Future<void> saveTask(Task task) async {
    final db = _database!;
    await db.insert(
      'tasks',
      _taskToMap(task),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // PUBLIC_INTERFACE
  /// Retrieves all tasks for a specific user
  Future<List<Task>> getTasks(String? userId) async {
    final db = _database!;
    final List<Map<String, dynamic>> maps = await db.query(
      'tasks',
      where: userId != null ? 'userId = ?' : 'userId IS NULL',
      whereArgs: userId != null ? [userId] : null,
      orderBy: 'createdAt DESC',
    );

    return List.generate(maps.length, (i) => _taskFromMap(maps[i]));
  }

  // PUBLIC_INTERFACE
  /// Updates an existing task
  Future<void> updateTask(Task task) async {
    final db = _database!;
    await db.update(
      'tasks',
      _taskToMap(task),
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }

  // PUBLIC_INTERFACE
  /// Deletes a task
  Future<void> deleteTask(String taskId) async {
    final db = _database!;
    await db.delete(
      'tasks',
      where: 'id = ?',
      whereArgs: [taskId],
    );
  }

  // User operations
  // PUBLIC_INTERFACE
  /// Saves user information
  Future<void> saveUser(AppUser user) async {
    final db = _database!;
    await db.insert(
      'users',
      _userToMap(user),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // PUBLIC_INTERFACE
  /// Retrieves user by ID
  Future<AppUser?> getUser(String userId) async {
    final db = _database!;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [userId],
    );

    if (maps.isNotEmpty) {
      return _userFromMap(maps.first);
    }
    return null;
  }

  // API Configuration
  // PUBLIC_INTERFACE
  /// Saves API configuration
  Future<void> saveApiConfig(ApiConfig config) async {
    await _prefs!.setString('api_config', json.encode(config.toJson()));
  }

  // PUBLIC_INTERFACE
  /// Retrieves API configuration
  Future<ApiConfig?> getApiConfig() async {
    final configString = _prefs!.getString('api_config');
    if (configString != null) {
      return ApiConfig.fromJson(json.decode(configString));
    }
    return null;
  }

  // Settings
  // PUBLIC_INTERFACE
  /// Saves app settings
  Future<void> saveSetting(String key, dynamic value) async {
    if (value is String) {
      await _prefs!.setString(key, value);
    } else if (value is bool) {
      await _prefs!.setBool(key, value);
    } else if (value is int) {
      await _prefs!.setInt(key, value);
    } else if (value is double) {
      await _prefs!.setDouble(key, value);
    }
  }

  // PUBLIC_INTERFACE
  /// Retrieves app setting
  T? getSetting<T>(String key) {
    return _prefs!.get(key) as T?;
  }

  // Sync operations
  // PUBLIC_INTERFACE
  /// Gets tasks that need to be synced
  Future<List<Task>> getUnsyncedTasks() async {
    final db = _database!;
    final List<Map<String, dynamic>> maps = await db.query(
      'tasks',
      where: 'syncStatus = ?',
      whereArgs: [0],
    );

    return List.generate(maps.length, (i) => _taskFromMap(maps[i]));
  }

  // PUBLIC_INTERFACE
  /// Marks task as synced
  Future<void> markTaskSynced(String taskId) async {
    final db = _database!;
    await db.update(
      'tasks',
      {'syncStatus': 1},
      where: 'id = ?',
      whereArgs: [taskId],
    );
  }

  // Helper methods
  Map<String, dynamic> _taskToMap(Task task) {
    return {
      'id': task.id,
      'title': task.title,
      'description': task.description,
      'createdAt': task.createdAt.toIso8601String(),
      'dueDate': task.dueDate?.toIso8601String(),
      'reminderTime': task.reminderTime?.toIso8601String(),
      'priority': task.priority.name,
      'isCompleted': task.isCompleted ? 1 : 0,
      'userId': task.userId,
      'syncStatus': 0,
    };
  }

  Task _taskFromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      createdAt: DateTime.parse(map['createdAt']),
      dueDate: map['dueDate'] != null ? DateTime.parse(map['dueDate']) : null,
      reminderTime: map['reminderTime'] != null ? DateTime.parse(map['reminderTime']) : null,
      priority: TaskPriority.values.firstWhere((e) => e.name == map['priority']),
      isCompleted: map['isCompleted'] == 1,
      userId: map['userId'],
    );
  }

  Map<String, dynamic> _userToMap(AppUser user) {
    return {
      'id': user.id,
      'email': user.email,
      'displayName': user.displayName,
      'photoUrl': user.photoUrl,
      'createdAt': user.createdAt.toIso8601String(),
      'lastLoginAt': user.lastLoginAt.toIso8601String(),
    };
  }

  AppUser _userFromMap(Map<String, dynamic> map) {
    return AppUser(
      id: map['id'],
      email: map['email'],
      displayName: map['displayName'],
      photoUrl: map['photoUrl'],
      createdAt: DateTime.parse(map['createdAt']),
      lastLoginAt: DateTime.parse(map['lastLoginAt']),
    );
  }
}
