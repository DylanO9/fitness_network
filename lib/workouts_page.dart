import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'day_page.dart';
import 'calendar_log_page.dart'; // New page for displaying calendar logs

class WorkoutsPage extends StatefulWidget {
  @override
  State<WorkoutsPage> createState() => _WorkoutsPageState();
}

class _WorkoutsPageState extends State<WorkoutsPage> {
  DateTime _selectedDay = DateTime.now();
  late Future<List<Map<String, dynamic>>> _splitDays;
  final Map<DateTime, List<Map<String, dynamic>>> _calendarLogs = {}; // Track calendar logs

  @override
  void initState() {
    super.initState();
    _splitDays = _fetchSplitDays(); // Initialize the future here
    _fetchCalendarLogs(); // Fetch existing calendar logs
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

  Future<void> _fetchCalendarLogs() async {
    try {
      final response = await Supabase.instance.client
          .from('Calendar_Logs')
          .select()
          .eq('user_id', Supabase.instance.client.auth.currentUser!.id);

      print('Calendar Logs Response: $response');

      Map<DateTime, List<Map<String, dynamic>>> tempLogs = {};

      for (var log in response) {
        final date = DateTime.parse(log['date']).toUtc(); // Store in UTC
        final normalizedDate = DateTime(date.year, date.month, date.day);
        
        if (!tempLogs.containsKey(normalizedDate)) {
          tempLogs[normalizedDate] = [];
        }
        tempLogs[normalizedDate]!.add(log);
      }

      setState(() {
        _calendarLogs.clear();
        _calendarLogs.addAll(tempLogs);
      });

    } catch (e) {
      print('Error fetching calendar logs: $e');
    }
  }

  void _deleteSplitDay(int id) async {
    try {
      final response = await Supabase.instance.client
          .from('Split_Days')
          .delete()
          .eq('user_id', Supabase.instance.client.auth.currentUser!.id)
          .eq('id', id);
      print('Response: $response');
      setState(() {
        _splitDays = _fetchSplitDays();
      });
    } catch (e) {
      print('Error deleting split day: $e');
    }
  }

  Future<void> _logCalendarLog(int splitDayId, DateTime date) async {
    try {
      await Supabase.instance.client
          .from('Calendar_Logs')
          .insert({
            'user_id': Supabase.instance.client.auth.currentUser!.id,
            'split_id': splitDayId,
            'date': date.toIso8601String(),
          });
      
      setState(() {
        final normalizedDate = DateTime(date.year, date.month, date.day);
        _calendarLogs[normalizedDate] = [..._calendarLogs[normalizedDate] ?? [], {'split_id': splitDayId}];
        print(_calendarLogs);
      });
    } catch (e) {
      print('Error logging calendar log: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue[800]!, Colors.blue[400]!],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            // Calendar Section
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                elevation: 6,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TableCalendar(
                    focusedDay: _selectedDay,
                    firstDay: DateTime(2025, 1, 1),
                    lastDay: DateTime(2026, 12, 31),
                    selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                    onDaySelected: (selectedDay, focusedDay) {
                      final normalizedDate = DateTime(selectedDay.year, selectedDay.month, selectedDay.day);
                      setState(() {
                        _selectedDay = normalizedDate;
                      });

                      final logsForDate = _calendarLogs[normalizedDate];
                      final splitDayId = logsForDate?.isNotEmpty == true ? logsForDate?.first['split_id'] : null;

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CalendarLogPage(
                            date: normalizedDate,
                            splitDayId: splitDayId,
                          ),
                        ),
                      );
                    },
                    calendarStyle: CalendarStyle(
                      todayDecoration: BoxDecoration(
                        color: Colors.blue[800],
                        shape: BoxShape.circle,
                      ),
                      selectedDecoration: BoxDecoration(
                        color: Colors.blue[400],
                        shape: BoxShape.circle,
                      ),
                      markersAlignment: Alignment.bottomCenter,
                      markersAutoAligned: true,
                      markerDecoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                    eventLoader: (date) {
                      final normalizedDate = DateTime(date.year, date.month, date.day);
                      return _calendarLogs[normalizedDate] ?? [];
                    },
                  ),
                ),
              ),
            ),

            // Split Days Section
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: _splitDays,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Error: ${snapshot.error}',
                        style: TextStyle(color: Colors.white),
                      ),
                    );
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(
                      child: Text(
                        'No split days found',
                        style: TextStyle(color: Colors.white),
                      ),
                    );
                  }

                  final splitDays = snapshot.data!;
                  return GridView.builder(
                    padding: const EdgeInsets.all(16.0),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 1.5,
                    ),
                    itemCount: splitDays.length,
                    itemBuilder: (context, index) {
                      final day = splitDays[index];
                      return Draggable<Map<String, dynamic>>(
                        data: day,
                        feedback: Material(
                          child: Container(
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.blue,
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Text(
                              day['split_name'],
                              style: TextStyle(color: Colors.white, fontSize: 18),
                            ),
                          ),
                        ),
                        child: Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Stack(
                            children: [
                              InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => DayPage(
                                        day: day['split_name'],
                                        day_id: day['id'],
                                      ),
                                    ),
                                  );
                                },
                                borderRadius: BorderRadius.circular(15),
                                child: Center(
                                  child: Text(
                                    day['split_name'],
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue[800],
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 8,
                                right: 8,
                                child: IconButton(
                                  icon: Icon(
                                    Icons.delete,
                                    color: Colors.red[400],
                                  ),
                                  onPressed: () => _deleteSplitDay(day['id']),
                                ),
                              ),
                            ],
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
      floatingActionButton: DragTarget<Map<String, dynamic>>(
        onAccept: (data) {
          _logCalendarLog(data['id'], _selectedDay);
        },
        builder: (context, candidateData, rejectedData) {
          return FloatingActionButton(
            onPressed: () async {
              // Show dialog to add new split
              await _showAddSplitDialog();
            },
            backgroundColor: Colors.white,
            child: Icon(
              Icons.add,
              color: Colors.blue[800],
            ),
          );
        },
      ),
    );
  }

  Future<void> _showAddSplitDialog() async {
    final TextEditingController _controller = TextEditingController();

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Add New Split',
            style: TextStyle(color: Colors.blue[800]),
          ),
          content: TextField(
            controller: _controller,
            decoration: InputDecoration(
              hintText: 'Enter split name',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                'Cancel',
                style: TextStyle(color: Colors.blue[800]),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(
                'Save',
                style: TextStyle(color: Colors.blue[800]),
              ),
              onPressed: () async {
                final splitName = _controller.text;
                if (splitName.isNotEmpty) {
                  await Supabase.instance.client
                      .from('Split_Days')
                      .insert({
                        'user_id': Supabase.instance.client.auth.currentUser!.id,
                        'split_name': splitName,
                      });
                  setState(() {
                    _splitDays = _fetchSplitDays();
                  });
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }
}