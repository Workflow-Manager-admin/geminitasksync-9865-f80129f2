import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/task.dart';

class TaskItem extends StatelessWidget {
  final Task task;
  final VoidCallback? onTap;
  final VoidCallback? onToggle;
  final VoidCallback? onDelete;

  const TaskItem({
    super.key,
    required this.task,
    this.onTap,
    this.onToggle,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: onToggle,
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: task.isCompleted 
                            ? const Color(0xFF6200EE)
                            : Colors.grey,
                          width: 2,
                        ),
                        color: task.isCompleted 
                          ? const Color(0xFF6200EE)
                          : Colors.transparent,
                      ),
                      child: task.isCompleted
                        ? const Icon(
                            Icons.check,
                            size: 16,
                            color: Colors.white,
                          )
                        : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      task.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        decoration: task.isCompleted 
                          ? TextDecoration.lineThrough
                          : null,
                        color: task.isCompleted
                          ? Colors.grey[600]
                          : null,
                      ),
                    ),
                  ),
                  _buildPriorityChip(),
                  if (onDelete != null) ...[
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: onDelete,
                      child: Icon(
                        Icons.delete_outline,
                        color: Colors.red[400],
                        size: 20,
                      ),
                    ),
                  ],
                ],
              ),
              if (task.description.isNotEmpty) ...[
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.only(left: 36),
                  child: Text(
                    task.description,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                      decoration: task.isCompleted 
                        ? TextDecoration.lineThrough
                        : null,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.only(left: 36),
                child: Row(
                  children: [
                    if (task.dueDate != null) ...[
                      Icon(
                        Icons.calendar_today,
                        size: 14,
                        color: _getDueDateColor(),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        DateFormat('MMM dd').format(task.dueDate!),
                        style: TextStyle(
                          fontSize: 12,
                          color: _getDueDateColor(),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 16),
                    ],
                    if (task.reminderTime != null) ...[
                      Icon(
                        Icons.notifications,
                        size: 14,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        DateFormat('HH:mm').format(task.reminderTime!),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPriorityChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getPriorityColor().withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _getPriorityColor(), width: 1),
      ),
      child: Text(
        task.priority.displayName,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: _getPriorityColor(),
        ),
      ),
    );
  }

  Color _getPriorityColor() {
    switch (task.priority) {
      case TaskPriority.low:
        return Colors.green;
      case TaskPriority.medium:
        return Colors.orange;
      case TaskPriority.high:
        return Colors.red;
      case TaskPriority.urgent:
        return Colors.purple;
    }
  }

  Color _getDueDateColor() {
    if (task.dueDate == null) return Colors.grey[600]!;
    
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dueDate = DateTime(task.dueDate!.year, task.dueDate!.month, task.dueDate!.day);
    
    if (dueDate.isBefore(today)) {
      return Colors.red; // Overdue
    } else if (dueDate.isAtSameMomentAs(today)) {
      return Colors.orange; // Due today
    } else {
      return Colors.grey[600]!; // Future
    }
  }
}
