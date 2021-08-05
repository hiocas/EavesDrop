import 'dart:convert';
import 'package:draw/draw.dart' hide Visibility;
import 'package:eavesdrop/models/search_details.dart';
import 'package:eavesdrop/widgets/animations%20and%20transitions/transitions.dart';
import 'common_tags_list.dart';
import 'package:eavesdrop/utils/util_functions.dart';
import 'package:flutter/material.dart';
import 'package:eavesdrop/utils/search_functions.dart';

class AnimatedSearchFiltersCard extends StatefulWidget {
  const AnimatedSearchFiltersCard({
    Key key,
    this.duration = const Duration(milliseconds: 500),
    this.initialQuery,
    this.sort,
    this.timeFilter,
  }) : super(key: key);

  final Duration duration;
  final String initialQuery;
  final Sort sort;
  final TimeFilter timeFilter;

  @override
  _AnimatedSearchFiltersCardState createState() =>
      _AnimatedSearchFiltersCardState();
}

class _AnimatedSearchFiltersCardState extends State<AnimatedSearchFiltersCard>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        await _controller.reverse();
        return Future.value(true);
      },
      child: SlideFadeTransition(
        animation: _controller,
        beginOffset: Offset(0.0, 0.1),
        child: SearchFiltersCard(
          initialQuery: widget.initialQuery,
          sort: widget.sort,
          timeFilter: widget.timeFilter,
        ),
      ),
    );
  }
}

class SearchFiltersCard extends StatefulWidget {
  final String initialQuery;
  final Sort sort;
  final TimeFilter timeFilter;

  const SearchFiltersCard({
    Key key,
    @required this.initialQuery,
    @required this.sort,
    @required this.timeFilter,
  }) : super(key: key);

  @override
  _SearchFiltersCardState createState() => _SearchFiltersCardState();
}

class _SearchFiltersCardState extends State<SearchFiltersCard> {
  TextEditingController controller;
  Sort _searchSort;
  TimeFilter _searchTimeFilter;

  @override
  void initState() {
    controller = TextEditingController(text: widget.initialQuery);
    _searchSort = widget.sort;
    _searchTimeFilter = widget.timeFilter;
    super.initState();
  }

  void popCard(BuildContext context) {
    Map<String, dynamic> result = {
      'new_query': (widget.initialQuery != controller.text),
      'query': controller.text,
      'sort': SearchFunctions.getSortIndex(_searchSort),
      'time_filter': SearchFunctions.getTimeFilterIndex(_searchTimeFilter),
    };
    Navigator.pop(context, jsonEncode(result));
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Material(
            color: Theme.of(context).backgroundColor,
            elevation: 2.0,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(32.0)),
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  color: Theme.of(context).backgroundColor,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Align(
                        alignment: Alignment.center,
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: Text(
                            'Search Filters',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 24.0),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(maxHeight: 175.0),
                          child: TextField(
                            controller: controller,
                            maxLines: null,
                            textInputAction: TextInputAction.done,
                            keyboardType: TextInputType.text,
                            style: TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              hintText: 'Search...',
                              hintStyle: TextStyle(color: Colors.white),
                              focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Theme.of(context).accentColor)),
                              enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Theme.of(context).primaryColor)),
                            ),
                            onSubmitted: (value) => popCard(context),
                          ),
                        ),
                      ),
                      Container(
                        height: 45,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: Sort.values.length,
                          itemBuilder: (context, index) => Padding(
                            padding: const EdgeInsets.only(right: 6.0),
                            child: ChoiceChip(
                              backgroundColor: Theme.of(context).primaryColor,
                              selectedColor: Theme.of(context).accentColor,
                              labelStyle: TextStyle(color: Colors.white),
                              side: BorderSide(width: 0.0),
                              label: Text(
                                SearchFunctions.sortToString(
                                  Sort.values[index],
                                ),
                              ),
                              selected: _searchSort == Sort.values[index],
                              onSelected: (selected) {
                                _searchSort = Sort.values[index];
                                setState(() {});
                              },
                            ),
                          ),
                        ),
                      ),
                      Visibility(
                        visible:
                            SearchFunctions.timeFilterRelevant(_searchSort),
                        child: Container(
                          height: 45,
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: TimeFilter.values.length,
                            itemBuilder: (context, index) => Padding(
                              padding: const EdgeInsets.only(right: 6.0),
                              child: ChoiceChip(
                                backgroundColor: Theme.of(context).primaryColor,
                                selectedColor: Theme.of(context).accentColor,
                                disabledColor:
                                    darken(Theme.of(context).primaryColor, 0.1),
                                labelStyle: TextStyle(color: Colors.white),
                                side: BorderSide(width: 0.0),
                                label: Text(
                                  SearchFunctions.timeFilterToString(
                                    SearchFunctions.getSortedTimeFilterValue(
                                        index),
                                  ),
                                ),
                                selected: _searchTimeFilter ==
                                    SearchFunctions.getSortedTimeFilterValue(
                                        index),
                                onSelected: SearchFunctions.timeFilterRelevant(
                                        _searchSort)
                                    ? (selected) {
                                        _searchTimeFilter = SearchFunctions
                                            .getSortedTimeFilterValue(index);
                                        setState(() {});
                                      }
                                    : null,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.center,
                        child: ElevatedButton.icon(
                          icon: Icon(Icons.search),
                          label: Text('Filter'),
                          style: ButtonStyle(
                              elevation: MaterialStateProperty.all(15.0),
                              backgroundColor: MaterialStateProperty.all(
                                  Theme.of(context).primaryColor)),
                          onPressed: () => popCard(context),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
          SizedBox(
            height: 365,
            child: Material(
              color: Theme.of(context).backgroundColor,
              elevation: 2.0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(32.0)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: SingleChildScrollView(
                  child: CommonTagsList(
                    tags: [
                      'f4[gender]',
                      'm4[gender]',
                      'tf4[gender]',
                      'tm4[gender]',
                      'nb4[gender]',
                      '[gender]dom',
                      '[gender]sub',
                      'aftercare',
                      'asmr',
                      'blowjob',
                      'cannilingus',
                      'cheating',
                      'cockwarming',
                      'creampie',
                      'cuddling',
                      'deepthroat',
                      'enemies to lovers',
                      'fingering',
                      'friends to lovers',
                      'good boy',
                      'good girl',
                      'grinding',
                      'handjob',
                      'hypnosis',
                      'kissing',
                      'l-bombs',
                      'massage',
                      'missionary',
                      'orgasm',
                      'possessive',
                      'public',
                      'riding',
                      'rough',
                      'script fill',
                      'sfx',
                      'spanking',
                      'teasing',
                      'threesome',
                      'tomboy',
                      'tsundere',
                      'virgin',
                      'whispering',
                      'yandere'
                    ],
                    initialText: controller.text,
                    onSelected: (value, chosenTag) {
                      print('chosenTag:$chosenTag');
                      final SearchDetails current =
                          SearchDetails.fromQuery(controller.text);
                      final String currentTag = '"' + chosenTag + '"';
                      if (value) {
                        print(current.includedTags);
                        current.includedTags =
                            current.includedTags + currentTag;
                        print(current.includedTags);
                      } else {
                        print(current.includedTags);
                        current.includedTags = current.includedTags
                            .replaceFirst(
                                RegExp(currentTag, caseSensitive: false), '');
                        print(current.includedTags);
                      }
                      current.formatIncludedTags();
                      controller.text =
                          SearchDetails.toQuery(controller.text, current);
                      print('type:${this.runtimeType}');
                      this.setState(() {});
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
