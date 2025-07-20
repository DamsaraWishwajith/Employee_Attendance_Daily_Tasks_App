import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Task {
  String name;
  DateTime dueDate;
  String priority;
  String status;

  Task({
    required this.name,
    required this.dueDate,
    required this.priority,
    required this.status,
  });

  factory Task.fromJson(Map<String, dynamic> json) => Task(
    name: json['name'],
    dueDate: DateTime.parse(json['dueDate']),
    priority: json['priority'],
    status: json['status'],
  );

  Map<String, dynamic> toJson() => {
    'name': name,
    'dueDate': dueDate.toIso8601String(),
    'priority': priority,
    'status': status,
  };
}

class TaskManagerr extends StatefulWidget {
  const TaskManagerr({super.key});

  @override
  State<TaskManagerr> createState() => _TaskManagerState();
}

class _TaskManagerState extends State<TaskManagerr> {
  List<Task> _tasks = [];
  bool _showAddForm = false;

  final TextEditingController _taskNameController = TextEditingController();
  DateTime? _selectedDueDate;
  String _selectedPriority = 'Low';
  String _selectedStatus = 'Not Started';

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final String? jsonString = prefs.getString('tasks_list');
    if (jsonString != null) {
      final List<dynamic> jsonData = jsonDecode(jsonString);
      setState(() {
        _tasks = jsonData.map((e) => Task.fromJson(e)).toList();
      });
    }
  }

  Future<void> _saveTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final String jsonString = jsonEncode(
      _tasks.map((e) => e.toJson()).toList(),
    );
    await prefs.setString('tasks_list', jsonString);
  }

  void _pickDueDate() async {
    final now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDueDate ?? now,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 5),
    );
    if (picked != null) {
      setState(() {
        _selectedDueDate = picked;
      });
    }
  }

  void _addTask() {
    if (_taskNameController.text.isEmpty) {
      _showMessage('Please enter task name');
      return;
    }
    if (_selectedDueDate == null) {
      _showMessage('Please select a due date');
      return;
    }

    final newTask = Task(
      name: _taskNameController.text,
      dueDate: _selectedDueDate!,
      priority: _selectedPriority,
      status: _selectedStatus,
    );

    setState(() {
      _tasks.add(newTask);
      _showAddForm = false;
      _taskNameController.clear();
      _selectedDueDate = null;
      _selectedPriority = 'Low';
      _selectedStatus = 'Not Started';
    });
    _saveTasks();
  }

  void _showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Widget _buildTaskList() {
    if (_tasks.isEmpty) {
      return const Center(child: Text('No tasks added yet.'));
    }
    return ListView.builder(
      itemCount: _tasks.length,
      itemBuilder: (context, index) {
        final t = _tasks[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          child: ListTile(
            title: Text(t.name),
            subtitle: Text(
              'Due: ${t.dueDate.toLocal().toString().split(' ')[0]}\nPriority: ${t.priority}\nStatus: ${t.status}',
            ),
            isThreeLine: true,
          ),
        );
      },
    );
  }

  Widget _buildAddTaskForm() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _taskNameController,
              decoration: const InputDecoration(
                labelText: 'Task Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Text(
                    _selectedDueDate == null
                        ? 'No due date selected'
                        : 'Due Date: ${_selectedDueDate!.toLocal().toString().split(' ')[0]}',
                  ),
                ),
                TextButton(
                  onPressed: _pickDueDate,
                  child: const Text('Select Due Date'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedPriority,
              decoration: const InputDecoration(
                labelText: 'Priority',
                border: OutlineInputBorder(),
              ),
              items:
                  ['Low', 'Medium', 'High']
                      .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                      .toList(),
              onChanged: (val) {
                if (val != null) {
                  setState(() {
                    _selectedPriority = val;
                  });
                }
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedStatus,
              decoration: const InputDecoration(
                labelText: 'Status',
                border: OutlineInputBorder(),
              ),
              items:
                  ['Not Started', 'In Progress', 'Done']
                      .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                      .toList(),
              onChanged: (val) {
                if (val != null) {
                  setState(() {
                    _selectedStatus = val;
                  });
                }
              },
            ),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _addTask, child: const Text('Add Task')),
            TextButton(
              onPressed: () {
                setState(() {
                  _showAddForm = false;
                  _taskNameController.clear();
                  _selectedDueDate = null;
                  _selectedPriority = 'Low';
                  _selectedStatus = 'Not Started';
                });
              },
              child: const Text('Cancel'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _showAddForm
        ? _buildAddTaskForm()
        : Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8),
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    _showAddForm = true;
                  });
                },
                child: const Text('Add Task'),
              ),
            ),
            Expanded(child: _buildTaskList()),
          ],
        );
  }

  @override
  void dispose() {
    _taskNameController.dispose();
    super.dispose();
  }
}
