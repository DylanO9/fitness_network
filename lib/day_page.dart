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
  late Future<List<String>> _exercises;

  @override
  void initState() {
    super.initState();
    _exercises = _fetchExercises();
  }

  Future<List<String>> _fetchExercises() async {
    try {
      final response = await Supabase.instance.client
          .from('Split_Mapping')
          .select()
          .eq('user_id', Supabase.instance.client.auth.currentUser!.id)
          .eq('split_id', widget.day_id);
      print('Response: $response');
      return response.map((item) => item['exercise_name'] as String).toList();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.day),
      ),
      body: Center(
        child: FutureBuilder<List<String>>(
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
            return ListView.builder(
              itemCount: exercises.length,
              itemBuilder: (context, index) {
                final exercise = exercises[index];
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey, width: 1),
                    ),
                    child: ListTile(
                      title: Row(
                        children: [
                          Text(exercise),
                          Spacer(),
                          IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () => _deleteExercise(exercise),
                          ),
                        ],
                      ),
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
        backgroundColor: Colors.blue,
        child: Icon(Icons.add),
      ),
    );
  }
}
