import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Attendify ',
              style: TextStyle(
                fontSize: 25,
                color: Color.fromARGB(255, 16, 8, 125),
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 15),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Employee Attendance & Tasks App',
                  style: TextStyle(
                    fontSize: 18,
                    color: Color.fromARGB(255, 16, 8, 125),
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 15),
                Text(
                  'Developed by: Damsara Wishwajith\nDate: 2025/07/19',
                  style: TextStyle(
                    fontSize: 15,
                    color: Color.fromARGB(255, 16, 8, 125),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
