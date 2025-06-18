import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AppHelpers {
  // PUBLIC_INTERFACE
  /// Formats a DateTime to a readable date string
  static String formatDate(DateTime date) {
    return DateFormat('MMM dd, yyyy').format(date);
  }

  // PUBLIC_INTERFACE
  /// Formats a DateTime to a readable time string
  static String formatTime(DateTime time) {
    return DateFormat('HH:mm').format(time);
  }

  // PUBLIC_INTERFACE
  /// Formats a DateTime to a readable date-time string
  static String formatDateTime(DateTime dateTime) {
    return DateFormat('MMM dd, yyyy - HH:mm').format(dateTime);
  }

  // PUBLIC_INTERFACE
  /// Validates email format
  static bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  // PUBLIC_INTERFACE
  /// Validates password strength
  static bool isValidPassword(String password) {
    return password.length >= 6;
  }

  // PUBLIC_INTERFACE
  /// Shows a snackbar with the given message
  static void showSnackBar(BuildContext context, String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : null,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // PUBLIC_INTERFACE
  /// Shows a confirmation dialog
  static Future<bool> showConfirmationDialog(
    BuildContext context,
    String title,
    String content, {
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(cancelText),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(confirmText),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  // PUBLIC_INTERFACE
  /// Gets the relative time description (e.g., "2 days ago", "in 3 hours")
  static String getRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = dateTime.difference(now);

    if (difference.inDays > 0) {
      return 'in ${difference.inDays} day${difference.inDays == 1 ? '' : 's'}';
    } else if (difference.inDays < 0) {
      final daysPast = -difference.inDays;
      return '$daysPast day${daysPast == 1 ? '' : 's'} ago';
    } else if (difference.inHours > 0) {
      return 'in ${difference.inHours} hour${difference.inHours == 1 ? '' : 's'}';
    } else if (difference.inHours < 0) {
      final hoursPast = -difference.inHours;
      return '$hoursPast hour${hoursPast == 1 ? '' : 's'} ago';
    } else if (difference.inMinutes > 0) {
      return 'in ${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'}';
    } else if (difference.inMinutes < 0) {
      final minutesPast = -difference.inMinutes;
      return '$minutesPast minute${minutesPast == 1 ? '' : 's'} ago';
    } else {
      return 'now';
    }
  }

  // PUBLIC_INTERFACE
  /// Checks if a date is today
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }

  // PUBLIC_INTERFACE
  /// Checks if a date is tomorrow
  static bool isTomorrow(DateTime date) {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return date.year == tomorrow.year && date.month == tomorrow.month && date.day == tomorrow.day;
  }

  // PUBLIC_INTERFACE
  /// Checks if a date is overdue
  static bool isOverdue(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateOnly = DateTime(date.year, date.month, date.day);
    return dateOnly.isBefore(today);
  }

  // PUBLIC_INTERFACE
  /// Truncates text to specified length with ellipsis
  static String truncateText(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength - 3)}...';
  }

  // PUBLIC_INTERFACE
  /// Capitalizes the first letter of a string
  static String capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  // PUBLIC_INTERFACE
  /// Generates a random ID string
  static String generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  // PUBLIC_INTERFACE
  /// Debounces function calls
  static void debounce(VoidCallback callback, Duration delay) {
    Timer? timer;
    timer?.cancel();
    timer = Timer(delay, callback);
  }
}
