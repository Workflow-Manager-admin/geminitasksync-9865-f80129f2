class AppConfig {
  static const String appName = 'GeminiTaskSync';
  static const String appVersion = '1.0.0';
  static const String appBuildNumber = '1';
  
  // API Configuration
  static const String geminiApiBaseUrl = 'https://generativelanguage.googleapis.com/v1beta/models';
  static const String defaultGeminiModel = 'gemini-pro';
  static const double defaultTemperature = 0.7;
  static const int defaultMaxTokens = 1000;
  
  // Database Configuration
  static const String databaseName = 'geminitasksync.db';
  static const int databaseVersion = 1;
  
  // Notification Configuration
  static const String taskReminderChannelId = 'task_reminders';
  static const String taskReminderChannelName = 'Task Reminders';
  static const String taskReminderChannelDescription = 'Notifications for task reminders';
  
  static const String generalChannelId = 'general';
  static const String generalChannelName = 'General Notifications';
  static const String generalChannelDescription = 'General app notifications';
  
  // Theme Configuration
  static const int primaryColor = 0xFF6200EE;
  static const int secondaryColor = 0xFF03DAC6;
  static const int accentColor = 0xFFFF4081;
  
  // Validation Rules
  static const int minPasswordLength = 6;
  static const int minApiKeyLength = 10;
  static const int maxTaskTitleLength = 100;
  static const int maxTaskDescriptionLength = 1000;
}
