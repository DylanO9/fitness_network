import 'package:flutter/material.dart';
import 'login_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://fzlxkmlxjdtcebqsqctw.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZ6bHhrbWx4amR0Y2VicXNxY3R3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzY1NTI0OTIsImV4cCI6MjA1MjEyODQ5Mn0.iZSMzCAtYyalXo1pGSkHTMISW4xjTZ0lBsLCMtXO1pg',
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fitness Network',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LoginPage(),
    );
  }
}
