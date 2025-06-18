import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:geminitasksync/main.dart';
import 'package:geminitasksync/providers/auth_provider.dart';
import 'package:geminitasksync/providers/task_provider.dart';
import 'package:geminitasksync/providers/settings_provider.dart';
import 'package:geminitasksync/widgets/custom_button.dart';
import 'package:geminitasksync/widgets/task_input.dart';
import 'package:geminitasksync/widgets/task_item.dart';
import 'package:geminitasksync/models/task.dart';

void main() {
  group('Widget Tests', () {
    testWidgets('CustomButton displays text and handles tap', (WidgetTester tester) async {
      bool tapped = false;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomButton(
              text: 'Test Button',
              onPressed: () => tapped = true,
            ),
          ),
        ),
      );

      expect(find.text('Test Button'), findsOneWidget);
      
      await tester.tap(find.byType(CustomButton));
      expect(tapped, true);
    });

    testWidgets('CustomButton shows loading state', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomButton(
              text: 'Loading Button',
              isLoading: true,
              onPressed: () {},
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Loading Button'), findsNothing);
    });

    testWidgets('CustomButton with icon displays both icon and text', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomButton(
              text: 'Icon Button',
              icon: Icons.add,
              onPressed: () {},
            ),
          ),
        ),
      );

      expect(find.text('Icon Button'), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('TaskInput displays hint text and handles submission', (WidgetTester tester) async {
      String? submittedText;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TaskInput(
              hintText: 'Enter task...',
              onSubmit: (text) => submittedText = text,
            ),
          ),
        ),
      );

      expect(find.text('Enter task...'), findsOneWidget);
      
      await tester.enterText(find.byType(TextField), 'Test task');
      await tester.tap(find.byIcon(Icons.send));
      await tester.pump();

      expect(submittedText, 'Test task');
    });

    testWidgets('TaskItem displays task information correctly', (WidgetTester tester) async {
      final task = Task(
        id: '1',
        title: 'Test Task',
        description: 'Test Description',
        createdAt: DateTime.now(),
        priority: TaskPriority.high,
        isCompleted: false,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TaskItem(task: task),
          ),
        ),
      );

      expect(find.text('Test Task'), findsOneWidget);
      expect(find.text('Test Description'), findsOneWidget);
      expect(find.text('High'), findsOneWidget);
    });

    testWidgets('TaskItem shows completed state correctly', (WidgetTester tester) async {
      final task = Task(
        id: '1',
        title: 'Completed Task',
        description: 'Completed Description',
        createdAt: DateTime.now(),
        isCompleted: true,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TaskItem(task: task),
          ),
        ),
      );

      expect(find.text('Completed Task'), findsOneWidget);
      expect(find.byIcon(Icons.check), findsOneWidget);
    });

    testWidgets('TaskItem handles toggle callback', (WidgetTester tester) async {
      bool toggled = false;
      
      final task = Task(
        id: '1',
        title: 'Toggle Task',
        description: 'Toggle Description',
        createdAt: DateTime.now(),
        isCompleted: false,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TaskItem(
              task: task,
              onToggle: () => toggled = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(GestureDetector).first);
      expect(toggled, true);
    });

    testWidgets('App displays login screen when not authenticated', (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => AuthProvider()),
            ChangeNotifierProvider(create: (_) => TaskProvider()),
            ChangeNotifierProvider(create: (_) => SettingsProvider()),
          ],
          child: MaterialApp(
            home: const AuthWrapper(),
          ),
        ),
      );

      expect(find.text('GeminiTaskSync'), findsOneWidget);
      expect(find.text('Sign in to your account'), findsOneWidget);
    });
  });
}
