import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TaskManager extends StatefulWidget {
  const TaskManager({super.key});

  @override
  State<TaskManager> createState() => _TaskManagerState();
}

class _TaskManagerState extends State<TaskManager> {
  final TextEditingController _taskController = TextEditingController();
  final List<String> _priority = ['Low', 'Medium', 'High'];
  final List<String> _status = ['Not Started', 'In Progress', 'Done'];
  DateTime? _selectedDate;
  String? _selectedItem;
  String? _selectedStatus;

  List<Map<String, String>> _taskList = [];

  @override
  void initState() {
    super.initState();
    loadRows();
  }

  Future<void> _saveTask({
    required String task,
    required String date,
    required String priority,
    required String status,
  }) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      Map<String, dynamic> newTask = {
        'task': task,
        'date': date,
        'priority': priority,
        'status': status,
      };
      List<String> existing = prefs.getStringList('_taskList') ?? [];
      existing.add(jsonEncode(newTask));
      await prefs.setStringList('_taskList', existing);
    } catch (e, stacktrace) {
      Logger().e('Error saving task: $e $stacktrace');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save task. Please try again.')),
      );
    }
  }

  Future<void> _updateTaskStatus(int index, String newStatus) async {
    try {
      _taskList[index]['status'] = newStatus;
      List<String> updatedList =
          _taskList.map((task) => jsonEncode(task)).toList();

      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('_taskList', updatedList);

      setState(() {});
    } catch (e, stacktrace) {
      Logger().e('Error updating task status: $e $stacktrace');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update task status. Please try again.'),
        ),
      );
    }
  }

  Future<void> loadRows() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      List<String> encodedList = prefs.getStringList('_taskList') ?? [];

      setState(() {
        _taskList =
            encodedList
                .map((item) => Map<String, String>.from(jsonDecode(item)))
                .toList();
      });
    } catch (e, stacktrace) {
      Logger().e('Error loading tasks: $e $stacktrace');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load tasks. Please restart the app.'),
        ),
      );
    }
  }

  void _showAddTaskDialog() {
    showDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setState) => AlertDialog(
                  backgroundColor: const Color(0xFFD1FFFE),
                  title: const Text(
                    'Add New Task',
                    style: TextStyle(
                      color: Color.fromARGB(255, 16, 8, 125),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  content: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          height: 45,
                          child: TextField(
                            controller: _taskController,
                            decoration: const InputDecoration(
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(10),
                                ),
                              ),
                              hintText: 'Enter task name',
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.black, width: 0.7),
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Row(
                            children: [
                              Text(
                                _selectedDate == null
                                    ? '   No date selected'
                                    : '   Date: ${DateFormat('yyyy-MM-dd').format(_selectedDate!)}',
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.grey.shade600,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Spacer(),
                              IconButton(
                                icon: const Icon(Icons.calendar_today),
                                onPressed: () async {
                                  DateTime? picked = await showDatePicker(
                                    context: context,
                                    initialDate: DateTime.now(),
                                    firstDate: DateTime(2020),
                                    lastDate: DateTime(2100),
                                  );
                                  if (picked != null) {
                                    setState(() {
                                      _selectedDate = picked;
                                    });
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.black, width: 0.7),
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: DropdownButton<String>(
                            isExpanded: true,
                            hint: const Text('  Select Priority'),
                            value: _selectedItem,
                            onChanged: (String? newValue) {
                              setState(() {
                                _selectedItem = newValue;
                              });
                            },
                            items:
                                _priority
                                    .map(
                                      (value) => DropdownMenuItem(
                                        value: value,
                                        child: Text('  $value'),
                                      ),
                                    )
                                    .toList(),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.black, width: 0.7),
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: DropdownButton<String>(
                            isExpanded: true,
                            hint: const Text('  Select Status'),
                            value: _selectedStatus,
                            onChanged: (String? newValue) {
                              setState(() {
                                _selectedStatus = newValue;
                              });
                            },
                            items:
                                _status
                                    .map(
                                      (value) => DropdownMenuItem(
                                        value: value,
                                        child: Text('  $value'),
                                      ),
                                    )
                                    .toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.white,
                        minimumSize: const Size(100, 50),
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          color: Color.fromARGB(255, 16, 8, 125),
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 15),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 16, 8, 125),
                        minimumSize: const Size(100, 50),
                      ),
                      onPressed: () async {
                        if (_taskController.text.isEmpty ||
                            _selectedDate == null ||
                            _selectedItem == null ||
                            _selectedStatus == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Please fill all fields"),
                            ),
                          );
                          return;
                        }

                        await _saveTask(
                          task: _taskController.text,
                          date: DateFormat('yyyy-MM-dd').format(_selectedDate!),
                          priority: _selectedItem!,
                          status: _selectedStatus!,
                        );

                        await loadRows();

                        setState(() {
                          _taskController.clear();
                          _selectedDate = null;
                          _selectedItem = null;
                          _selectedStatus = null;
                        });

                        if (context.mounted) Navigator.pop(context);
                      },
                      child: const Text(
                        'Add',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Task Manager')),
      body:
          _taskList.isEmpty
              ? const Center(child: Text('No tasks yet.'))
              : ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: _taskList.length,
                itemBuilder: (context, index) {
                  final task = _taskList[index];
                  return Card(
                    color: const Color(0xFFD1FFFE),
                    margin: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 12,
                    ),
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      title: Text(task['task'] ?? ''),
                      subtitle: Text(
                        'Date: ${task['date']}\nPriority: ${task['priority']}',
                      ),
                      isThreeLine: true,
                      trailing: DropdownButton<String>(
                        value: task['status'],
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            _updateTaskStatus(index, newValue);
                          }
                        },
                        items:
                            _status
                                .map(
                                  (String value) => DropdownMenuItem(
                                    value: value,
                                    child: Text(value),
                                  ),
                                )
                                .toList(),
                      ),
                    ),
                  );
                },
              ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color.fromARGB(255, 159, 221, 220),
        onPressed: _showAddTaskDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
