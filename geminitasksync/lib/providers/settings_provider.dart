import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../models/api_config.dart';
import '../services/storage_service.dart';

class SettingsProvider with ChangeNotifier {
  final StorageService _storageService = StorageService();
  
  ApiConfig? _apiConfig;
  ThemeMode _themeMode = ThemeMode.system;
  bool _notificationsEnabled = true;
  bool _isLoading = false;
  String? _error;

  ApiConfig? get apiConfig => _apiConfig;
  ThemeMode get themeMode => _themeMode;
  bool get notificationsEnabled => _notificationsEnabled;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasValidApiKey => _apiConfig?.isValid == true;

  // PUBLIC_INTERFACE
  /// Loads settings from storage
  Future<void> loadSettings() async {
    _isLoading = true;
    notifyListeners();

    try {
      _apiConfig = await _storageService.getApiConfig();
      
      final themeModeName = _storageService.getSetting<String>('theme_mode');
      if (themeModeName != null) {
        _themeMode = ThemeMode.values.firstWhere(
          (mode) => mode.name == themeModeName,
          orElse: () => ThemeMode.system,
        );
      }
      
      _notificationsEnabled = _storageService.getSetting<bool>('notifications_enabled') ?? true;
    } catch (e) {
      _error = 'Failed to load settings: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // PUBLIC_INTERFACE
  /// Updates API configuration
  Future<void> updateApiConfig(ApiConfig config) async {
    try {
      await _storageService.saveApiConfig(config);
      _apiConfig = config;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to save API configuration: $e';
      notifyListeners();
    }
  }

  // PUBLIC_INTERFACE
  /// Updates theme mode
  Future<void> updateThemeMode(ThemeMode mode) async {
    try {
      await _storageService.saveSetting('theme_mode', mode.name);
      _themeMode = mode;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to save theme setting: $e';
      notifyListeners();
    }
  }

  // PUBLIC_INTERFACE
  /// Updates notification settings
  Future<void> updateNotificationsEnabled(bool enabled) async {
    try {
      await _storageService.saveSetting('notifications_enabled', enabled);
      _notificationsEnabled = enabled;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to save notification setting: $e';
      notifyListeners();
    }
  }

  // PUBLIC_INTERFACE
  /// Clears error message
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
