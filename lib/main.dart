import 'package:flutter/material.dart';
import 'package:gwa_app/screens/home/home.dart';
import 'package:gwa_app/screens/library/library.dart';
import 'package:gwa_app/screens/submission_list/submission_list.dart';
import 'package:gwa_app/states/global_state.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'models/library_gwa_submission.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();

  Hive.registerAdapter(LibraryGwaSubmissionAdapter());

  GlobalState globalState = GlobalState();
  await globalState.initApp();

  runApp(MyApp(
    globalState: globalState,
  ));
}

class MyApp extends StatefulWidget {
  final GlobalState globalState;

  const MyApp({Key key, this.globalState}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int _currentPageIndex = 1;
  List<Widget> _screens = [
    SubmissionList(),
    Home(),
    Library(),
  ];

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<GlobalState>.value(value: widget.globalState)
      ],
      child: MaterialApp(
        title: 'GoneWildAudio App',
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
        home: Scaffold(
          body: AnimatedSwitcher(
            duration: Duration(milliseconds: 500),
            transitionBuilder: (child, animation) {
              //TODO(Design): Make a better transition.
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
            child: _screens.elementAt(_currentPageIndex),
          ),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _currentPageIndex,
            backgroundColor: Color.fromARGB(255, 28, 18, 28),
            selectedItemColor: Color.fromARGB(255, 119, 23, 45),
            unselectedItemColor: Colors.grey[700],
            elevation: 15.0,
            items: [
              BottomNavigationBarItem(
                icon: Icon(Icons.search),
                label: 'Search',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.book),
                label: 'Library',
              )
            ],
            onTap: (index) {
              setState(() {
                _currentPageIndex = index;
              });
            },
          ),
        ),
      ),
    );
  }
}

class InstantRoute<T> extends MaterialPageRoute<T> {
  InstantRoute({WidgetBuilder builder, RouteSettings settings})
      : super(builder: builder, settings: settings);

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    return child;
  }
}
