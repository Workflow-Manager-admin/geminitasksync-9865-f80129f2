import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/task.dart';
import '../providers/task_provider.dart';
import '../widgets/custom_button.dart';

class TaskDetailScreen extends StatefulWidget {
  final Task? task;

  const TaskDetailScreen({super.key, this.task});

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  DateTime? _dueDate;
  DateTime? _reminderTime;
  TaskPriority _priority = TaskPriority.medium;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _isEditing = widget.task == null;
    
    if (widget.task != null) {
      _titleController.text = widget.task!.title;
      _descriptionController.text = widget.task!.description;
      _dueDate = widget.task!.dueDate;
      _reminderTime = widget.task!.reminderTime;
      _priority = widget.task!.priority;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isNewTask = widget.task == null;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(isNewTask ? 'New Task' : 'Task Details'),
        backgroundColor: const Color(0xFF6200EE),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (!isNewTask && !_isEditing)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => setState(() => _isEditing = true),
            ),
        ],
      ),
      body: Consumer<TaskProvider>(
        builder: (context, taskProvider, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTitleField(),
                  const SizedBox(height: 16),
                  _buildDescriptionField(),
                  const SizedBox(height: 24),
                  _buildPrioritySection(),
                  const SizedBox(height: 24),
                  _buildDateTimeSection(),
                  const SizedBox(height: 32),
                  if (_isEditing) _buildActionButtons(taskProvider),
                  if (!_isEditing && widget.task != null) _buildTaskInfo(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTitleField() {
    return TextFormField(
      controller: _titleController,
      decoration: InputDecoration(
        labelText: 'Task Title',
        prefixIcon: const Icon(Icons.title),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF6200EE), width: 2),
        ),
      ),
      enabled: _isEditing,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter a task title';
        }
        return null;
      },
    );
  }

  Widget _buildDescriptionField() {
    return TextFormField(
      controller: _descriptionController,
      maxLines: 4,
      decoration: InputDecoration(
        labelText: 'Description',
        prefixIcon: const Icon(Icons.description),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF6200EE), width: 2),
        ),
        alignLabelWithHint: true,
      ),
      enabled: _isEditing,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter a description';
        }
        return null;
      },
    );
  }

  Widget _buildPrioritySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Priority',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          children: TaskPriority.values.map((priority) {
            final isSelected = _priority == priority;
            return FilterChip(
              label: Text(priority.displayName),
              selected: isSelected,
              onSelected: _isEditing ? (selected) {
                if (selected) {
                  setState(() => _priority = priority);
                }
              } : null,
              selectedColor: _getPriorityColor(priority).withOpacity(0.2),
              checkmarkColor: _getPriorityColor(priority),
              side: BorderSide(color: _getPriorityColor(priority)),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildDateTimeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDateSection(),
        const SizedBox(height: 16),
        _buildReminderSection(),
      ],
    );
  }

  Widget _buildDateSection() {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.calendar_today),
      title: const Text('Due Date'),
      subtitle: Text(_dueDate != null 
        ? DateFormat('MMM dd, yyyy').format(_dueDate!)
        : 'No due date set'),
      trailing: _isEditing ? IconButton(
        icon: const Icon(Icons.edit),
        onPressed: _selectDueDate,
      ) : null,
      onTap: _isEditing ? _selectDueDate : null,
    );
  }

  Widget _buildReminderSection() {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.notifications),
      title: const Text('Reminder'),
      subtitle: Text(_reminderTime != null 
        ? DateFormat('MMM dd, yyyy - HH:mm').format(_reminderTime!)
        : 'No reminder set'),
      trailing: _isEditing ? IconButton(
        icon: const Icon(Icons.edit),
        onPressed: _selectReminderTime,
      ) : null,
      onTap: _isEditing ? _selectReminderTime : null,
    );
  }

  Widget _buildActionButtons(TaskProvider taskProvider) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: CustomButton(
            text: widget.task != null ? 'Update Task' : 'Create Task',
            isLoading: taskProvider.isLoading,
            onPressed: () => _saveTask(taskProvider),
          ),
        ),
        const SizedBox(height: 12),
        if (widget.task != null) ...[
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => setState(() => _isEditing = false),
              child: const Text('Cancel'),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildTaskInfo() {
    final task = widget.task!;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Task Information',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoRow('Created', DateFormat('MMM dd, yyyy - HH:mm').format(task.createdAt)),
            _buildInfoRow('Status', task.isCompleted ? 'Completed' : 'Pending'),
            if (task.isCompleted) 
              _buildInfoRow('Priority', task.priority.displayName),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  Color _getPriorityColor(TaskPriority priority) {
    switch (priority) {
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

  Future<void> _selectDueDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (date != null) {
      setState(() => _dueDate = date);
    }
  }

  Future<void> _selectReminderTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _reminderTime ?? _dueDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (date != null && mounted) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_reminderTime ?? DateTime.now()),
      );

      if (time != null) {
        setState(() {
          _reminderTime = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  Future<void> _saveTask(TaskProvider taskProvider) async {
    if (!_formKey.currentState!.validate()) return;

    final task = Task(
      id: widget.task?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      createdAt: widget.task?.createdAt ?? DateTime.now(),
      dueDate: _dueDate,
      reminderTime: _reminderTime,
      priority: _priority,
      isCompleted: widget.task?.isCompleted ?? false,
      userId: widget.task?.userId,
    );

    if (widget.task != null) {
      await taskProvider.updateTask(task);
    } else {
      await taskProvider.addTask(task);
    }

    if (mounted) {
      Navigator.pop(context);
    }
  }
}
