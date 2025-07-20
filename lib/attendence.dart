import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AttendanceManager extends StatefulWidget {
  final String userName;
  const AttendanceManager({super.key, required this.userName});

  @override
  State<AttendanceManager> createState() => _AttendanceManagerState();
}

class _AttendanceManagerState extends State<AttendanceManager> {
  List<Map<String, String>> attendanceRows = [];
  String formattedDate = '';
  String dayName = '';
  String checkInTime = '';
  String checkOutTime = '';
  String timeSpent = '';
  int checkInStatus = 0;
  int checkOutStatus = 0;
  String status = '';
  String clr = 'green';

  String formattedDatec = '';
  String dayNamec = '';
  String checkInTimec = '';
  String checkInStatusc = '0';

  @override
  void initState() {
    super.initState();
    loadRows();
    displayTodayAttendanceRow();
    statusAttendence();
  }

  void statusAttendence() {
    formattedDatec != formattedDate ? saveAttendanceRow : null;
  }

  Future<void> loadRows() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      List<String> encodedList = prefs.getStringList('attendanceList') ?? [];

      setState(() {
        attendanceRows =
            encodedList
                .map((item) => Map<String, String>.from(jsonDecode(item)))
                .toList();
      });
    } catch (e, stacktrace) {
      Logger().e('Error loading attendance rows: $e $stacktrace');
    }
  }

  Future<void> saveAttendanceRow2({
    required String date,
    required String day,
    required String checkIn,
    required String stats,
  }) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();

      Map<String, String> newRow = {
        'datec': date,
        'dayc': day,
        'checkInc': checkIn,
        'statusc': stats,
      };

      List<String> existingList = prefs.getStringList('attendanceList2') ?? [];

      List<Map<String, String>> decodedList =
          existingList
              .map((e) => Map<String, String>.from(jsonDecode(e)))
              .toList();

      bool updated = false;
      for (int i = 0; i < decodedList.length; i++) {
        if (decodedList[i]['datec'] == date) {
          decodedList[i] = newRow;
          updated = true;
          break;
        }
      }

      if (!updated) {
        decodedList.add(newRow);
      }

      List<String> updatedList =
          decodedList.map((row) => jsonEncode(row)).toList();
      await prefs.setStringList('attendanceList2', updatedList);
    } catch (e, stacktrace) {
      Logger().e('Error loading attendance rows2: $e $stacktrace');
    }
  }

  Future<void> saveAttendanceRow({
    required String date,
    required String day,
    required String checkIn,
    required String checkOut,
    required String spent,
    required String stats,
  }) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();

      Map<String, String> row = {
        'date': date,
        'day': day,
        'checkIn': checkIn,
        'checkOut': checkOut,
        'spent': spent,
        'status': stats,
      };

      List<String> existing = prefs.getStringList('attendanceList') ?? [];
      existing.add(jsonEncode(row));
      await prefs.setStringList('attendanceList', existing);
    } catch (e, stacktrace) {
      Logger().e('Error loading attendance rows: $e $stacktrace');
    }
  }

  Future<void> displayTodayAttendanceRow() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      List<String> encodedList = prefs.getStringList('attendanceList2') ?? [];
      List<Map<String, String>> rows =
          encodedList
              .map((e) => Map<String, String>.from(jsonDecode(e)))
              .toList();
      String today = DateFormat('MM/dd/yyyy').format(DateTime.now());
      for (var row in rows) {
        if (row['datec'] == today) {
          setState(() {
            formattedDatec = row['datec']!;
            dayNamec = row['dayc']!;
            checkInTimec = row['checkInc']!;
            checkInStatusc = row['statusc']!;
          });
          break;
        }
      }
    } catch (e, stacktrace) {
      Logger().e('Error displaying today attendance row: $e $stacktrace');
    }
  }

  String getTimeSpent(String checkIn, String checkOut) {
    try {
      DateFormat format = DateFormat('HH:mm');
      DateTime checkInDT = format.parse(checkIn);
      DateTime checkOutDT = format.parse(checkOut);
      if (checkOutDT.isBefore(checkInDT)) return 'Invalid';

      final duration = checkOutDT.difference(checkInDT);
      final hours = duration.inHours;
      final minutes = duration.inMinutes % 60;
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}';
    } catch (e, stacktrace) {
      Logger().e('Error calculating time spent: $e $stacktrace');
      return 'Error';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 20),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: const Color.fromARGB(255, 11, 5, 91),
                    width: 2,
                  ),
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    Text(
                      'Hello ${widget.userName}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 27, 21, 111),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text('Date : $formattedDatec'),
                        Text('Day : $dayNamec'),
                        Text('Check-In time : $checkInTimec'),
                        Text('Check-Out time : $checkOutTime'),
                        Text('Time spent : $timeSpent'),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('Status : '),
                            Text(
                              status,
                              style: const TextStyle(
                                color: Color.fromARGB(255, 47, 174, 51),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 120,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color.fromARGB(
                                255,
                                27,
                                21,
                                111,
                              ),
                            ),
                            onPressed: () {
                              setState(() {
                                checkInStatus = 1;
                                checkInTime = DateFormat(
                                  'HH:mm',
                                ).format(DateTime.now());
                                formattedDate = DateFormat(
                                  'MM/dd/yyyy',
                                ).format(DateTime.now());
                                dayName = DateFormat(
                                  'EEEE',
                                ).format(DateTime.now());
                                saveAttendanceRow2(
                                  date: formattedDate,
                                  day: dayName,
                                  checkIn: checkInTime,
                                  stats: checkInStatus.toString(),
                                );
                                displayTodayAttendanceRow();
                                checkOutTime = '';
                                timeSpent = '';
                                status = '';
                              });
                            },
                            child: const Text(
                              'Check In',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 40),
                        SizedBox(
                          width: 120,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color.fromARGB(
                                255,
                                27,
                                21,
                                111,
                              ),
                            ),
                            onPressed: () async {
                              setState(() {
                                checkOutStatus = 1;
                                displayTodayAttendanceRow();
                                checkOutTime = DateFormat(
                                  'HH:mm',
                                ).format(DateTime.now());
                                timeSpent = getTimeSpent(
                                  checkInTimec,
                                  checkOutTime,
                                );

                                if (checkInStatusc == '1' &&
                                    checkOutStatus == 1) {
                                  status = 'Present';
                                } else if ((checkInStatusc == '1' &&
                                        checkOutStatus == 0) ||
                                    (checkInStatusc == '0' &&
                                        checkOutStatus == 1)) {
                                  status = 'Incomplete';
                                } else {
                                  status = 'Absent';
                                }
                              });
                              await saveAttendanceRow(
                                date: formattedDatec,
                                day: dayNamec,
                                checkIn: checkInTimec,
                                checkOut: checkOutTime,
                                spent: timeSpent,
                                stats: status,
                              );

                              await loadRows();

                              saveAttendanceRow2(
                                date: '',
                                day: '',
                                checkIn: '',
                                stats: '',
                              );
                            },
                            child: const Text(
                              'Check Out',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              const Divider(),
              const Text(
                'Attendance Records',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: ListView.builder(
                  itemCount: attendanceRows.length,
                  itemBuilder: (context, index) {
                    final row = attendanceRows[index];
                    final statusColor =
                        row['status'].toString().toLowerCase() == 'absent'
                            ? Colors.red
                            : Colors.green;
                    return Card(
                      color: const Color(0xFFD1FFFE),
                      margin: const EdgeInsets.all(8),
                      child: ListTile(
                        title: Text('Date: ${row['date']} (${row['day']})'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Check In: ${row['checkIn']}'),
                            Text('Check Out: ${row['checkOut']}'),
                            Text('Spent: ${row['spent']}'),
                            Row(
                              children: [
                                const Text('Status: '),
                                Text(
                                  '${row['status']}',
                                  style: TextStyle(color: statusColor),
                                ),
                              ],
                            ),
                          ],
                        ),
                        trailing: Image.asset(
                          'assets/2.jpg',
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
