import 'package:flutter/material.dart';
import 'dart:async';
import 'package:draw/draw.dart';
import 'package:flutter/rendering.dart';
import 'local_widgets/submission_list_item.dart';
import 'package:gwa_app/models/gwa_submission_preview.dart';
import 'package:gwa_app/utils/util_functions.dart';

/*TODO: Implement lazy loading and a "show more" in search so that the user can
   search for more than 1000 (I think that's the limit) submissions. */
class SubmissionList extends StatefulWidget {
  @override
  SubmissionListState createState() => SubmissionListState();
}

/*FIXME: I managed to make some sort of paging but it needs to be revised and
    better shown to the user.
    When the user scrolls to the bottom load() gets called to add more
    submissions to the submission list.
    There's no DoOnce mechanism there so it can get called more than once. */

class SubmissionListState extends State<SubmissionList> {
  StreamController<UserContent> streamController;
  Stream<UserContent> stream;
  List<GwaSubmissionPreview> list = [];
  String lastSeenSubmission = 'None';
  Reddit reddit;

  var scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    scrollController.addListener(() {
      if (scrollController.offset ==
          scrollController.position.maxScrollExtent) {
        lastSeenSubmission = list.last.fullname;
        /*FIXME: This is what's responsible for loading more submissions when
           the user reaches the end of the list but it's scuffed... */
        // load(streamController);
      }
    });

    streamController = StreamController.broadcast();
    streamController.stream.listen(
      (submission) => setState(
        () {
          GwaSubmissionPreview gwaSubmission =
              new GwaSubmissionPreview(submission);
          list.add(gwaSubmission);
        },
      ),
    );

    load(streamController);
  }

  load(StreamController sc) async {

    //TODO: Make a class to hold this data instead of handling it like this.
    Map<String, dynamic> data = await parseJsonFromAssets('lib/assets/reddit.json');

    reddit = await Reddit.createScriptInstance(
      clientId: data["CLIENT_ID"],
      clientSecret: data["SECRET"],
      userAgent: 'MyAPI/0.0.1',
      username: data["username"],
      password: data["password"],
    );

    //TODO: Make a search feature that loads submissions based on search...
    var subreddit = reddit.subreddit('gonewildaudio');
    stream = subreddit
        // .search('author:skitty-gwa', sort: Sort.top, timeFilter: TimeFilter.all);
        .top(
            timeFilter: TimeFilter.all,
            limit: 200,
            params: {'after': lastSeenSubmission});
    // .search('author:linguisticpoet', sort: Sort.newest, timeFilter: TimeFilter.all);
    streamController.addStream(stream);
  }

  @override
  void dispose() {
    super.dispose();
    streamController?.close();
    streamController = null;
    scrollController.dispose();
    scrollController = null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Search Results"),
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(15.0),
                bottomRight: Radius.circular(15.0)),
            gradient: LinearGradient(colors: [
              Theme.of(context).primaryColor,
              Theme.of(context).cardColor,
            ], begin: Alignment.bottomLeft, end: Alignment.bottomRight),
          ),
        ),
        leading: IconButton(
            icon: Icon(Icons.menu),
            onPressed: () {
              print('The app bar leading button has been pressed.');
            }),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () => print('User requested to search'),
          )
        ],
      ),
      backgroundColor: Theme.of(context).backgroundColor,
      body: Container(
        child: StreamBuilder(
          stream: streamController.stream,
          builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
            if (!snapshot.hasData) {
              return Center(child: CircularProgressIndicator());
            } else {
              return RefreshIndicator(
                //TODO: Implement pull to refresh.
                onRefresh: () {
                  print('User requested a refresh');
                  return Future.value();
                },
                child: CustomScrollView(
                  physics: const BouncingScrollPhysics(
                      parent: AlwaysScrollableScrollPhysics()),
                  controller: scrollController,
                  slivers: [
                    SliverPadding(
                      padding: const EdgeInsets.all(8.0),
                      sliver: SliverGrid(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          mainAxisSpacing: 5,
                          crossAxisSpacing: 5,
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (BuildContext context, int index) {
                            return SubmissionListItem(
                              submission: list[index],
                              reddit: reddit,
                            );
                          },
                          childCount: list.length,
                        ),
                      ),
                    )
                  ],
                ),
              );
            }
          },
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Theme.of(context).backgroundColor,
        selectedItemColor: Theme.of(context).primaryColor,
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
      ),
    );
  }
}
