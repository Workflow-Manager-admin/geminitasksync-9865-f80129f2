import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  AppUser? _currentUser;
  bool _isLoading = false;
  String? _error;

  AppUser? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _currentUser != null;

  // PUBLIC_INTERFACE
  /// Initializes the auth provider and listens to auth state changes
  void initialize() {
    AuthService.authStateChanges.listen((User? firebaseUser) async {
      if (firebaseUser != null) {
        _currentUser = await AuthService.getCurrentAppUser();
      } else {
        _currentUser = null;
      }
      notifyListeners();
    });
  }

  // PUBLIC_INTERFACE
  /// Signs in with email and password
  Future<bool> signIn(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final user = await AuthService.signInWithEmailPassword(email, password);
      if (user != null) {
        _currentUser = user;
        return true;
      }
      return false;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // PUBLIC_INTERFACE
  /// Creates a new account
  Future<bool> signUp(String email, String password, String displayName) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final user = await AuthService.createAccount(email, password, displayName);
      if (user != null) {
        _currentUser = user;
        return true;
      }
      return false;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // PUBLIC_INTERFACE
  /// Signs out the current user
  Future<void> signOut() async {
    _isLoading = true;
    notifyListeners();

    try {
      await AuthService.signOut();
      _currentUser = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // PUBLIC_INTERFACE
  /// Sends password reset email
  Future<bool> resetPassword(String email) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await AuthService.sendPasswordResetEmail(email);
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // PUBLIC_INTERFACE
  /// Updates user profile
  Future<bool> updateProfile(String? displayName, String? photoUrl) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await AuthService.updateProfile(displayName, photoUrl);
      _currentUser = await AuthService.getCurrentAppUser();
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
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
