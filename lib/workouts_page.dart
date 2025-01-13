import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'add_exercise_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
  late Future<List<String>> _splitDays;

  @override
  void initState() {
    super.initState();
    _splitDays = _fetchSplitDays(); // Initialize the future here
  }

Future<List<String>> _fetchSplitDays() async {
    try {
      final response = await Supabase.instance.client
          .from('Split_Days')
          .select();
      print('Response: $response');
      return response.map((item) => item['split_name'] as String).toList();
    } catch (e) {
      print('Error fetching split days: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
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
            Expanded(
              child: FutureBuilder<List<String>>(
                future: _splitDays,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text('Error: ${snapshot.error}'),
                    );
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                      child: Text('No split days found'),
                    );
                  }
      
                  final splitDays = snapshot.data!;
                  return ListView.builder(
                    itemCount: splitDays.length,
                    itemBuilder: (context, index) {
                      final day = splitDays[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 8.0),
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
                            backgroundColor: Colors.white,
                          ),
                          child: Text(
                            day,
                            style: const TextStyle(
                              fontSize: 18,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final response = await Supabase.instance.client
              .from('Split_Days')
              .insert({'user_id': 1,'split_name': 'Push'});
          print('Response: $response');
        },
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add),
      ),
    );
  }
}