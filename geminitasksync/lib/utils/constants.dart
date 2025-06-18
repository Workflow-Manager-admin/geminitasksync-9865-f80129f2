class AppConstants {
  // Route Names
  static const String loginRoute = '/login';
  static const String homeRoute = '/home';
  static const String settingsRoute = '/settings';
  static const String taskDetailRoute = '/task-detail';
  
  // Storage Keys
  static const String apiConfigKey = 'api_config';
  static const String themeModeKey = 'theme_mode';
  static const String notificationsEnabledKey = 'notifications_enabled';
  static const String userPreferencesKey = 'user_preferences';
  
  // Validation Messages
  static const String emailRequiredMessage = 'Please enter your email';
  static const String emailInvalidMessage = 'Please enter a valid email';
  static const String passwordRequiredMessage = 'Please enter your password';
  static const String passwordTooShortMessage = 'Password must be at least 6 characters';
  static const String nameRequiredMessage = 'Please enter your name';
  static const String titleRequiredMessage = 'Please enter a task title';
  static const String descriptionRequiredMessage = 'Please enter a description';
  static const String apiKeyRequiredMessage = 'Please enter your API key';
  static const String apiKeyTooShortMessage = 'API key seems too short';
  
  // Success Messages
  static const String taskCreatedMessage = 'Task created successfully';
  static const String taskUpdatedMessage = 'Task updated successfully';
  static const String taskDeletedMessage = 'Task deleted successfully';
  static const String apiKeySavedMessage = 'API key saved successfully';
  static const String settingsUpdatedMessage = 'Settings updated successfully';
  static const String passwordResetEmailSentMessage = 'Password reset email sent';
  
  // Error Messages
  static const String genericErrorMessage = 'Something went wrong. Please try again.';
  static const String networkErrorMessage = 'Network error. Please check your connection.';
  static const String apiKeyRequiredErrorMessage = 'Please configure your Gemini API key in settings to use AI task creation.';
  static const String taskCreationFailedMessage = 'Failed to create task';
  static const String taskUpdateFailedMessage = 'Failed to update task';
  static const String taskDeleteFailedMessage = 'Failed to delete task';
  static const String loadTasksFailedMessage = 'Failed to load tasks';
  static const String saveApiConfigFailedMessage = 'Failed to save API configuration';
  
  // Dialog Titles
  static const String deleteTaskTitle = 'Delete Task';
  static const String signOutTitle = 'Sign Out';
  static const String apiKeyRequiredTitle = 'API Key Required';
  static const String chooseThemeTitle = 'Choose Theme';
  static const String searchTasksTitle = 'Search Tasks';
  static const String gettingApiKeyTitle = 'Getting Your Gemini API Key';
  
  // Button Labels
  static const String signInButton = 'Sign In';
  static const String signUpButton = 'Create Account';
  static const String signOutButton = 'Sign Out';
  static const String saveButton = 'Save';
  static const String cancelButton = 'Cancel';
  static const String deleteButton = 'Delete';
  static const String createTaskButton = 'Create Task';
  static const String updateTaskButton = 'Update Task';
  static const String saveApiKeyButton = 'Save API Key';
  static const String helpButton = 'Help';
  static const String settingsButton = 'Settings';
  static const String doneButton = 'Done';
  static const String clearButton = 'Clear';
  static const String gotItButton = 'Got it';
  
  // Placeholder Texts
  static const String taskInputHint = 'Describe what you need to do...';
  static const String emailHint = 'Enter your email';
  static const String passwordHint = 'Enter your password';
  static const String nameHint = 'Enter your full name';
  static const String apiKeyHint = 'Enter your Gemini API key';
  static const String taskTitleHint = 'Enter task title';
  static const String taskDescriptionHint = 'Enter task description';
  static const String searchHint = 'Enter search term...';
  
  // Time Formats
  static const String dateFormat = 'MMM dd, yyyy';
  static const String timeFormat = 'HH:mm';
  static const String dateTimeFormat = 'MMM dd, yyyy - HH:mm';
  
  // URLs
  static const String geminiApiKeyUrl = 'https://makersuite.google.com/app/apikey';
  static const String privacyPolicyUrl = 'https://example.com/privacy';
  static const String termsOfServiceUrl = 'https://example.com/terms';
}
