import 'package:draw/draw.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gwa_app/states/global_state.dart';
import 'package:gwa_app/widgets/gradient_appbar_flexible_space.dart';
import 'package:provider/provider.dart';

class SubmissionListAppBar extends StatefulWidget
    implements PreferredSizeWidget {
  final void Function(Sort value) onSelectedItem;
  final void Function(TimeFilter value) onSelectedFilter;
  final void Function(String query) onSubmitted;
  final void Function(String query) onChanged;
  final void Function() clearQuery;
  final bool initialIsSearching;
  final String initialQuery;
  final Sort initialSort;
  final TimeFilter initialTimeFilter;

  const SubmissionListAppBar({
    Key key,
    @required this.onSubmitted,
    @required this.onChanged,
    @required this.onSelectedItem,
    @required this.onSelectedFilter,
    @required this.clearQuery,
    this.initialSort,
    this.initialTimeFilter,
    this.initialIsSearching,
    this.initialQuery,
  }) : super(key: key);

  @override
  _SubmissionListAppBarState createState() => _SubmissionListAppBarState();

  @override
  final Size preferredSize = const Size.fromHeight(kToolbarHeight);
}

class _SubmissionListAppBarState extends State<SubmissionListAppBar> {
  bool _isSearching = false;
  Sort _sort = Sort.newest;
  TimeFilter _timeFilter = TimeFilter.all;
  TextEditingController _textFieldController;

  String _sortToString(Sort sort) {
    switch (sort) {
      case Sort.relevance:
        return 'Relevance';
      case Sort.hot:
        return 'Hot';
      case Sort.top:
        return 'Top';
      case Sort.newest:
        return 'Newest';
      case Sort.comments:
        return 'Comments';
      default:
        return '';
    }
  }

  String _timeFilterToString(TimeFilter timeFilter) {
    switch (timeFilter) {
      case TimeFilter.all:
        return 'All';
      case TimeFilter.day:
        return 'Day';
      case TimeFilter.hour:
        return 'Hour';
      case TimeFilter.month:
        return 'Month';
      case TimeFilter.week:
        return 'Week';
      case TimeFilter.year:
        return 'Year';
      default:
        return '';
    }
  }

  bool _timeFilterRelevant() {
    return _sort == Sort.top ||
        _sort == Sort.relevance ||
        _sort == Sort.comments;
  }

  TimeFilter _getSortedTimeFilterValue(int index) {
    switch (index) {
      case 0:
        return TimeFilter.all;
      case 1:
        return TimeFilter.year;
      case 2:
        return TimeFilter.month;
      case 3:
        return TimeFilter.week;
      case 4:
        return TimeFilter.day;
      case 5:
        return TimeFilter.hour;
      default:
        return TimeFilter.values[index];
    }
  }

  List<Widget> _makeAppBarActions() {
    if (_isSearching) {
      if (_timeFilterRelevant()) {
        return [
          Consumer<GlobalState>(builder: (context, state, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                cardColor: Theme.of(context).primaryColor,
                iconTheme: IconThemeData(color: Colors.white),
              ),
              child: PopupMenuButton<TimeFilter>(
                icon: Icon(Icons.filter_alt_outlined),
                enabled: !state.isBusy,
                tooltip: "Filter results based on creation time",
                initialValue: this._timeFilter,
                /*FIXME: This is a really hacky solution. Like in
                        PopupTagsCardButton, the parent widget gets called
                        with a function to change it's value. Change this
                        (maybe look into keys). */
                onSelected: (TimeFilter value) {
                  widget.onSelectedFilter(value);
                  setState(() {
                    _timeFilter = value;
                    _showSnackBar();
                  });
                },
                itemBuilder: (context) {
                  return List<PopupMenuEntry<TimeFilter>>.generate(6, (index) {
                    return PopupMenuItem(
                        value: _getSortedTimeFilterValue(index),
                        child: Text(
                            _timeFilterToString(_getSortedTimeFilterValue(index))));
                  });
                },
                elevation: 15.0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(15.0))),
              ),
            );
          }),
          IconButton(
            icon: Icon(Icons.close),
            tooltip: 'Close search',
            onPressed: () {
              setState(() {
                _isSearching = false;
              });
            },
          ),
        ];
      } else {
        return [
          IconButton(
            icon: Icon(Icons.close),
            tooltip: 'Close search',
            onPressed: () {
              setState(() {
                _isSearching = false;
              });
            },
          )
        ];
      }
    } else {
      return [
        IconButton(
          icon: Icon(Icons.search),
          tooltip: 'Search',
          onPressed: () {
            setState(() {
              _isSearching = true;
              _textFieldController.clear();
              widget.clearQuery.call();
            });
          },
        )
      ];
    }
  }

  String _makeSearchHint() {
    String timeFilter;
    switch (_timeFilter) {
      case TimeFilter.all:
        timeFilter = 'All Time';
        break;
      case TimeFilter.day:
        timeFilter = 'Past 24 Hours';
        break;
      case TimeFilter.hour:
        timeFilter = 'Past Hour';
        break;
      case TimeFilter.month:
        timeFilter = 'Past Month';
        break;
      case TimeFilter.week:
        timeFilter = 'Past Week';
        break;
      case TimeFilter.year:
        timeFilter = 'Past Year';
        break;
    }
    switch (_sort) {
      case Sort.relevance:
        return 'Search Most Relevant, ' + timeFilter + '...';
      case Sort.hot:
        return 'Search Hot...';
      case Sort.top:
        return 'Search Top, ' + timeFilter + '...';
      case Sort.newest:
        return 'Search New...';
        break;
      case Sort.comments:
        return 'Search Comment Count, ' + timeFilter + '...';
      default:
        return '';
    }
  }

  void _showSnackBar() {
    ScaffoldMessenger.of(context)
      ..removeCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(_makeSearchHint())));
  }

  @override
  void initState() {
    _isSearching = widget.initialIsSearching;
    if (widget.initialSort != null){
      _sort = widget.initialSort;
    }
    if (widget.initialTimeFilter != null){
      _timeFilter = widget.initialTimeFilter;
    }
    _textFieldController =
        TextEditingController(text: widget.initialQuery ?? null);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: _isSearching
          ? Consumer<GlobalState>(builder: (context, state, child) {
              return TextField(
                enabled: !state.isBusy,
                controller: _textFieldController,
                decoration: InputDecoration(
                  isDense: true,
                  hintText: 'Search...',
                  focusedBorder: UnderlineInputBorder(
                      borderSide:
                          BorderSide(color: Theme.of(context).accentColor)),
                  enabledBorder: UnderlineInputBorder(
                      borderSide:
                          BorderSide(color: Theme.of(context).primaryColor)),
                ),
                onSubmitted: (value) {
                  if (value != null && value.isNotEmpty)
                    widget.onSubmitted(value);
                },
                onChanged: (value) {
                  if (value != null) widget.onChanged(value);
                },
              );
            })
          : Text('Search Results'),
      backgroundColor: Colors.transparent,
      elevation: 15.0,
      backwardsCompatibility: false,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      flexibleSpace: GradientAppBarFlexibleSpace(),
      leading: _isSearching
          ? Consumer<GlobalState>(builder: (context, state, child) {
              return Theme(
                data: Theme.of(context).copyWith(
                  cardColor: Theme.of(context).primaryColor,
                  iconTheme: IconThemeData(color: Colors.white),
                ),
                child: PopupMenuButton<Sort>(
                  icon: Icon(Icons.sort_outlined),
                  enabled: !state.isBusy,
                  tooltip: 'Sort results',
                  initialValue: this._sort,
                  /*FIXME: This is a really hacky solution. Like in
                      PopupTagsCardButton, the parent widget gets called with a
                      function to change it's value. Change this (maybe look into
                      keys). */
                  onSelected: (Sort value) {
                    widget.onSelectedItem(value);
                    setState(() {
                      _sort = value;
                      _showSnackBar();
                    });
                  },
                  itemBuilder: (context) {
                    return List<PopupMenuEntry<Sort>>.generate(5, (index) {
                      return PopupMenuItem(
                          value: Sort.values[index],
                          child: Text(_sortToString(Sort.values[index])));
                    });
                  },
                  elevation: 15.0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(15.0))),
                ),
              );
            })
          : IconButton(
              icon: Icon(Icons.menu),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              }),
      actions: _makeAppBarActions(),
    );
  }
}
