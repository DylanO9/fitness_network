import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ExerciseListPage extends StatefulWidget {
  final String bodyPart;
  final List<String> exercises;
  final int day_id;
  final int initialOrder;

  const ExerciseListPage({
    super.key,
    required this.bodyPart,
    required this.exercises,
    required this.day_id,
    required this.initialOrder,
  });

  @override
  ExerciseListPageState createState() => ExerciseListPageState();
}

class ExerciseListPageState extends State<ExerciseListPage> {
  late List<bool> _checked;
  late List<Map<String, dynamic>> _selectedExercises;
  late int _currentOrder;

  @override
  void initState() {
    super.initState();
    _checked = List<bool>.filled(widget.exercises.length, false);
    _selectedExercises = [];
    _currentOrder = widget.initialOrder;
  }

  void _saveSelectedExercises() async {
    try {
      for (String exercise in _selectedExercises.map((e) => e['exercise_name'])) {
        _currentOrder++;
        final response = await Supabase.instance.client
            .from('Split_Mapping')
            .upsert({
              'user_id': Supabase.instance.client.auth.currentUser!.id,
              'split_id': widget.day_id,
              'exercise_name': exercise,
              'order': _currentOrder,
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
        title: Text(
          "Exercises for ${widget.bodyPart}",
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
        child: widget.exercises.isEmpty
            ? Center(
                child: Text(
                  'No exercises available',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              )
            : ListView.builder(
                padding: EdgeInsets.all(16),
                itemCount: widget.exercises.length,
                itemBuilder: (context, index) {
                  return Card(
                    elevation: 4,
                    margin: EdgeInsets.only(bottom: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: ListTile(
                      title: Text(
                        widget.exercises[index],
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[800],
                        ),
                      ),
                      trailing: Checkbox(
                        value: _checked[index],
                        onChanged: (bool? value) {
                          setState(() {
                            _checked[index] = value!;
                            if (_checked[index]) {
                              _selectedExercises.add({
                                'exercise_name': widget.exercises[index],
                                'order': _currentOrder + 1,
                              });
                            } else {
                              _selectedExercises.removeWhere((e) => e['exercise_name'] == widget.exercises[index]);
                            }
                          });
                        },
                        activeColor: Colors.blue[800],
                      ),
                    ),
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _saveSelectedExercises,
        backgroundColor: Colors.white,
        child: Icon(
          Icons.save,
          color: Colors.blue[800],
        ),
        tooltip: 'Save selected exercises',
      ),
    );
  }
}