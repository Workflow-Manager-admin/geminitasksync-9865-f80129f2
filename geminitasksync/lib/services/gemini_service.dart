import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/task.dart';
import '../models/api_config.dart';

class GeminiService {
  static const String _baseUrl = 'https://generativelanguage.googleapis.com/v1beta/models';
  
  // PUBLIC_INTERFACE
  /// Converts user instruction to structured task using Gemini API
  Future<Task> convertInstructionToTask(String instruction, ApiConfig config) async {
    try {
      final prompt = _buildPrompt(instruction);
      final response = await _callGeminiApi(prompt, config);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return _parseGeminiResponse(data, instruction);
      } else {
        throw Exception('Failed to convert instruction: ${response.statusCode}');
      }
    } catch (e) {
      // Fallback to manual parsing if API fails
      return _fallbackTaskCreation(instruction);
    }
  }

  String _buildPrompt(String instruction) {
    return '''
    Convert the following instruction into a structured task. Extract:
    - Title (brief, actionable)
    - Description (detailed breakdown)
    - Due date (if mentioned, format: YYYY-MM-DD)
    - Priority (low, medium, high, urgent based on urgency indicators)
    - Reminder time (if specified, format: YYYY-MM-DD HH:MM)
    
    Instruction: "$instruction"
    
    Respond in JSON format:
    {
      "title": "...",
      "description": "...",
      "dueDate": "YYYY-MM-DD or null",
      "priority": "low|medium|high|urgent",
      "reminderTime": "YYYY-MM-DD HH:MM or null"
    }
    ''';
  }

  Future<http.Response> _callGeminiApi(String prompt, ApiConfig config) async {
    final url = Uri.parse('$_baseUrl/${config.geminiModel}:generateContent?key=${config.geminiApiKey}');
    
    final body = json.encode({
      'contents': [{
        'parts': [{'text': prompt}]
      }],
      'generationConfig': {
        'temperature': config.temperature,
        'maxOutputTokens': config.maxTokens,
      }
    });

    return await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: body,
    );
  }

  Task _parseGeminiResponse(Map<String, dynamic> data, String originalInstruction) {
    try {
      final content = data['candidates'][0]['content']['parts'][0]['text'];
      final jsonMatch = RegExp(r'\{.*\}', dotAll: true).firstMatch(content);
      
      if (jsonMatch != null) {
        final taskData = json.decode(jsonMatch.group(0)!);
        
        return Task(
          id: _generateId(),
          title: taskData['title'] ?? _extractTitle(originalInstruction),
          description: taskData['description'] ?? originalInstruction,
          createdAt: DateTime.now(),
          dueDate: _parseDate(taskData['dueDate']),
          reminderTime: _parseDateTime(taskData['reminderTime']),
          priority: _parsePriority(taskData['priority']),
        );
      }
    } catch (e) {
      // If parsing fails, use fallback
    }
    
    return _fallbackTaskCreation(originalInstruction);
  }

  Task _fallbackTaskCreation(String instruction) {
    return Task(
      id: _generateId(),
      title: _extractTitle(instruction),
      description: instruction,
      createdAt: DateTime.now(),
      priority: _detectPriority(instruction),
      dueDate: _extractDate(instruction),
    );
  }

  String _extractTitle(String instruction) {
    // Extract first sentence or up to 50 characters
    final sentences = instruction.split(RegExp(r'[.!?]'));
    String title = sentences.first.trim();
    
    if (title.length > 50) {
      title = title.substring(0, 47) + '...';
    }
    
    return title.isEmpty ? 'New Task' : title;
  }

  TaskPriority _detectPriority(String instruction) {
    final lowerInstruction = instruction.toLowerCase();
    
    if (lowerInstruction.contains(RegExp(r'\b(urgent|asap|immediately|critical|emergency)\b'))) {
      return TaskPriority.urgent;
    } else if (lowerInstruction.contains(RegExp(r'\b(important|high|priority|soon)\b'))) {
      return TaskPriority.high;
    } else if (lowerInstruction.contains(RegExp(r'\b(low|later|whenever|optional)\b'))) {
      return TaskPriority.low;
    }
    
    return TaskPriority.medium;
  }

  DateTime? _extractDate(String instruction) {
    final datePatterns = [
      RegExp(r'\b(today|tomorrow|yesterday)\b', caseSensitive: false),
      RegExp(r'\b(\d{1,2}[/-]\d{1,2}[/-]\d{2,4})\b'),
      RegExp(r'\b(\d{4}-\d{2}-\d{2})\b'),
    ];

    for (final pattern in datePatterns) {
      final match = pattern.firstMatch(instruction);
      if (match != null) {
        return _parseRelativeDate(match.group(0)!);
      }
    }

    return null;
  }

  DateTime? _parseDate(String? dateString) {
    if (dateString == null || dateString == 'null') return null;
    try {
      return DateTime.parse(dateString);
    } catch (e) {
      return null;
    }
  }

  DateTime? _parseDateTime(String? dateTimeString) {
    if (dateTimeString == null || dateTimeString == 'null') return null;
    try {
      return DateTime.parse(dateTimeString);
    } catch (e) {
      return null;
    }
  }

  TaskPriority _parsePriority(String? priorityString) {
    switch (priorityString?.toLowerCase()) {
      case 'urgent':
        return TaskPriority.urgent;
      case 'high':
        return TaskPriority.high;
      case 'low':
        return TaskPriority.low;
      default:
        return TaskPriority.medium;
    }
  }

  DateTime? _parseRelativeDate(String dateString) {
    final now = DateTime.now();
    final lowerDate = dateString.toLowerCase();

    if (lowerDate.contains('today')) {
      return DateTime(now.year, now.month, now.day);
    } else if (lowerDate.contains('tomorrow')) {
      return DateTime(now.year, now.month, now.day + 1);
    } else if (lowerDate.contains('yesterday')) {
      return DateTime(now.year, now.month, now.day - 1);
    }

    // Try to parse date formats
    try {
      return DateTime.parse(dateString);
    } catch (e) {
      return null;
    }
  }

  String _generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }
}
