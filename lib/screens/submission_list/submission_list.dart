import 'package:eavesdrop/screens/audio_player/expandable_audio_player.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:draw/draw.dart';
import 'package:flutter/rendering.dart';
import 'package:eavesdrop/screens/gwa_drawer/gwa_drawer.dart';
import 'package:eavesdrop/widgets/gwa_scrollbar.dart';
import '../../widgets/gwa_list_item.dart';
import 'package:eavesdrop/states/global_state.dart';
import 'package:provider/provider.dart';
import 'local_widgets/submission_list_appbar.dart';

/*FIXME: This implements GlobalState but it seems to be slower than the old
   implementation. */

/*TODO: I think there are too many separate calls for Provider.of... I don't
   know how this impacts performance but you should look into it. */
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

class SubmissionListState extends State<SubmissionList> {
  ScrollController scrollController = ScrollController();
  GlobalState globalState;
  Sort searchSort;
  TimeFilter searchTimeFilter;
  String submittedSearchQuery = '';
  String currentSearchQuery = '';

  @override
  void initState() {
    super.initState();
    scrollController.addListener(() {
      if (scrollController.offset ==
          scrollController.position.maxScrollExtent) {
        Provider.of<GlobalState>(context, listen: false)
            .updateLastSeenSubmission();
        _updateSearch(false);
      }
    });

    if (widget.initialQuery == null || widget.initialQuery.isEmpty) {
      searchSort = Sort.newest;
      Provider.of<GlobalState>(context, listen: false).prepareNewSearch();
      Provider.of<GlobalState>(context, listen: false).loadNewest();
    } else {
      submittedSearchQuery = widget.initialQuery;
      currentSearchQuery = widget.initialQuery;
      searchSort = widget.initialSort;
      searchTimeFilter = widget.initialTimeFilter;
      Provider.of<GlobalState>(context, listen: false).loadSearch(
          widget.initialQuery, widget.initialSort, widget.initialTimeFilter);
    }
  }

  @override
  void dispose() {
    super.dispose();
    scrollController.dispose();
    scrollController = null;
    /* TODO: This is giving me a lot of errors so I'm not sure if I should keep
        it here. For now I put it in main. Figure out if it's where it should
        be and if it's even needed. */
    // if (globalState != null) {
    //   globalState.dispose();
    //   globalState = null;
    // }
  }

  _updateSearch(bool shouldRenew) {
    if (this.submittedSearchQuery.isNotEmpty) {
      if (shouldRenew)
        Provider.of<GlobalState>(context, listen: false).prepareNewSearch();
      Provider.of<GlobalState>(context, listen: false).loadSearch(
          this.submittedSearchQuery, this.searchSort, this.searchTimeFilter);
      setState(() {});
    } else {
      switch (this.searchSort) {
        case Sort.relevance:
          if (submittedSearchQuery.isNotEmpty) {
            if (shouldRenew)
              Provider.of<GlobalState>(context, listen: false)
                  .prepareNewSearch();
            Provider.of<GlobalState>(context, listen: false).loadSearch(
                this.submittedSearchQuery,
                this.searchSort,
                this.searchTimeFilter);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content:
                  Text('To sort based on relevancy you must search something.'),
            ));
          }
          break;
        case Sort.hot:
          if (shouldRenew)
            Provider.of<GlobalState>(context, listen: false).prepareNewSearch();
          Provider.of<GlobalState>(context, listen: false).loadHot();
          setState(() {});
          break;
        case Sort.newest:
          if (shouldRenew)
            Provider.of<GlobalState>(context, listen: false).prepareNewSearch();
          Provider.of<GlobalState>(context, listen: false).loadNewest();
          setState(() {});
          break;
        case Sort.comments:
          if (shouldRenew)
            Provider.of<GlobalState>(context, listen: false).prepareNewSearch();
          Provider.of<GlobalState>(context, listen: false)
              .loadControversial(this.searchTimeFilter);
          setState(() {});
          break;
        case Sort.top:
          if (shouldRenew)
            Provider.of<GlobalState>(context, listen: false).prepareNewSearch();
          Provider.of<GlobalState>(context, listen: false)
              .loadTop(this.searchTimeFilter);
          setState(() {});
          break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: ExpandingAudioPlayer(
        background: Scaffold(
          appBar: SubmissionListAppBar(
            initialIsSearching:
                widget.initialQuery != null && widget.initialQuery.isNotEmpty,
            initialQuery: widget.initialQuery,
            initialSort: widget.initialSort,
            initialTimeFilter: widget.initialTimeFilter,
            onSelectedFilter: (TimeFilter result) {
              this.searchTimeFilter = result;
              if (this.submittedSearchQuery == this.currentSearchQuery) {
                _updateSearch(true);
              }
            },
            onSelectedItem: (Sort result) {
              this.searchSort = result;
              //This way the search only gets updated after every submission.
              if (this.submittedSearchQuery == this.currentSearchQuery)
                _updateSearch(true);
            },
            onSubmitted: (query) {
              this.submittedSearchQuery = query;
              _updateSearch(true);
            },
            /*FIXME: There's probably a more efficient way to check if the user
                changed their query, maybe using onEditingComplete. Fix this. */
            onChanged: (query) {
              this.currentSearchQuery = query;
            },
            clearQuery: () {
              this.submittedSearchQuery = '';
              this.currentSearchQuery = '';
            },
          ),
          onDrawerChanged: (open) {
            // In case a setting change occurred that requires a rebuild.
            if (!open && GwaDrawerManager.updateOnReturn) {
              GwaDrawerManager.updateOnReturn = false;
              _updateSearch(false);
            }
          },
          drawer: GwaDrawer(),
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
                  return RefreshIndicator(
                    color: Theme.of(context).accentColor,
                    backgroundColor: Theme.of(context).backgroundColor,
                    onRefresh: () {
                      globalState.prepareNewSearch();
                      _updateSearch(true);
                      return Future.value();
                    },
                    child: PrimaryScrollController(
                      controller: scrollController,
                      child: GwaScrollbar(
                        child: CustomScrollView(
                          physics: const BouncingScrollPhysics(
                              parent: AlwaysScrollableScrollPhysics()),
                          controller: scrollController,
                          slivers: [
                            SliverPadding(
                              padding: const EdgeInsets.all(8.0),
                              sliver: SliverGrid(
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 3,
                                  mainAxisSpacing: 5,
                                  crossAxisSpacing: 5,
                                ),
                                delegate: SliverChildBuilderDelegate(
                                  (BuildContext context, int index) {
                                    return GwaListItem(
                                      submission:
                                          globalState.searchResults[index],
                                    );
                                  },
                                  childCount: globalState.searchResults.length,
                                ),
                              ),
                            ),
                            SliverToBoxAdapter(child: Builder(builder: (context) {
                              /* If we're loading new content (this will always
                              be new submissions that are added to an existing
                              search since we already determined the stream has
                              data) show a CircularProgressIndicator and animate
                              to it if the user can't see it (submissions are
                              taking up the entire screen, this also makes sure
                              we won't load automatically since the user has to
                              scroll for that to happen.)*/
                              if (globalState.isBusy) {
                                if (globalState.searchResults.length >= 18) {
                                  scrollController.animateTo(
                                      scrollController.position.maxScrollExtent +
                                          100,
                                      duration: Duration(milliseconds: 200),
                                      curve: Curves.easeOut);
                                }
                                return Container(
                                  width: double.infinity,
                                  height: 120,
                                  child:
                                      Center(child: CircularProgressIndicator()),
                                );
                              }
                              /* If we're not busy (loading new data) and there's
                              no more search data in our stream, show a message
                              that indicates to the user there's nothing more to
                              load. */
                              if (globalState.outOfSearchData) {
                                /* If there are exactly 250 results and we can't
                                load more it's probably because of the reddit api
                                limitations. We should inform the user that. */
                                if (globalState.searchResults.length == 249 ||
                                    globalState.searchResults.length == 250) {
                                  return Container(
                                      width: double.infinity,
                                      height: 50,
                                      child: Material(
                                        color: Colors.transparent,
                                        child: InkWell(
                                          onTap: () => showDialog(
                                              context: context,
                                              builder: (BuildContext context) =>
                                                  AlertDialog(
                                                    backgroundColor:
                                                        Theme.of(context)
                                                            .backgroundColor,
                                                    title: const Text(
                                                        "If you got less results than you know you should get, this probably isn't a bug."
                                                        "\n\nThe official reddit api (the thingy I get data from) lets me receive up to 250 posts on a subreddit search."
                                                        "\n\nIf you just get the newest/hottest or top posts the limit is different, but for searching it's 250."
                                                        "\n\nIn the future, we may switch to a different api that supposedly has a far greater limit,"
                                                        " but for now this is what's implemented, sorry!"
                                                        "\n\nIf you're looking for a specific post, try to search for it more specifically (include more of it's title etc...)."
                                                        "\n\nThank you for reading this, have a great day!"
                                                        "\n\ntldr: reddit bad limits results uwu (but not really since they're holding a lot of data that needs to be supplied to a lot of users).",
                                                        style: TextStyle(
                                                            fontSize: 14.0,
                                                            color: Colors.white)),
                                                    actions: [
                                                      TextButton(
                                                          onPressed: () =>
                                                              Navigator.pop(
                                                                  context),
                                                          child: Text('Got it'))
                                                    ],
                                                  )),
                                          child: Center(
                                            child: Column(
                                              children: [
                                                Text(
                                                  'There are no more posts to load.',
                                                  style: TextStyle(
                                                      color: Colors.grey[700]),
                                                ),
                                                Text(
                                                    "Doesn't make sense? click me!",
                                                    style: TextStyle(
                                                        fontSize: 12.0,
                                                        color: Colors.grey[400]))
                                              ],
                                            ),
                                          ),
                                        ),
                                      ));
                                }
                                return Container(
                                    width: double.infinity,
                                    height: 50,
                                    child: Center(
                                      child: Text(
                                        'There are no more posts to load.',
                                        style: TextStyle(color: Colors.grey[700]),
                                      ),
                                    ));
                              }
                              /* If we're not busy and there are more stuff to
                              load, show "nothing" (a Container with no child). */
                              return Container();
                            })),
                          ],
                        ),
                      ),
                    ),
                  );
                }
              },
            ),
          ),
        ),
      ),
    );
  }
}
