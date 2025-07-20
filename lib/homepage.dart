import 'package:emp/about.dart';
import 'package:emp/attendence.dart';
import 'package:emp/task.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  _HomepageScreenState createState() => _HomepageScreenState();
}

class _HomepageScreenState extends State<Homepage> {
  final TextEditingController _controller = TextEditingController();
  String? _savedName;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadSavedName();
  }

  Future<void> _loadSavedName() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _savedName = prefs.getString('user_name');
      });
      Logger().i('Loaded saved name: $_savedName');
    } catch (e) {
      Logger().e('Error loading saved name: $e');
    }
  }

  Future<void> _saveName(String name) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_name', name);
      setState(() {
        _savedName = name;
      });
      Logger().i('Loaded saved name: $_savedName');
    } catch (e) {
      Logger().e('Error loading saved name: $e');
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    Logger().i('Selected index changed to: $index');
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Employee Attendance & Tasks App',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color.fromARGB(255, 11, 5, 91),
      ),
      body:
          _savedName == null
              ? SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/1.jpg',
                        width: 400,
                        height: 400,
                        fit: BoxFit.cover,
                      ),
                      Text(
                        'TrackTango',
                        style: TextStyle(
                          color: const Color.fromARGB(255, 11, 5, 91),
                          fontWeight: FontWeight.bold,
                          fontSize: 40,
                        ),
                      ),
                      const Text(
                        'Suggests smooth tracking of attendance and tasks.',
                      ),
                      const SizedBox(height: 15),
                      SizedBox(
                        width: 350,
                        child: TextField(
                          controller: _controller,
                          decoration: const InputDecoration(
                            labelText: 'Enter your name',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(10),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: 350,
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color.fromARGB(
                              255,
                              16,
                              8,
                              125,
                            ),
                          ),
                          onPressed: () {
                            if (_controller.text.isNotEmpty) {
                              _saveName(_controller.text);
                            } else {
                              Logger().i('Name field is empty, not saving.');
                            }
                          },
                          child: const Text(
                            'Save Name',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 21,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
              : _selectedIndex == 0
              ? Center(child: AttendanceManager(userName: _savedName!))
              : _selectedIndex == 1
              ? const Center(child: TaskManager())
              : const Center(child: AboutScreen()),
      bottomNavigationBar:
          _savedName == null
              ? null
              : BottomNavigationBar(
                currentIndex: _selectedIndex,
                onTap: _onItemTapped,
                items: const [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.access_time),
                    label: 'Attendance',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.task),
                    label: 'Tasks',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.info),
                    label: 'About',
                  ),
                ],
              ),
    );
  }
}
