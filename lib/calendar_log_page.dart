import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CalendarLogPage extends StatefulWidget {
  final DateTime date;
  final int? splitDayId;

  const CalendarLogPage({Key? key, required this.date, this.splitDayId}) : super(key: key);

  @override
  State<CalendarLogPage> createState() => _CalendarLogPageState();
}

class _CalendarLogPageState extends State<CalendarLogPage> {
  late Future<List<Map<String, dynamic>>> _exercises;
  late Future<List<Map<String, dynamic>>> _splitDays;

  @override
  void initState() {
    super.initState();
    _splitDays = _fetchSplitDays(); // Initialize the future here
    _exercises = _fetchExercises();
  }

  // Grab all the information related to the split such as split_name and all related exercises
  Future<List<Map<String, dynamic>>> _fetchSplitDays() async {
    try {
      final response = await Supabase.instance.client
          .from('Split_Days')
          .select()
          .eq('id', widget.splitDayId!);
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

  Future<List<Map<String, dynamic>>> _fetchExercises() async {
    try {
      final response = await Supabase.instance.client
          .from('Split_Mapping')
          .select()
          .eq('user_id', Supabase.instance.client.auth.currentUser!.id)
          .eq('split_id', widget.splitDayId!)
          .order('order', ascending: true); // Order by the 'order' column

      print('Response: $response');
      return response.map((item) => {
        'exercise_name': item['exercise_name'] as String,
        'reps': (item['reps'] ?? 0) as int,
        'sets': (item['sets'] ?? 0) as int,
        'order': item['order'] as int, // Include the order in the map
      }).toList();
    } catch (e) {
      print('Error fetching exercises: $e');
      return [];
    }
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Calendar Log for ${widget.date.toLocal().toString().split(' ')[0]}'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _exercises,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: Colors.white));
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
                'No exercises found',
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          final exercises = snapshot.data!;
          return ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: exercises.length,
            itemBuilder: (context, index) {
              final exercise = exercises[index];

              return Card(
                elevation: 4,
                margin: EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Exercise Name
                      Text(
                        exercise['exercise_name'],
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[800],
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
    );
  }
}
