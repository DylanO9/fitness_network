import 'package:flutter/material.dart';

class DayPage extends StatelessWidget {
  final String day;

  DayPage({required this.day});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(day),
      ),
      body: Center(
        child: Text('Workouts for $day'),
      ),
    );
  }
}

class WorkoutsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          const Text(
            'Workouts Page',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
            for (var day in ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'])
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: ElevatedButton(
                onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                  builder: (context) => DayPage(day: day),
                  ),
                );
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero,
                  ),
                ),
                child: Text(day),
              ),
            ),
        ],
      ),
    );
  }
}