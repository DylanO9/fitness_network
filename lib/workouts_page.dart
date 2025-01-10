import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

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
        child: Column(

        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
        print('Add to workout');
      },
      child: Icon(Icons.add),
      backgroundColor: Colors.blue,
      ),
    );
  }
}

class WorkoutsPage extends StatefulWidget {
  @override
  State<WorkoutsPage> createState() => _WorkoutsPageState();
}

class _WorkoutsPageState extends State<WorkoutsPage> {
  DateTime _selectedDay = DateTime.now();
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          const Text(
            'Workouts',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          // Add widget for calendar
          TableCalendar(
            focusedDay: DateTime.now(), 
            firstDay: DateTime(2025, 1, 1), 
            lastDay: DateTime(2026, 12, 31),
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) => setState(() {
              _selectedDay = selectedDay;
            }),
            ),
          for (var day in [
            'Monday',
            'Tuesday',
            'Wednesday',
            'Thursday',
            'Friday',
            'Saturday',
            'Sunday'
          ])
            Padding(
              padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 0.0),
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
                side: BorderSide(color: Colors.grey), // Add border here
                ),
                backgroundColor: Colors.white,
              ),
              child: Text(
                day,
                style: TextStyle(
                fontSize: 18,
                color: Colors.black,
                ),
              ),
              ),
            ),
        ],
      ),
    );
  }
}
