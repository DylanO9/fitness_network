import 'package:flutter/material.dart';

class ExerciseListPage extends StatefulWidget {
  final String bodyPart;
  final List<String> exercises;

  const ExerciseListPage({
    super.key,
    required this.bodyPart,
    required this.exercises,
  });

  @override
  _ExerciseListPageState createState() => _ExerciseListPageState();
}

class _ExerciseListPageState extends State<ExerciseListPage> {
  late List<bool> _checked;
  late List<String> _selectedExercises;

  @override
  void initState() {
    super.initState();
    _checked = List<bool>.filled(widget.exercises.length, false);
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
    );
  }
}
