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

  @override
  void initState() {
    super.initState();
    _exercises = _fetchExercises();
  }

  Future<List<Map<String, dynamic>>> _fetchExercises() async {
    try {
      final response = await Supabase.instance.client
          .from('Split_Mapping')
          .select()
          .eq('user_id', Supabase.instance.client.auth.currentUser!.id)
          .eq('split_id', widget.splitDayId!)
          .order('order', ascending: true);

      return response.map((item) => {
        'exercise_name': item['exercise_name'] as String,
        'exercise_id': item['id'],
      }).toList();
    } catch (e) {
      print('Error fetching exercises: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Calendar Log for ${widget.date.toLocal().toString().split(' ')[0]}'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _exercises,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No exercises found'));
          }

          final exercises = snapshot.data!;
          return ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: exercises.length,
            itemBuilder: (context, index) {
              final exercise = exercises[index];
              return ExerciseTile(
                exerciseName: exercise['exercise_name'],
                exerciseId: exercise['exercise_id'],
                date: widget.date,
              );
            },
          );
        },
      ),
    );
  }
}

class ExerciseTile extends StatefulWidget {
  final String exerciseName;
  final int exerciseId;
  final DateTime date;

  const ExerciseTile({
    Key? key,
    required this.date,
    required this.exerciseName,
    required this.exerciseId,
  }) : super(key: key);

  @override
  _ExerciseTileState createState() => _ExerciseTileState();
}

class _ExerciseTileState extends State<ExerciseTile> {
  bool _isExpanded = false;
  int _weight = 0;
  int _reps = 0;
  late Future<List<Map<String, dynamic>>> _logs;

  @override
  void initState() {
    super.initState();
    _logs = _fetchLogs();
  }

  Future<List<Map<String, dynamic>>> _fetchLogs() async {
    try {
      final response = await Supabase.instance.client
          .from('Exercise_Logs')
          .select()
          .eq('split_mapping_id', widget.exerciseId)
          .eq('date', widget.date.toIso8601String())
          .eq('user_id', Supabase.instance.client.auth.currentUser!.id)
          .order('date', ascending: false);

      return response.map((item) => {
        'weight': item['weight'],
        'reps': item['reps'],
        'date': item['date'],
      }).toList();
    } catch (e) {
      print('Error fetching logs: $e');
      return [];
    }
  }

  Future<void> _logWeightReps() async {
    try {
      await Supabase.instance.client.from('Exercise_Logs').insert({
        'split_mapping_id': widget.exerciseId,
        'weight': _weight,
        'reps': _reps,
        'date': widget.date.toIso8601String(),
        'user_id': Supabase.instance.client.auth.currentUser!.id,
      });
      setState(() {
        _logs = _fetchLogs();
      });
    } catch (e) {
      print('Error logging weight/reps: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: ExpansionTile(
        title: Text(
          widget.exerciseName,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        initiallyExpanded: _isExpanded,
        onExpansionChanged: (expanded) {
          setState(() {
            _isExpanded = expanded;
          });
        },
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                FutureBuilder<List<Map<String, dynamic>>>(
                  future: _logs,
                  builder: (context, snapshot) {
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Text('No logs found');
                    }
                    return Column(
                      children: snapshot.data!.map((log) {
                        return ListTile(
                          title: Text('Weight: ${log['weight']} lbs'),
                          subtitle: Text('Reps: ${log['reps']}'),
                        );
                      }).toList(),
                    );
                  },
                ),
                TextField(
                  decoration: InputDecoration(labelText: 'Weight (lbs)'),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    _weight = int.tryParse(value) ?? 0;
                  },
                ),
                TextField(
                  decoration: InputDecoration(labelText: 'Reps'),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    _reps = int.tryParse(value) ?? 0;
                  },
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    if (_weight > 0 && _reps > 0) {
                      _logWeightReps();
                    }
                  },
                  child: Text('Add'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
