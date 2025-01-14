import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'day_page.dart';

class WorkoutsPage extends StatefulWidget {
  @override
  State<WorkoutsPage> createState() => _WorkoutsPageState();
}

class _WorkoutsPageState extends State<WorkoutsPage> {
  DateTime _selectedDay = DateTime.now();
  late Future<List<Map<String, dynamic>>> _splitDays;

  @override
  void initState() {
    super.initState();
    _splitDays = _fetchSplitDays(); // Initialize the future here
  }

  Future<List<Map<String, dynamic>>> _fetchSplitDays() async {
    try {
      final response = await Supabase.instance.client
          .from('Split_Days')
          .select()
          .eq('user_id', Supabase.instance.client.auth.currentUser!.id);
      print('Response: $response');
      final data = response as List<dynamic>;
      return data.map((item) => {
        'split_name': item['split_name'],
        'id': item['id'],
      }).toList();
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
              child: FutureBuilder<List<Map<String, dynamic>>>(
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
                                builder: (context) => DayPage(day: day['split_name'], day_id: day['id']),
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
                            day['split_name'],
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
              .insert({'user_id': Supabase.instance.client.auth.currentUser!.id,'split_name': 'Push'});
          print('Response: $response');
        },
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add),
      ),
    );
  }
}