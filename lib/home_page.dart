import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> logs = [];
  Map<String, List<Map<String, dynamic>>> exerciseLogs = {};
  String? selectedExerciseName;
  DateTime? earliestDate;

  @override
  void initState() {
    super.initState();
    _fetchExerciseLogs();
  }

  Future<void> _fetchExerciseLogs() async {
    final response = await Supabase.instance.client
        .from('Exercise_Logs')
        .select()
        .eq('user_id', Supabase.instance.client.auth.currentUser!.id)
        .order('date', ascending: true);
    print('Response: $response');
    if (response is List) {
      setState(() {
        logs = response;
        _groupByExercise();
      });
    }
  }

  void _groupByExercise() {
    Map<String, List<Map<String, dynamic>>> grouped = {};
    for (var log in logs) {
      String exerciseName = log['exercise_name'];
      if (!grouped.containsKey(exerciseName)) {
        grouped[exerciseName] = [];
      }
      grouped[exerciseName]!.add(log);
    }
    setState(() {  
      exerciseLogs = grouped;
      if (exerciseLogs.isNotEmpty) {
        selectedExerciseName = exerciseLogs.keys.first;
        earliestDate = DateTime.parse(logs.first['date']);
      }
    });
  }

  List<FlSpot> _generateData() {
    if (selectedExerciseName == null || !exerciseLogs.containsKey(selectedExerciseName)) {
      return [];
    }

    List<FlSpot> dataPoints = [];
    var logsForExercise = exerciseLogs[selectedExerciseName]!;
    for (var log in logsForExercise) {
      DateTime date = DateTime.parse(log['date']);
      double dayNumber = date.difference(earliestDate!).inDays.toDouble() + 1;
      double weight = log['weight'] * (1 + (log['reps'] / 30));
      dataPoints.add(FlSpot(dayNumber, weight));
    }
    return dataPoints;
  }

  double _getMaxWeight() {
    if (selectedExerciseName == null || !exerciseLogs.containsKey(selectedExerciseName)) {
      return 0;
    }

    var logsForExercise = exerciseLogs[selectedExerciseName]!;
    double maxWeight = logsForExercise
        .map((log) => log['weight'] * (1 + (log['reps'] / 30)))
        .reduce((a, b) => a > b ? a : b);
    return maxWeight;
  }

  String _formatDate(double value) {
    DateTime date = earliestDate!.add(Duration(days: value.toInt() - 1));
    return DateFormat('MM/dd').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue[800]!, Colors.blue[400]!],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Section
              Container(
                padding: EdgeInsets.only(top: 50, left: 20, right: 20, bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.blue[800],
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome Back,',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Track your strength progress below!',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 20),
                    Container(
                      padding: EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.search, color: Colors.grey),
                          SizedBox(width: 10),
                          Text(
                            'Search for workouts...',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Dropdown for exercise selection
              Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Select Exercise',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 10),
                    DropdownButton<String>(
                      value: selectedExerciseName,
                      dropdownColor: Colors.white,
                      onChanged: (newName) {
                        setState(() {
                          selectedExerciseName = newName;
                        });
                      },
                      items: exerciseLogs.keys.map((exerciseName) {
                        return DropdownMenuItem<String>(
                          value: exerciseName,
                          child: Text(exerciseName),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),

              // Strength Progress Chart
              Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Strength Progress',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 10),
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(15),
                        child: SizedBox(
                          height: 250,
                          child: LineChart(
                            LineChartData(
                              minY: 0,
                              maxY: _getMaxWeight() + 10, // Add a buffer to the max weight for better spacing
                              titlesData: FlTitlesData(
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    getTitlesWidget: (value, meta) {
                                      return Text(
                                        _formatDate(value),
                                        style: TextStyle(fontSize: 10),
                                      );
                                    },
                                    interval: 8, // Adjusts interval for readability
                                  ),
                                ),
                                leftTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    getTitlesWidget: (value, meta) {
                                      return Text(
                                        value.toStringAsFixed(0), // Show whole numbers only
                                        style: TextStyle(fontSize: 12),
                                      );
                                    },
                                    reservedSize: 40, // Prevents label stacking
                                    interval: (_getMaxWeight() / 4).clamp(10, 50), // Dynamic interval
                                  ),
                                ),
                                topTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: false, // Hide duplicate top labels
                                  ),
                                ),
                                rightTitles: AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                              ),
                              borderData: FlBorderData(show: false),
                              lineBarsData: [
                                LineChartBarData(
                                  spots: _generateData(),
                                  isCurved: true,
                                  barWidth: 4,
                                  belowBarData: BarAreaData(show: false),
                                  color: Colors.blue,
                                ),
                              ],
                            )
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Fitness Tips Section
              Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Fitness Tips',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 10),
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(15),
                        child: Column(
                          children: [
                            ListTile(
                              leading: Icon(Icons.favorite, color: Colors.red),
                              title: Text(
                                'Stay Hydrated',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(
                                'Drink plenty of water throughout the day.',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ),
                            Divider(),
                            ListTile(
                              leading: Icon(Icons.directions_run, color: Colors.blue),
                              title: Text(
                                'Warm Up Properly',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(
                                'Always warm up before starting your workout.',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
