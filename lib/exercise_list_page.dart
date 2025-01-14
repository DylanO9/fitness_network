import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ExerciseListPage extends StatefulWidget {
  final String bodyPart;
  final List<String> exercises;
  final int day_id;

  const ExerciseListPage({
    super.key,
    required this.bodyPart,
    required this.exercises,
    required this.day_id,
  });

  @override
  ExerciseListPageState createState() => ExerciseListPageState();
}

class ExerciseListPageState extends State<ExerciseListPage> {
  late List<bool> _checked;
  late List<String> _selectedExercises;

  @override
  void initState() {
    super.initState();
    _checked = List<bool>.filled(widget.exercises.length, false);
    _selectedExercises = [];
  }

  void _saveSelectedExercises() async {
    try {
      for (String exercise in _selectedExercises) {
        final response = await Supabase.instance.client
            .from('Split_Mapping')
            .upsert({
              'user_id': Supabase.instance.client.auth.currentUser!.id,
              'split_id': widget.day_id,
              'exercise_name': exercise,
            })
            .select();
        print('Response: $response');
      }
    } catch (e) {
      print('Error saving exercises: $e');
    }
    Navigator.pop(context, _selectedExercises);
    print('Selected exercises: $_selectedExercises');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Exercises for ${widget.bodyPart}"),
      ),
      body: widget.exercises.isEmpty
          ? Text('No exercises available')
          : ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 0.0, vertical: 0.0),
              itemCount: widget.exercises.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(
                    widget.exercises[index],
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  trailing: Checkbox(
                    value: _checked[index],
                    onChanged: (bool? value) {
                      setState(() {
                        _checked[index] = value!;
                        if (_checked[index]) {
                          _selectedExercises.add(widget.exercises[index]);
                        } else {
                          _selectedExercises.remove(widget.exercises[index]);
                        }
                      });
                    },
                    activeColor: Colors.blue,
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _saveSelectedExercises,
        child: Icon(Icons.save),
        tooltip: 'Save selected exercises',
      ),
    );
  }
}
