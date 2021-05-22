import 'package:flutter/material.dart';
import 'package:gwa_app/states/global_state.dart';
import 'package:provider/provider.dart';
import 'screens/submission_list/submission_list.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  GlobalState globalState = GlobalState();
  await globalState.initApp();
  runApp(MyApp(
    globalState: globalState,
  ));
}

class MyApp extends StatelessWidget {
  final GlobalState globalState;

  const MyApp({Key key, this.globalState}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider<GlobalState>.value(value: globalState)],
      child: MaterialApp(
        themeMode: ThemeMode.dark,
        theme: ThemeData(
            primaryColor: Color.fromARGB(255, 119, 23, 45),
            accentColor: Color.fromARGB(255, 62, 26, 92),
            backgroundColor: Colors.grey[200],
            cardColor: Color.fromARGB(255, 7, 13, 43),
            textTheme: TextTheme(bodyText2: TextStyle(color: Colors.black))),
        darkTheme: ThemeData(
          primaryColor: Color.fromARGB(255, 119, 23, 45),
          accentColor: Color.fromARGB(255, 62, 26, 92),
          backgroundColor: Color.fromARGB(255, 28, 18, 28),
          cardColor: Color.fromARGB(255, 7, 13, 43),
        ),
        home: SubmissionList(),
      ),
    );
  }
}
