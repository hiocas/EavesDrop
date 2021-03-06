import 'package:draw/draw.dart';
import 'package:eavesdrop/screens/audio_player/expandable_audio_player.dart';
import 'package:eavesdrop/states/gwa_player_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:eavesdrop/models/hive_boxes.dart';
import 'package:eavesdrop/models/placeholders_options.dart';
import 'package:eavesdrop/screens/flat_home/new_home.dart';
import 'package:eavesdrop/screens/library/library.dart';
import 'package:eavesdrop/screens/submission_list/submission_list.dart';
import 'package:eavesdrop/states/global_state.dart';
import 'package:eavesdrop/utils/gwa_functions.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'dart:core';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();

  HiveBoxes.initHive();

  GlobalState globalState = GlobalState();

  await globalState.initApp();

  GwaPlayerState playerState = GwaPlayerState();

  await playerState.init();

  final appSettings = await HiveBoxes.getAppSettings();
  if (appSettings == null) {
    GwaFunctions.setPlaceholders(PlaceholdersOptions.Gradients);
  } else {
    GwaFunctions.setPlaceholders(appSettings.placeholdersOptions);
  }

  runApp(MyApp(
    globalState: globalState,
    playerState: playerState,
  ));
}

class MyApp extends StatefulWidget {
  final GlobalState globalState;
  final GwaPlayerState playerState;

  const MyApp({
    Key key,
    this.globalState,
    this.playerState,
  }) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void dispose() {
    // TODO: Figure out the correct place for this, and if it's even needed.
    widget.globalState.dispose();
    widget.playerState.dispose();
    Hive.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<GlobalState>.value(value: widget.globalState),
        ChangeNotifierProvider<GwaPlayerState>.value(value: widget.playerState),
      ],
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          systemNavigationBarColor: const Color.fromARGB(255, 28, 18, 28),
        ),
        child: MaterialApp(
          title: 'GoneWildAudio App',
          themeMode: ThemeMode.dark,
          theme: ThemeData(
              primaryColor: const Color.fromARGB(255, 119, 23, 45),
              accentColor: const Color.fromARGB(255, 62, 26, 92),
              backgroundColor: Colors.grey[200],
              cardColor: const Color.fromARGB(255, 7, 13, 43),
              textTheme:
                  const TextTheme(bodyText2: TextStyle(color: Colors.black))),
          darkTheme: ThemeData(
              primaryColor: const Color.fromARGB(255, 119, 23, 45),
              accentColor: const Color.fromARGB(255, 62, 26, 92),
              backgroundColor: const Color.fromARGB(255, 28, 18, 28),
              cardColor: const Color.fromARGB(255, 7, 13, 43),
              errorColor: const Color.fromARGB(255, 110, 70, 110),
              scrollbarTheme: ScrollbarThemeData(
                thumbColor: MaterialStateProperty.all(
                    const Color.fromARGB(255, 119, 23, 45).withOpacity(0.7)),
              )),
          home: HomeScaffold(),
          routes: {
            ExtractArgumentsSubmissionList.routeName: (context) =>
                ExtractArgumentsSubmissionList(),
            RedirectToHome.routeName: (context) => RedirectToHome(),
            '/home': (context) => HomeScaffold(
                  initialIndex: 1,
                ),
            '/library': (context) => HomeScaffold(
                  initialIndex: 2,
                )
          },
        ),
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
      NewHome(),
      Library(),
    ];
    HiveBoxes.checkFirstTime(context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: ExpandingAudioPlayer(
        background: AnimatedSwitcher(
          duration: Duration(milliseconds: 400),
          transitionBuilder: (child, animation) {
            //TODO(Design): Make a better transition.
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
          child: _screens.elementAt(_currentPageIndex),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentPageIndex,
        backgroundColor: Theme.of(context).backgroundColor,
        selectedItemColor: Colors.grey[400],
        unselectedItemColor: Colors.grey[800],
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
            Provider.of<GlobalState>(context, listen: false).prepareNewSearch();
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
    // Prepare a new search.
    Provider.of<GlobalState>(context, listen: false).prepareNewSearch();
    return HomeScaffold(
      initialIndex: 0,
      initialSearchQuery: args.initialSearchQuery,
      initialSort: args.initialSort,
      initialTimeFilter: args.initialTimeFilter,
    );
  }
}

class RedirectToHome extends StatelessWidget {
  static const routeName = '/redirectToHome';

  @override
  Widget build(BuildContext context) {
    return HomeScaffold(
      initialIndex: 1,
    );
  }
}
