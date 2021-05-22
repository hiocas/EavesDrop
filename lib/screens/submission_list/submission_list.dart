import 'package:flutter/material.dart';
import 'dart:async';
import 'package:draw/draw.dart';
import 'package:flutter/rendering.dart';
import 'local_widgets/submission_list_item.dart';
import 'package:gwa_app/states/global_state.dart';
import 'package:provider/provider.dart';

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
  String lastSeenSubmission = 'None';

  var scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    scrollController.addListener(() {
      if (scrollController.offset ==
          scrollController.position.maxScrollExtent) {
        /*FIXME: This is what's responsible for loading more submissions when
           the user reaches the end of the list but it's scuffed... */
      }
    });
    Provider.of<GlobalState>(context, listen: false).loadSearch('', TimeFilter.all);
  }

  @override
  void dispose() {
    super.dispose();
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
        child: Consumer<GlobalState>(
          builder: (context, state, child) {
            return StreamBuilder(
              stream: state.searchResultsStream,
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
                                // if (index >= list.length) {
                                //   return null;
                                // }
                                return SubmissionListItem(
                                  submission: state.searchResults[index],
                                  reddit: state.reddit,
                                );
                              },
                              childCount: state.searchResults.length,
                            ),
                          ),
                        )
                      ],
                    ),
                  );
                }
              },
            );
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
