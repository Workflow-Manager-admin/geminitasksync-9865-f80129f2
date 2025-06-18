import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:geminitasksync/providers/auth_provider.dart';
import 'package:geminitasksync/providers/task_provider.dart';
import 'package:geminitasksync/providers/settings_provider.dart';
import 'package:geminitasksync/screens/login_screen.dart';
import 'package:geminitasksync/screens/home_screen.dart';
import 'package:geminitasksync/screens/settings_screen.dart';

void main() {

  group('App Flow Tests', () {
    testWidgets('Complete app flow test', (WidgetTester tester) async {
      // Build the app
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => AuthProvider()),
            ChangeNotifierProvider(create: (_) => TaskProvider()),
            ChangeNotifierProvider(create: (_) => SettingsProvider()),
          ],
          child: MaterialApp(
            home: const LoginScreen(),
            routes: {
              '/home': (context) => const HomeScreen(),
              '/settings': (context) => const SettingsScreen(),
            },
          ),
        ),
      );

      // Verify login screen is displayed
      expect(find.text('GeminiTaskSync'), findsOneWidget);
      expect(find.text('Sign in to your account'), findsOneWidget);

      // Test form validation
      await tester.tap(find.text('Sign In'));
      await tester.pumpAndSettle();

      expect(find.text('Please enter your email'), findsOneWidget);
      expect(find.text('Please enter your password'), findsOneWidget);

      // Fill in valid email but invalid password
      await tester.enterText(find.byType(TextFormField).first, 'test@example.com');
      await tester.enterText(find.byType(TextFormField).last, '123');
      await tester.tap(find.text('Sign In'));
      await tester.pumpAndSettle();

      // Check for password validation error
      expect(find.text('Password must be at least 6 characters'), findsOneWidget);

      // Switch to sign up mode
      await tester.tap(find.text("Don't have an account? Sign Up"));
      await tester.pumpAndSettle();

      expect(find.text('Create your account'), findsOneWidget);
      expect(find.text('Create Account'), findsOneWidget);

      // Switch back to sign in
      await tester.tap(find.text('Already have an account? Sign In'));
      await tester.pumpAndSettle();

      expect(find.text('Sign in to your account'), findsOneWidget);
    });

    testWidgets('Task creation flow test', (WidgetTester tester) async {
      // Build the home screen directly (simulating authenticated state)
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => AuthProvider()),
            ChangeNotifierProvider(create: (_) => TaskProvider()),
            ChangeNotifierProvider(create: (_) => SettingsProvider()),
          ],
          child: MaterialApp(
            home: const HomeScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify home screen elements
      expect(find.text('GeminiTaskSync'), findsOneWidget);
      expect(find.text('All'), findsOneWidget);
      expect(find.text('Today'), findsOneWidget);
      expect(find.text('Pending'), findsOneWidget);
      expect(find.text('Done'), findsOneWidget);

      // Check for empty state
      expect(find.text('No tasks yet'), findsOneWidget);
      expect(find.text('Add your first task using the input above'), findsOneWidget);

      // Try to add a task without API key
      await tester.enterText(find.byType(TextField), 'Test task creation');
      await tester.tap(find.byIcon(Icons.send));
      await tester.pumpAndSettle();

      // Should show API key dialog
      expect(find.text('API Key Required'), findsOneWidget);
      expect(find.text('Please configure your Gemini API key in settings to use AI task creation.'), findsOneWidget);

      // Dismiss dialog
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      // Navigate to settings
      await tester.tap(find.byIcon(Icons.settings));
      await tester.pumpAndSettle();

      expect(find.text('Settings'), findsOneWidget);
      expect(find.text('Gemini API Configuration'), findsOneWidget);
    });

    testWidgets('Settings screen test', (WidgetTester tester) async {
      // Build the settings screen
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => AuthProvider()),
            ChangeNotifierProvider(create: (_) => TaskProvider()),
            ChangeNotifierProvider(create: (_) => SettingsProvider()),
          ],
          child: MaterialApp(
            home: const SettingsScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify settings screen elements
      expect(find.text('Settings'), findsOneWidget);
      expect(find.text('Profile'), findsOneWidget);
      expect(find.text('Gemini API Configuration'), findsOneWidget);
      expect(find.text('App Settings'), findsOneWidget);
      expect(find.text('About'), findsOneWidget);

      // Test API key input
      await tester.enterText(find.byType(TextFormField), 'test-api-key-123');
      await tester.tap(find.text('Save API Key'));
      await tester.pumpAndSettle();

      // Test theme selection
      await tester.tap(find.text('Theme'));
      await tester.pumpAndSettle();

      expect(find.text('Choose Theme'), findsOneWidget);
      expect(find.text('Light'), findsOneWidget);
      expect(find.text('Dark'), findsOneWidget);
      expect(find.text('System'), findsOneWidget);

      // Select dark theme
      await tester.tap(find.text('Dark').last);
      await tester.pumpAndSettle();

      // Test notifications toggle
      await tester.tap(find.byType(Switch));
      await tester.pumpAndSettle();

      // Test help dialog
      await tester.tap(find.text('Help'));
      await tester.pumpAndSettle();

      expect(find.text('Getting Your Gemini API Key'), findsOneWidget);
      expect(find.text('Visit https://makersuite.google.com/app/apikey'), findsOneWidget);

      await tester.tap(find.text('Got it'));
      await tester.pumpAndSettle();
    });

    testWidgets('Navigation test', (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => AuthProvider()),
            ChangeNotifierProvider(create: (_) => TaskProvider()),
            ChangeNotifierProvider(create: (_) => SettingsProvider()),
          ],
          child: MaterialApp(
            home: const HomeScreen(),
            routes: {
              '/settings': (context) => const SettingsScreen(),
            },
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Test navigation to settings
      await tester.tap(find.byIcon(Icons.settings));
      await tester.pumpAndSettle();

      expect(find.text('Settings'), findsOneWidget);

      // Test navigation back
      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();

      expect(find.text('GeminiTaskSync'), findsOneWidget);
      expect(find.text('All'), findsOneWidget);
    });
  });
}
