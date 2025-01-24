import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'exercise_list_page.dart';

class AddExercisePage extends StatefulWidget {
  final String day;
  final int day_id;

  const AddExercisePage({super.key, required this.day, required this.day_id});

  @override
  _AddExercisePageState createState() => _AddExercisePageState();
}

class _AddExercisePageState extends State<AddExercisePage> {
  List<String> _selectedExercises = [];
  final List<String> bodyParts = [
    'chest',
    'back',
    'legs',
    'arms',
    'shoulders',
    'abs'
  ];

  void fetchExercises(String bodyPart) async {
    final url = Uri.parse('https://exercisedb.p.rapidapi.com/exercises/bodyPart/$bodyPart?limit=10&offset=0');

    try {
      final response = await http.get(
        url,
        headers: {
          'X-Rapidapi-Key': '834b99fcaemsh4f1ff02156e1aecp141eb9jsn6bf831eb2667',
          'X-Rapidapi-Host': 'exercisedb.p.rapidapi.com',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final exercises = List<String>.from(data.map((exercise) => exercise['name']));

        // Navigate to the ExerciseListPage with fetched exercises
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ExerciseListPage(
              bodyPart: bodyPart,
              exercises: exercises,
              day_id: widget.day_id,
            ),
          ),
        );

        if (result != null) {
          setState(() {
            _selectedExercises.addAll(result);
          });
        }
      } else {
        print('Failed to fetch exercises. Status code: ${response.statusCode}');
      }
    } catch (error) {
      print('Error occurred: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, _selectedExercises);
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text("Add Exercise for ${widget.day}"),
        ),
        body: ListView.builder(
          itemCount: bodyParts.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 0.0),
              child: SizedBox(
                width: double.infinity,
                height: 150,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero,
                    ),
                  ),
                  onPressed: () => fetchExercises(bodyParts[index]),
                  child: Text(
                    bodyParts[index],
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}