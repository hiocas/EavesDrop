import 'package:flutter/material.dart';
import 'dart:async';
import 'package:draw/draw.dart';
import 'package:flutter/rendering.dart';
import '../../widgets/gwa_list_item.dart';
import 'package:gwa_app/states/global_state.dart';
import 'package:provider/provider.dart';
import 'local_widgets/submission_list_appbar.dart';

/*FIXME: This implements GlobalState but it seems to be slower than the old
   implementation. */

/*TODO: Implement lazy loading and a "show more" in search so that the user can
   search for more than 1000 (I think that's the limit) submissions. */

/*TODO: I think there are too many separate calls for Provider.of... I dunno
    how this impacts performance but you should look into it. */
class SubmissionList extends StatefulWidget {
  final String initialQuery;
  final TimeFilter initialTimeFilter;
  final Sort initialSort;

  const SubmissionList({
    Key key,
    this.initialQuery = '',
    this.initialTimeFilter = TimeFilter.all,
    this.initialSort = Sort.relevance,
  }) : super(key: key);

  @override
  SubmissionListState createState() => SubmissionListState();
}

/*FIXME: I managed to make some sort of paging but it needs to be revised and
    better shown to the user.
    When the user scrolls to the bottom load() gets called to add more
    submissions to the submission list.
    There's no DoOnce mechanism there so it can get called more than once. */

class SubmissionListState extends State<SubmissionList> {
  ScrollController scrollController = ScrollController();
  GlobalState globalState;
  Sort searchSort = Sort.relevance;
  TimeFilter searchTimeFilter = TimeFilter.all;
  String submittedSearchQuery = '';
  String currentSearchQuery = '';

  @override
  void initState() {
    super.initState();
    scrollController.addListener(() {
      if (scrollController.offset ==
          scrollController.position.maxScrollExtent) {
        /*FIXME: This is what's responsible for loading more submissions when
           the user reaches the end of the list but it's scuffed... */
        // Provider.of<GlobalState>(context, listen: false)
        //     .updateLastSeenSubmission();
      }
    });

    if (widget.initialQuery.isEmpty || widget.initialQuery == null) {
      Provider.of<GlobalState>(context, listen: false).loadNewest();
    } else {
      Provider.of<GlobalState>(context, listen: false).loadSearch(
          widget.initialQuery, widget.initialSort, widget.initialTimeFilter);
    }
  }

  @override
  void dispose() {
    super.dispose();
    scrollController.dispose();
    scrollController = null;
    if (globalState != null) {
      globalState.dispose();
      globalState = null;
    }
  }

  _updateSearch() {
    if (this.submittedSearchQuery.isNotEmpty) {
      Provider.of<GlobalState>(context, listen: false).loadSearch(
          this.submittedSearchQuery, this.searchSort, this.searchTimeFilter);
      setState(() {});
    } else {
      switch (this.searchSort) {
        case Sort.relevance:
          // TODO: Handle this case.
          break;
        case Sort.hot:
          Provider.of<GlobalState>(context, listen: false)
              .loadHot();
          setState(() {});
          break;
        case Sort.newest:
          Provider.of<GlobalState>(context, listen: false)
              .loadNewest();
          setState(() {});
          break;
        case Sort.comments:
          // TODO: Handle this case.
          break;
        case Sort.top:
          print('hey');
          Provider.of<GlobalState>(context, listen: false)
              .loadTop(this.searchTimeFilter);
          setState(() {});
          break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SubmissionListAppBar(
        onSelectedFilter: (TimeFilter result) {
          this.searchTimeFilter = result;
          if (this.submittedSearchQuery == this.currentSearchQuery) {
            _updateSearch();
          }
        },
        onSelectedItem: (Sort result) {
          this.searchSort = result;
          //This way the search only gets updated after every submission.
          if (this.submittedSearchQuery == this.currentSearchQuery)
            _updateSearch();
        },
        onSubmitted: (query) {
          this.submittedSearchQuery = query;
          _updateSearch();
        },
        /*FIXME: There's probably a more efficient way to check if the user
            changed their query, maybe using onEditingComplete. Fix this. */
        onChanged: (query) {
          this.currentSearchQuery = query;
        },
      ),
      backgroundColor: Theme.of(context).backgroundColor,
      body: Container(
        child: StreamBuilder(
          stream: Provider.of<GlobalState>(context).searchResultsStream,
          builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
            if (Provider.of<GlobalState>(context).searchEmpty) {
              return Center(child: Text('No Submissions Found.'));
            } else if (!snapshot.hasData ||
                (Provider.of<GlobalState>(context).searchResults.isEmpty)) {
              return Center(child: CircularProgressIndicator());
            } else {
              this.globalState = Provider.of<GlobalState>(context);
              print(globalState.searchResults.length);
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
                            return GwaListItem(
                              submission: globalState.searchResults[index],
                            );
                          },
                          childCount: globalState.searchResults.length,
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
    );
  }
}
