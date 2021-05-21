import 'package:flutter/material.dart';
import 'screens/submission_list/submission_list.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      themeMode: ThemeMode.dark,
      theme: ThemeData(
        primaryColor: Color.fromARGB(255, 119, 23, 45),
        accentColor: Color.fromARGB(255, 62, 26, 92),
        backgroundColor: Colors.grey[200],
        cardColor: Color.fromARGB(255, 7, 13, 43),
        textTheme: TextTheme(bodyText2: TextStyle(color: Colors.black))
      ),
      darkTheme: ThemeData(
        primaryColor: Color.fromARGB(255, 119, 23, 45),
        accentColor: Color.fromARGB(255, 62, 26, 92),
        backgroundColor: Color.fromARGB(255, 28, 18, 28),
        cardColor: Color.fromARGB(255, 7, 13, 43),
      ),
      home: SubmissionList(),
    );
  }
}
