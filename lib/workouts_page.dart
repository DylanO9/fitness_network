import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'add_exercise_page.dart';

class DayPage extends StatefulWidget {
  final String day;

  DayPage({required this.day});

  @override
  State<DayPage> createState() => _DayPageState();
}

class _DayPageState extends State<DayPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.day),
      ),
      body: Center(
        child: 
            ListView.builder(
              itemCount: 0,
              scrollDirection: Axis.vertical,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SizedBox(
                    width: double.infinity,
                    child: Stack(
                      children: [
                        SizedBox(
                          width: double.infinity,
                          height: 200,
                          child: ListTile(
                          title: Text('Exercise $index'),
                          subtitle: Text('Details about exercise $index'),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: BorderSide(color: Colors.grey, width: 1),
                          ),
                          ),
                        ),
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () {
                              print('Delete exercise $index');
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AddExercisePage(day: widget.day),
          ),
        );
      },
      backgroundColor: Colors.blue,
      child: Icon(Icons.add),
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
