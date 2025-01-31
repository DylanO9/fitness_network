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

  void _deleteExercise(String exercise) async {
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

  void _updateExercise(String exercise, int reps, int sets) async {
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
        title: Text(
          widget.day,
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue[800],
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue[800]!, Colors.blue[400]!],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: FutureBuilder<List<Map<String, dynamic>>>(
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
                final TextEditingController setsController = TextEditingController(text: exercise['sets'].toString());
                final TextEditingController repsController = TextEditingController(text: exercise['reps'].toString());

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
                        SizedBox(height: 10),

                        // Sets and Reps Input Fields
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: setsController,
                                decoration: InputDecoration(
                                  labelText: 'Sets',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                keyboardType: TextInputType.number,
                                onFieldSubmitted: (value) {
                                  _updateExercise(
                                    exercise['exercise_name'],
                                    int.parse(repsController.text),
                                    int.parse(setsController.text),
                                  );
                                },
                              ),
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: TextFormField(
                                controller: repsController,
                                decoration: InputDecoration(
                                  labelText: 'Reps',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                keyboardType: TextInputType.number,
                                onFieldSubmitted: (value) {
                                  _updateExercise(
                                    exercise['exercise_name'],
                                    int.parse(repsController.text),
                                    int.parse(setsController.text),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10),

                        // Delete Button
                        Align(
                          alignment: Alignment.centerRight,
                          child: IconButton(
                            icon: Icon(Icons.delete, color: Colors.red[400]),
                            onPressed: () => _deleteExercise(exercise['exercise_name']),
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
        backgroundColor: Colors.white,
        child: Icon(
          Icons.add,
          color: Colors.blue[800],
        ),
      ),
    );
  }
}