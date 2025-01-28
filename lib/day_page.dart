import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'add_exercise_page.dart';

class DayPage extends StatefulWidget {
  final String day;
  final int day_id;

  DayPage({required this.day, required this.day_id});

  @override
  State<DayPage> createState() => _DayPageState();
}

class _DayPageState extends State<DayPage> {
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
          .eq('split_id', widget.day_id)
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

  Future<void> _deleteExercise(String exercise) async {
    try {
      final response = await Supabase.instance.client
          .from('Split_Mapping')
          .delete()
          .eq('user_id', Supabase.instance.client.auth.currentUser!.id)
          .eq('split_id', widget.day_id)
          .eq('exercise_name', exercise);
      print('Response: $response');
      setState(() {
        _exercises = _fetchExercises();
      });
    } catch (e) {
      print('Error deleting exercise: $e');
    }
  }

  Future<void> _updateExercise(String exercise, int reps, int sets) async {
    try {
      final response = await Supabase.instance.client
          .from('Split_Mapping')
          .update({'reps': reps, 'sets': sets})
          .eq('user_id', Supabase.instance.client.auth.currentUser!.id)
          .eq('split_id', widget.day_id)
          .eq('exercise_name', exercise);
      print('Response: $response');
      setState(() {
        _exercises = _fetchExercises();
      });
    } catch (e) {
      print('Error updating exercise: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.day),
      ),
      body: Center(
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _exercises,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Text('No exercises found');
            }

            final exercises = snapshot.data!;
            return SingleChildScrollView(
              child: DataTable(
                columnSpacing: 10.0,
                columns: const [
                  DataColumn(label: Text('Exercise')),
                  DataColumn(label: Text('Sets')),
                  DataColumn(label: Text('Reps')),
                  DataColumn(label: Text('Actions')),
                ],
                rows: exercises.map((exercise) {
                  final TextEditingController setsController = TextEditingController(text: exercise['sets'].toString());
                  final TextEditingController repsController = TextEditingController(text: exercise['reps'].toString());

                  return DataRow(cells: [
                    DataCell(Text(exercise['exercise_name'])),
                    DataCell(
                      SizedBox(
                        width: 50,
                        child: TextFormField(
                          controller: setsController,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          onFieldSubmitted: (value) {
                            _updateExercise(exercise['exercise_name'], int.parse(repsController.text), int.parse(setsController.text));
                          },
                        ),
                      ),
                    ),
                    DataCell(
                      SizedBox(
                        width: 50,
                        child: TextFormField(
                          controller: repsController,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          onFieldSubmitted: (value) {
                            _updateExercise(exercise['exercise_name'], int.parse(repsController.text), int.parse(setsController.text));
                          },
                        ),
                      ),
                    ),
                    DataCell(
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => _deleteExercise(exercise['exercise_name']),
                      ),
                    ),
                  ]);
                }).toList(),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddExercisePage(day: widget.day, day_id: widget.day_id),
            ),
          );

          if (result != null) {
            setState(() {
              _exercises = _fetchExercises();
            });
          }
        },
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add),
      ),
    );
  }
}
