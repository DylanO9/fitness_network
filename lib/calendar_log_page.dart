import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CalendarLogPage extends StatelessWidget {
  final DateTime date;
  final int? splitDayId;

  const CalendarLogPage({Key? key, required this.date, this.splitDayId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Calendar Log for ${date.toLocal().toString().split(' ')[0]}'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchCalendarLogs(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No logs found for this date.'));
          }

          final logs = snapshot.data!;
          return ListView.builder(
            itemCount: logs.length,
            itemBuilder: (context, index) {
              final log = logs[index];
              return ListTile(
                title: Text('Split Day ID: ${log['split_id']}'),
                subtitle: Text('Date: ${log['date']}'),
              );
            },
          );
        },
      ),
    );
  }

  Future<List<Map<String, dynamic>>> _fetchCalendarLogs() async {
    try {
      final response = await Supabase.instance.client
          .from('Calendar_Logs')
          .select()
          .eq('user_id', Supabase.instance.client.auth.currentUser!.id)
          .eq('date', date.toIso8601String());

      return response as List<Map<String, dynamic>>;
    } catch (e) {
      print('Error fetching calendar logs: $e');
      return [];
    }
  }
}