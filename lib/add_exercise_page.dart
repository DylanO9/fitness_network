import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'exercise_list_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/widgets.dart';

class AddExercisePage extends StatefulWidget {
  final String day;
  final int day_id;

  const AddExercisePage({super.key, required this.day, required this.day_id});

  @override
  _AddExercisePageState createState() => _AddExercisePageState();
}

class _AddExercisePageState extends State<AddExercisePage> with RouteAware {
  List<Map<String, dynamic>> _selectedExercises = [];
  final List<String> bodyParts = [
    'chest',
    'back',
    'legs',
    'arms',
    'shoulders',
    'abs',
    'cardio'
  ];
  int _currentOrder = 0;

  @override
  void initState() {
    super.initState();
    _fetchLargestOrder();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Subscribe to the route observer
    RouteObserver<ModalRoute<void>>().subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void dispose() {
    // Unsubscribe from the route observer
    RouteObserver<ModalRoute<void>>().unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() {
    // Called when the current route has been popped off, and the current route shows up
    _fetchLargestOrder();
  }

  Future<void> _fetchLargestOrder() async {
    try {
      final response = await Supabase.instance.client
          .from('Split_Mapping')
          .select('order')
          .eq('user_id', Supabase.instance.client.auth.currentUser!.id)
          .eq('split_id', widget.day_id)
          .order('order', ascending: false)
          .limit(1)
          .single();
      if (response != null) {
        setState(() {
          _currentOrder = response['order'] ?? 0;
        });
      }
    } catch (e) {
      print('Error fetching largest order: $e');
    }
  }

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
              initialOrder: _currentOrder,
            ),
          ),
        );

        if (result != null) {
          setState(() {
            _selectedExercises.addAll(result);
            _currentOrder = result.last['order'];
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
          title: Text(
            "Add Exercise for ${widget.day}",
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
          child: GridView.builder(
            padding: EdgeInsets.all(16),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.5,
            ),
            itemCount: bodyParts.length,
            itemBuilder: (context, index) {
              return Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(15),
                  onTap: () => fetchExercises(bodyParts[index]),
                  child: Center(
                    child: Text(
                      bodyParts[index].toUpperCase(),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[800],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}