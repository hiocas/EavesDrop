import 'package:draw/draw.dart';
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
  @override
  void dispose() {
    // TODO: Figure out the correct place for this, and if it's even needed.
    Provider.of<GlobalState>(context, listen: false).dispose();
    super.dispose();
  }

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
            scrollbarTheme: ScrollbarThemeData(
              thumbColor: MaterialStateProperty.all(
                  Color.fromARGB(255, 119, 23, 45).withOpacity(0.3)),
            )),
        home: HomeScaffold(),
        routes: {
          ExtractArgumentsSubmissionList.routeName: (context) =>
              ExtractArgumentsSubmissionList(),
          '/home': (context) => HomeScaffold(
                initialIndex: 1,
              ),
          '/library': (context) => HomeScaffold(
                initialIndex: 2,
              )
        },
      ),
    );
  }
}

class HomeScaffold extends StatefulWidget {
  const HomeScaffold({
    Key key,
    this.initialIndex,
    this.initialSearchQuery,
    this.initialSort,
    this.initialTimeFilter,
  }) : super(key: key);

  final int initialIndex;
  final String initialSearchQuery;
  final Sort initialSort;
  final TimeFilter initialTimeFilter;

  @override
  _HomeScaffoldState createState() => _HomeScaffoldState();
}

class _HomeScaffoldState extends State<HomeScaffold> {
  int _currentPageIndex;
  List<Widget> _screens;

  @override
  void initState() {
    this._currentPageIndex = widget.initialIndex ?? 1;
    this._screens = [
      SubmissionList(
        initialQuery: widget.initialSearchQuery ?? '',
        initialSort: widget.initialSort,
        initialTimeFilter: widget.initialTimeFilter,
      ),
      Home(),
      Library(),
    ];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
    );
  }
}

class SubmissionListArguments {
  String initialSearchQuery;
  Sort initialSort;
  TimeFilter initialTimeFilter;

  SubmissionListArguments(
      this.initialSearchQuery, this.initialSort, this.initialTimeFilter);
}

class ExtractArgumentsSubmissionList extends StatelessWidget {
  static const routeName = '/submissionListExtracted';

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context).settings.arguments as SubmissionListArguments;

    return HomeScaffold(
      initialIndex: 0,
      initialSearchQuery: args.initialSearchQuery,
      initialSort: args.initialSort,
      initialTimeFilter: args.initialTimeFilter,
    );
  }
}
