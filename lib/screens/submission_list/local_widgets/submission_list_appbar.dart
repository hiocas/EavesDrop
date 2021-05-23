import 'package:draw/draw.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gwa_app/states/global_state.dart';
import 'package:provider/provider.dart';

class SubmissionListAppBar extends StatefulWidget
    implements PreferredSizeWidget {
  final void Function(Sort value) onSelectedItem;
  final void Function(String query) onSubmitted;
  final void Function(String query) onChanged;

  const SubmissionListAppBar({
    Key key,
    @required this.onSubmitted,
    @required this.onChanged,
    @required this.onSelectedItem,
  }) : super(key: key);

  @override
  _SubmissionListAppBarState createState() => _SubmissionListAppBarState();

  @override
  final Size preferredSize = const Size.fromHeight(kToolbarHeight);
}

class _SubmissionListAppBarState extends State<SubmissionListAppBar> {
  bool _isSearching = false;
  Sort sort = Sort.relevance;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: _isSearching
          ? TextField(
              decoration: InputDecoration(
                hintText: 'Search...',
                focusedBorder: UnderlineInputBorder(
                    borderSide:
                        BorderSide(color: Theme.of(context).accentColor)),
              ),
              onSubmitted: (value) {
                if (value != null && value.isNotEmpty)
                  widget.onSubmitted(value);
              },
              onChanged: (value) {
                if (value != null) widget.onChanged(value);
              },
            )
          : Text('Search Results'),
      backgroundColor: Colors.transparent,
      elevation: 15.0,
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
      leading: _isSearching
          ? Consumer<GlobalState>(builder: (context, state, child) {
              return Theme(
                data: Theme.of(context).copyWith(
                  cardColor: Theme.of(context).primaryColor,
                  iconTheme: IconThemeData(color: Colors.white),
                ),
                child: PopupMenuButton<Sort>(
                  enabled: !state.isBusy,
                  initialValue: this.sort,
                  /*FIXME: This is a really hacky solution. Like in
                      PopupTagsCardButton, the parent widget gets called with a
                      function to change it's value. Change this (maybe look into
                      keys). */
                  onSelected: (Sort value) {
                    widget.onSelectedItem(value);
                    setState(() {
                      sort = value;
                    });
                  },
                  itemBuilder: (context) {
                    return List<PopupMenuEntry<Sort>>.generate(5, (index) {
                      return PopupMenuItem(
                          value: Sort.values[index],
                          child: Text(Sort.values[index].toString()));
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
                print('The app bar leading button has been pressed.');
              }),
      actions: [
        _isSearching
            ? IconButton(
                icon: Icon(Icons.close),
                onPressed: () {
                  setState(() {
                    _isSearching = false;
                  });
                },
              )
            : IconButton(
                icon: Icon(Icons.search),
                onPressed: () {
                  print('User requested to search');
                  setState(() {
                    _isSearching = true;
                  });
                },
              )
      ],
    );
  }
}
