import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gwa_app/models/hive_boxes.dart';
import 'package:gwa_app/models/library_gwa_submission.dart';
import 'package:gwa_app/screens/gwa_drawer/gwa_drawer.dart';
import 'package:gwa_app/widgets/gradient_appbar_flexible_space.dart';
import 'package:gwa_app/widgets/gwa_list_item.dart';
import 'package:gwa_app/widgets/gwa_scrollbar.dart';
import 'package:hive/hive.dart';

class Library extends StatefulWidget {
  const Library({Key key}) : super(key: key);

  @override
  _LibraryState createState() => _LibraryState();
}

class _LibraryState extends State<Library> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  bool _smallSubmissions;

  /// Returns a list of [Tab] widgets from [HiveBoxes.listTags].
  List<Widget> _makeListTabs() {
    List<Widget> tabs = [Tab(text: 'All')];
    for (String list in HiveBoxes.listTags) {
      tabs.add(Tab(
        text: list,
      ));
    }
    return tabs;
  }

  /// Returns a list of [TabBarView] children from [HiveBoxes.listTags].
  List<Widget> _makeListTabViews(
      List<LibraryGwaSubmission> librarySubmissions) {
    List<Widget> tabBarViews = [_makeListOf(librarySubmissions)];
    for (String list in HiveBoxes.listTags) {
      tabBarViews.add(_makeListOf(_sortOnListTag(list, librarySubmissions)));
    }
    return tabBarViews;
  }

  /// Filters a [LibraryGwaSubmission] list to another based on a list tag.
  List<LibraryGwaSubmission> _sortOnListTag(
      String listTag, List<LibraryGwaSubmission> librarySubmissions) {
    List<LibraryGwaSubmission> list = [];
    for (LibraryGwaSubmission submission in librarySubmissions) {
      for (String subList in submission.lists) {
        if (subList.contains(listTag)) list.add(submission);
      }
    }
    return list;
  }

  /// Makes the UI list based on a [LibraryGwaSubmission] list it receives.
  Widget _makeListOf(List<LibraryGwaSubmission> list) {
    return Container(
      child: GwaScrollbar(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics()),
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.all(8.0),
              sliver: SliverGrid(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: _smallSubmissions ? 3 : 2,
                  mainAxisSpacing: 5,
                  crossAxisSpacing: 5,
                ),
                delegate: SliverChildBuilderDelegate(
                  (BuildContext context, int index) {
                    return ListPreviewItem(
                      title: list[index].title,
                      fullname: list[index].fullname,
                      thumbnailUrl: list[index].thumbnailUrl,
                      onReturn: () {
                        setState(() {});
                      },
                    );
                  },
                  childCount: list.length,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<List<LibraryGwaSubmission>> _initLibrary() async {
    final appSettings = await HiveBoxes.openAppSettingsBox();
    _smallSubmissions = appSettings.getAt(0).librarySmallSubmissions;
    return HiveBoxes.getLibraryGwaSubmissionList();
  }

  @override
  void dispose() {
    Hive.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    /*TODO: Find a more efficient way to update the list (I don't think we need
       this since we won't be in this page when adding submissions to the
       library unless I change it -> not true, this can be done if a link
       to another submission is in a submission's selftext and the user clicks
       it). */
    return WillPopScope(
      onWillPop: () async => false,
      child: FutureBuilder<List<LibraryGwaSubmission>>(
        future: _initLibrary(),
        builder: (context, futureBox) {
          if (futureBox.hasData) {
            return DefaultTabController(
              initialIndex: 0,
              length: HiveBoxes.listTags.length + 1,
              child: Scaffold(
                key: _scaffoldKey,
                onDrawerChanged: (open) {
                  // Rebuild when closing the GwaDrawer
                  if (!open && GwaDrawerManager.updateOnReturn) {
                    GwaDrawerManager.updateOnReturn = false;
                    setState(() {});
                  }
                },
                appBar: AppBar(
                  title: Text('Library'),
                  backgroundColor: Colors.transparent,
                  elevation: 15.0,
                  backwardsCompatibility: false,
                  systemOverlayStyle: SystemUiOverlayStyle.light,
                  flexibleSpace: GradientAppBarFlexibleSpace(),
                  leading: IconButton(
                    icon: Icon(Icons.menu),
                    onPressed: () {
                      _scaffoldKey.currentState.openDrawer();
                    },
                  ),
                  actions: [
                    // Submission Cross Axis Count
                    IconButton(
                        icon: Icon(_smallSubmissions
                            ? Icons.grid_view_outlined
                            : Icons.grid_on_outlined),
                        tooltip: _smallSubmissions
                            ? 'Display less posts'
                            : 'Display more posts',
                        onPressed: () {
                          HiveBoxes.editAppSettings(
                              librarySmallSubmissions: !_smallSubmissions);
                          // Rebuild when updating the submissions size
                          setState(() {});
                        }),
                    // Clear Library
                    IconButton(
                      icon: Icon(Icons.close),
                      tooltip: 'Clear your library',
                      onPressed: () {
                        showDialog<String>(
                          context: context,
                          builder: (BuildContext context) => AlertDialog(
                            backgroundColor: Theme.of(context).backgroundColor,
                            title: const Text(
                              'Clear Library',
                              style: TextStyle(color: Colors.white),
                            ),
                            content: const Text(
                              'Are you sure you want to clear '
                              'your library? This action cannot be '
                              'reverted.',
                              style: TextStyle(color: Colors.white),
                            ),
                            actions: <Widget>[
                              TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, 'cancel'),
                                  child: const Text('Cancel')),
                              TextButton(
                                  onPressed: () {
                                    HiveBoxes.clearLibrary();
                                    Navigator.pop(context, 'clear');
                                  },
                                  child: const Text('Clear my Library'))
                            ],
                          ),
                        ).then((value) {
                          // Rebuild when clearing the library
                          if (value == 'clear') {
                            setState(() {
                              /*TODO: Need to make these methods as widgets or
                                 else setState() doesn't update the state (we
                                 want all widgets to be created in our build
                                 method. */
                              _initLibrary();
                              _makeListTabs();
                            });
                          }
                        });
                      },
                    )
                  ],
                  bottom: TabBar(
                    tabs: _makeListTabs(),
                    indicatorColor: Theme.of(context).accentColor,
                    indicatorSize: TabBarIndicatorSize.label,
                    isScrollable: HiveBoxes.listTags.length > 4,
                  ),
                ),
                drawer: GwaDrawer(),
                backgroundColor: Theme.of(context).backgroundColor,
                body: TabBarView(
                  children: _makeListTabViews(futureBox.data),
                ),
              ),
            );
          }
          /* FIXME: This is can be seen for a very quick duration and is very
              jarring. */
          return Scaffold(
            backgroundColor: Theme.of(context).backgroundColor,
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        },
      ),
    );
  }
}
