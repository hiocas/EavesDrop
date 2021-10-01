import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:eavesdrop/models/gwa_submission.dart';
import 'package:eavesdrop/models/hive_boxes.dart';
import 'package:eavesdrop/models/library_gwa_submission.dart';
import 'package:eavesdrop/widgets/custom_popup_widget_button.dart';
import 'package:hive/hive.dart';
import 'dart:math' as math;

//FIXME: This all seems kinda scuffed and very inefficient.
class PopupAddCardButton extends StatefulWidget {
  final String label;
  final String subtext;
  final IconData icon;
  final Color color;
  final Color subtextColor;
  final String heroTag;
  final GwaSubmission gwaSubmission;

  /// If this is true, the placeholder will be the default one I made unless the
  /// [placeholder] parameter is specified. If it isn't the placeholder will be
  /// the normal default placeholder.
  final bool usePlaceholder;
  final Widget placeholder;

  final bool mini;

  const PopupAddCardButton({
    Key key,
    this.label,
    this.subtext,
    this.icon,
    this.color,
    this.subtextColor,
    @required this.heroTag,
    @required this.gwaSubmission,
    this.usePlaceholder,
    this.placeholder,
    this.mini = false,
  }) : super(key: key);

  @override
  _PopupAddCardButtonState createState() => _PopupAddCardButtonState();
}

class _PopupAddCardButtonState extends State<PopupAddCardButton> {
  /* This variable will be used here to first find the submission (if it's in
  the user's library.). */
  LibraryGwaSubmission libraryGwaSubmission;

  // This variable will be used here to update the button ui.
  bool _inLibrary = false;

  Box<LibraryGwaSubmission> libraryBox;

  List<String> _listTags;

  /// Checks if the submission is in the user's library.
  bool _checkInLibrary(List<LibraryGwaSubmission> librarySubmissions) {
    if (librarySubmissions == null || librarySubmissions.isEmpty) return false;
    for (LibraryGwaSubmission libSub in librarySubmissions) {
      if (libSub.fullname == widget.gwaSubmission.fullname) {
        libraryGwaSubmission = libSub;
        return true;
      }
    }
    return false;
  }

  @override
  void dispose() {
    libraryBox.close();
    super.dispose();
  }


  Future<Box<LibraryGwaSubmission>> _initAddButton() async {
    _listTags = await HiveBoxes.listTags;
    return HiveBoxes.openLibraryBox();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Box<LibraryGwaSubmission>>(
      future: _initAddButton(),
      builder: (context, futureBox) {
        if (futureBox.hasData) {
          libraryBox = futureBox.data;
          final List<LibraryGwaSubmission> librarySubmissions =
          libraryBox.values.toList().cast<LibraryGwaSubmission>();
          _inLibrary = _checkInLibrary(librarySubmissions);
          return CustomPopupWidgetButton(
            mini: widget.mini,
            label: _inLibrary ? 'Edit' : widget.label,
            subtext: _inLibrary
                ? "Edit the post's library information"
                : widget.subtext,
            color: widget.color,
            subtextColor: widget.subtextColor,
            icon: _inLibrary ? Icons.edit_outlined : widget.icon,
            heroTag: widget.heroTag,
            onPopupPopped: (value) => setState(() {}),
            widget: PopupStatefulAddCard(
              inLibrary: _inLibrary,
              libraryGwaSubmission: libraryGwaSubmission,
              gwaSubmission: widget.gwaSubmission,
              listTags: _listTags,
            ),
            usePlaceholder: this.widget.usePlaceholder,
            placeholder: this.widget.placeholder,
          );
        }
        //TODO: Find a better way to load this button in.
        return CircularProgressIndicator();
      },
    );
  }
}

class PopupStatefulAddCard extends StatefulWidget {
  final GwaSubmission gwaSubmission;

  /// This variable is used to update the ui as well as perform other checks.
  /// The initial value for it is passed as a parameter, it is then passed to
  /// [PopupStatefulAddCardState], which uses it locally.
  final bool inLibrary;

  /// This variable is used so that we won't have to search for the
  /// [LibraryGwaSubmission] again if it was found in the library by
  /// the [_PopupAddCardButtonState].
  final LibraryGwaSubmission libraryGwaSubmission;

  final List<String> listTags;

  const PopupStatefulAddCard({
    Key key,
    @required this.gwaSubmission,
    @required this.inLibrary,
    @required this.libraryGwaSubmission,
    @required this.listTags,
  }) : super(key: key);

  @override
  PopupStatefulAddCardState createState() => PopupStatefulAddCardState();
}

class PopupStatefulAddCardState extends State<PopupStatefulAddCard> {
  /// This list determines in which lists in the user's library the
  /// [LibraryGwaSubmission] is in. It is used to update the checkboxes as well
  /// as the [LibraryGwaSubmission] itself.
  List<bool> _inLists;

  /// The initial value for this variable is passed down from
  /// [PopupStatefulAddCard] which gets it from [PopupAddCardButton].
  /// This is done so we won't have to check if it's in the user's library more
  /// than one time. It is then updated by this class based on the user's
  /// actions.
  bool _inLibrary;

  /// The initial value for this variable is passed down from
  /// [PopupStatefulAddCard] which gets it from [PopupAddCardButton].
  /// This is done so we won't have to find the submission in the user's
  /// library (if it is there) more than one time. It is then used to talk to
  /// the submission entry in the user's library (update it, add it or delete it).
  LibraryGwaSubmission _libraryGwaSubmission;

  /// This then updates the lists in [_libraryGwaSubmission] as well as the ui
  /// in this widget based on which checkbox the user has pressed and it's value.
  _updateLibrarySubmissionList(int index) {
    setState(() {
      _inLists[index] = !_inLists[index];
      List<String> lists = [];
      for (var i = 0; i < _inLists.length; i++) {
        if (_inLists[i]) lists.add(widget.listTags[i]);
      }
      _libraryGwaSubmission.lists = lists;
      _libraryGwaSubmission.save();
    });
  }

  /// Adds [_libraryGwaSubmission] to the user's library and sets [_inLibrary]
  /// to true.
  _addToLibrary() async {
    _libraryGwaSubmission = await HiveBoxes.addLibrarySubmission(
        widget.gwaSubmission.title,
        widget.gwaSubmission.fullname,
        widget.gwaSubmission.thumbnailUrl, []);
    setState(() {
      _inLibrary = true;
    });
  }

  /// Removes [_libraryGwaSubmission] from the user's library and sets
  /// [_inLibrary] to false.
  _removeFromLibrary() async {
    await _libraryGwaSubmission.delete();
    setState(() {
      _inLibrary = false;
      // Reset the _inList bool list.
      for (var i = 0; i < _inLists.length; i++) {
        _inLists[i] = false;
      }
    });
  }

  /// In here we get the initial values that were passed all the way down from
  /// [PopupAddCardButton].
  @override
  void initState() {
    _inLists = List.generate(widget.listTags.length, (index) => false);
    _libraryGwaSubmission = widget.libraryGwaSubmission;
    _inLibrary = widget.inLibrary;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    /* First, if the submission is in the user's library (meaning
    _libraryGwaSubmission isn't null and _inLibrary is true) we set up the
    _inLists boolean list based on the list the submission is in. */
    if (_libraryGwaSubmission != null && _inLibrary) {
      for (var i = 0; i < widget.listTags.length; i++) {
        for (String list in _libraryGwaSubmission.lists) {
          if (list == widget.listTags[i]) {
            _inLists[i] = true;
            break;
          }
        }
      }
    }
    return Material(
      color: Theme
          .of(context)
          .backgroundColor,
      elevation: 2.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32.0)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: CustomScrollView(
          semanticChildCount: widget.listTags.length,
          shrinkWrap: true,
          slivers: [
            SliverList(
              delegate: SliverChildBuilderDelegate(
                    (BuildContext context, int index) {
                  if (index.isEven) {
                    final int itemIndex = index ~/ 2;
                    return CheckboxListTile(
                      title: Text(widget.listTags[itemIndex],
                          style: TextStyle(
                            color: _inLibrary ? Colors.white : Colors.grey[800],
                          )),
                      value: _inLists[itemIndex],
                      onChanged: (bool value) {
                        if (_inLibrary) {
                          _updateLibrarySubmissionList(itemIndex);
                        }
                      },
                    );
                  }
                  return Divider(color: Colors.black);
                },
                semanticIndexCallback: (Widget w, int localIndex) {
                  if (localIndex.isEven) {
                    return localIndex ~/ 2;
                  }
                  return null;
                },
                childCount: math.max(0, widget.listTags.length * 2 - 1),
              ),
            ),
            SliverPadding(
              padding:
              const EdgeInsets.symmetric(horizontal: 55.0, vertical: 8.0),
              sliver: SliverToBoxAdapter(
                /* FIXME: This makes sure the button won't have "infinite"
                    width, but it seems really hacky. */
                child: SizedBox(
                  height: 50.0,
                  child: FittedBox(
                    /* TODO(Design): Make this button stay in it's place
                        when scrolling the list. */
                    child: ElevatedButton.icon(
                      icon: Icon(_inLibrary ? Icons.close : Icons.add),
                      label: Text(
                        _inLibrary ? 'Remove from Library' : 'Add to Library',
                      ),
                      style: ElevatedButton.styleFrom(
                          primary: Theme
                              .of(context)
                              .primaryColor,
                          elevation: 8.0),
                      onPressed: () async {
                        if (_inLibrary) {
                          _removeFromLibrary();
                        } else {
                          await _addToLibrary();
                        }
                      },
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
