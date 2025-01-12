import 'package:flutter/material.dart';

class ExerciseListPage extends StatelessWidget {
  final String bodyPart;
  final List<String> exercises;

  const ExerciseListPage({
    super.key,
    required this.bodyPart,
    required this.exercises,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Exercises for $bodyPart"),
      ),
      body: exercises.isEmpty
          ? const Center(
              child: Text('No exercises available'),
            )
          : ListView.builder(
              itemCount: exercises.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(exercises[index]),
                );
              },
            ),
    );
  }
}
