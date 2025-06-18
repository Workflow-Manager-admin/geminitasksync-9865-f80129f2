import 'package:firebase_auth/firebase_auth.dart';
import '../models/user.dart';
import 'storage_service.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final StorageService _storage = StorageService();

  // PUBLIC_INTERFACE
  /// Gets the current user stream
  static Stream<User?> get authStateChanges => _auth.authStateChanges();

  // PUBLIC_INTERFACE
  /// Gets the current user
  static User? get currentUser => _auth.currentUser;

  // PUBLIC_INTERFACE
  /// Signs in with email and password
  static Future<AppUser?> signInWithEmailPassword(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        final appUser = await _createAppUser(credential.user!);
        await _storage.saveUser(appUser);
        return appUser;
      }
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
    return null;
  }

  // PUBLIC_INTERFACE
  /// Creates a new account with email and password
  static Future<AppUser?> createAccount(String email, String password, String? displayName) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        // Update display name if provided
        if (displayName != null) {
          await credential.user!.updateDisplayName(displayName);
        }

        final appUser = await _createAppUser(credential.user!);
        await _storage.saveUser(appUser);
        return appUser;
      }
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
    return null;
  }

  // PUBLIC_INTERFACE
  /// Signs out the current user
  static Future<void> signOut() async {
    await _auth.signOut();
  }

  // PUBLIC_INTERFACE
  /// Sends password reset email
  static Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // PUBLIC_INTERFACE
  /// Updates user profile
  static Future<void> updateProfile(String? displayName, String? photoUrl) async {
    final user = _auth.currentUser;
    if (user != null) {
      await user.updateDisplayName(displayName);
      await user.updatePhotoURL(photoUrl);
      
      // Update in local storage
      final appUser = await _createAppUser(user);
      await _storage.saveUser(appUser);
    }
  }

  // PUBLIC_INTERFACE
  /// Gets the current app user from storage
  static Future<AppUser?> getCurrentAppUser() async {
    final user = _auth.currentUser;
    if (user != null) {
      return await _storage.getUser(user.uid);
    }
    return null;
  }

  static Future<AppUser> _createAppUser(User firebaseUser) async {
    return AppUser(
      id: firebaseUser.uid,
      email: firebaseUser.email!,
      displayName: firebaseUser.displayName,
      photoUrl: firebaseUser.photoURL,
      createdAt: firebaseUser.metadata.creationTime ?? DateTime.now(),
      lastLoginAt: DateTime.now(),
    );
  }

  static String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found with this email address.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'email-already-in-use':
        return 'An account with this email already exists.';
      case 'weak-password':
        return 'Password is too weak.';
      case 'invalid-email':
        return 'Invalid email address.';
      case 'network-request-failed':
        return 'Network error. Please check your connection.';
      default:
        return 'Authentication failed: ${e.message}';
    }
  }
}
