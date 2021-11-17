import 'package:eavesdrop/models/hive_boxes.dart';
import 'package:eavesdrop/models/library_gwa_submission.dart';
import 'package:eavesdrop/screens/gwa_drawer/local_widgets/settings/local_widgets/warning_tag_list.dart';
import 'package:eavesdrop/utils/gwa_functions.dart';
import 'package:eavesdrop/widgets/navigator_routes/hero_dialog_route.dart';
import 'package:eavesdrop/widgets/popup_card_button.dart';
import 'package:flutter/material.dart';
import 'default_list_settings.dart';

class LibraryListTags extends StatefulWidget {
  const LibraryListTags({
    Key key,
    @required this.libraryListTags,
    @required this.libraryListTagsCount,
    this.spacing = 15.0,
    this.explanation,
    this.spaceHead = 15.0,
  }) : super(key: key);

  final List<String> libraryListTags;
  final List<int> libraryListTagsCount;
  final double spacing;
  final Widget explanation;
  final double spaceHead;

  @override
  _LibraryListTagsState createState() => _LibraryListTagsState();
}

class _LibraryListTagsState extends State<LibraryListTags> {
  @override
  Widget build(BuildContext context) {
    // TODO: Change this to a list instead of a grid.
    return ListSetting(
      icon: Icons.book,
      settingName: 'Library Lists',
      noChildrenMessage: 'You have no Library Lists saved.',
      height: 180.0,
      spaceHead: widget.spaceHead,
      spacing: widget.spacing,
      length: widget.libraryListTags.length,
      heroTag: 'library-list-tags-popup-tag',
      itemBuilder: (context, index) => Hero(
        tag: 'library-list-tag-entry-popup-tag-$index',
        child: ListTile(
          visualDensity: VisualDensity.compact,
          trailing: Icon(
            Icons.edit,
            color: Colors.white,
          ),
          title: Text(
            widget.libraryListTags[index],
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.white),
          ),
          leading: Text(
            widget.libraryListTagsCount[index].toString(),
            style: const TextStyle(color: Colors.white),
          ),
          onTap: () async {
            final result = await Navigator.push(
              context,
              HeroDialogRoute(
                builder: (context) => EditLibraryListTagListDialog(
                  tags: widget.libraryListTags,
                  heroTag: 'library-list-tag-entry-popup-tag-$index',
                  currentList: widget.libraryListTags[index],
                  currentListEntries: widget.libraryListTagsCount[index],
                ),
              ),
            );
          },
        ),
      ),
      onButtonPressed: () async {
        // if (!_selected) {
        final result = await Navigator.push(
          context,
          HeroDialogRoute(
            builder: (context) => TagListDialog(
              title: 'Library List Name:',
              heroTag: 'library-list-tags-popup-tag',
              tags: widget.libraryListTags,
            ),
          ),
        );
        if (result != null && result.isNotEmpty) {
          widget.libraryListTags.add(result);
          await HiveBoxes.editAppSettings(
              libraryListTags: widget.libraryListTags);
          setState(() {});
        }
        // } else {
        //   /* TODO: Make the user remove these one by one and show a warning
        //       if the list to be removed contains entries and an option to
        //       migrate it's entries to another list. */
        //   for (int i = 0; i < widget.libraryListTags.length; i++) {
        //     if (_selectedLibraryListTags[i]) {
        //       print(widget.libraryListTags[i]);
        //       widget.libraryListTags.remove(i);
        //       i--;
        //     }
        //   }
        //   await HiveBoxes.editAppSettings(
        //       libraryListTags: widget.libraryListTags);
        //   setState(() {});
        // }
      },
    );
  }
}

class EditLibraryListTagListDialog extends StatefulWidget {
  const EditLibraryListTagListDialog({
    Key key,
    @required this.currentList,
    @required this.currentListEntries,
    @required this.tags,
    @required this.heroTag,
  }) : super(key: key);

  final String currentList;
  final int currentListEntries;
  final List<String> tags;
  final String heroTag;

  @override
  _EditLibraryListTagListDialogState createState() =>
      _EditLibraryListTagListDialogState();
}

class _EditLibraryListTagListDialogState
    extends State<EditLibraryListTagListDialog> {
  TextEditingController textEditingController;
  bool _changed = false;
  bool _textFieldEnabled = false;
  List<bool> _selectedEntries;
  List<LibraryGwaSubmission> _submissions = [];
  List<String> _migrateLists;
  String _migrateList;

  // add() {
  //   final String text = textEditingController.text;
  //   if (!text.contains(RegExp(r'\]|\['))) {
  //     bool exists = false;
  //     for (String tag in widget.tags) {
  //       if (tag == text) {
  //         exists = true;
  //         break;
  //       }
  //     }
  //     if (!exists) {
  //       Navigator.of(context).pop(textEditingController.text);
  //     }
  //   }
  // }

  @override
  void initState() {
    textEditingController = new TextEditingController(text: widget.currentList);
    _selectedEntries = List.filled(widget.currentListEntries, false);
    _migrateLists =
        widget.tags.where((element) => element != widget.currentList).toList();
    _migrateList = _migrateLists.first;
    super.initState();
  }

  init() async {
    if (_submissions.isEmpty) {
      final allEntries = await HiveBoxes.getLibraryGwaSubmissionList();
      for (LibraryGwaSubmission submission in allEntries) {
        if (submission.lists.contains(widget.currentList))
          _submissions.add(submission);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Hero(
          tag: widget.heroTag,
          child: DefaultPopupCard(
            heroTag: widget.heroTag,
            child: FutureBuilder<void>(
                future: init(),
                builder: (context, snapshot) {
                  final bool _entrySelected =
                      _selectedEntries.any((element) => element);
                  return Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                            width: 240,
                            child: TextField(
                              controller: textEditingController,
                              style: TextStyle(
                                  color: _textFieldEnabled
                                      ? Colors.white
                                      : Colors.black45),
                              enabled: _textFieldEnabled,
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                                _textFieldEnabled ? Icons.check : Icons.edit),
                            color: _textFieldEnabled
                                ? Colors.blueAccent
                                : Colors.white,
                            onPressed: () {
                              setState(() {
                                _textFieldEnabled = !_textFieldEnabled;
                                if (!_textFieldEnabled) {
                                  if (textEditingController.text ==
                                      widget.currentList)
                                    _changed = false;
                                  else
                                    _changed = true;
                                }
                              });
                            },
                          ),
                        ],
                      ),
                      SizedBox(height: 5),
                      Text(
                        "Make sure it isn't included already and that there are "
                        "no \"[ ]\".",
                        style: TextStyle(
                            color: Colors.grey[500],
                            fontWeight: FontWeight.w500,
                            fontSize: 14.0),
                      ),
                      IgnorePointer(
                        ignoring: widget.currentListEntries == 0,
                        child: ExpansionTile(
                          leading: Icon(Icons.bookmarks),
                          tilePadding: EdgeInsets.zero,
                          title: Text('Entries (${widget.currentListEntries})'),
                          childrenPadding: EdgeInsets.zero,
                          expandedCrossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                TextButton.icon(
                                  label: Text('Migrate'),
                                  icon: Icon(Icons.drive_file_move),
                                  onPressed: _entrySelected
                                      ? () {
                                          for (int i = 0;
                                              i < widget.currentListEntries;
                                              i++) {
                                            final LibraryGwaSubmission
                                                _submission = _submissions[i];
                                            if (!_submission.lists
                                                .contains(_migrateList)) {
                                              final List<String> list =
                                                  _submission.lists;
                                              list[list.indexOf(
                                                      widget.currentList)] =
                                                  _migrateList;
                                              if (_selectedEntries[i]) {
                                                HiveBoxes.editLibrarySubmission(
                                                    _submission,
                                                    lists: list);
                                              }
                                              setState(() {});
                                            }
                                          }
                                        }
                                      : null,
                                ),
                                Text('to'),
                                SizedBox(width: 10.0),
                                DropdownButton<String>(
                                  value: _migrateList,
                                  items: _migrateLists
                                      .map<DropdownMenuItem<String>>((list) =>
                                          DropdownMenuItem<String>(
                                              value: list, child: Text(list)))
                                      .toList(),
                                  onChanged: _entrySelected
                                      ? (newValue) => setState(() {
                                            _migrateList = newValue;
                                          })
                                      : null,
                                )
                              ],
                            ),
                            ConstrainedBox(
                              constraints: BoxConstraints(maxHeight: 400),
                              child: ListView.builder(
                                itemCount: _submissions.length,
                                shrinkWrap: true,
                                itemBuilder: (context, index) {
                                  final String lists =
                                      _submissions[index].lists.toString();
                                  String imageUrl =
                                      _submissions[index].thumbnailUrl;
                                  if (imageUrl == null || imageUrl.isEmpty)
                                    imageUrl =
                                        GwaFunctions.getPlaceholderImageUrl(
                                            _submissions[index].fullname);
                                  return ListTile(
                                    visualDensity: VisualDensity.compact,
                                    dense: true,
                                    title: Text(_submissions[index].title),
                                    isThreeLine: true,
                                    contentPadding: EdgeInsets.zero,
                                    minLeadingWidth: 0.0,
                                    selectedTileColor: Colors.white,
                                    selected: _selectedEntries[index],
                                    onTap: () {
                                      setState(() {
                                        if (!_submissions[index]
                                            .lists
                                            .contains(_migrateList)) {
                                          _selectedEntries[index] =
                                              !_selectedEntries[index];
                                        } else {
                                          _selectedEntries[index] = false;
                                        }
                                      });
                                    },
                                    leading: Container(
                                      height: 30.0,
                                      width: 30.0,
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                        image: DecorationImage(
                                          image: NetworkImage(imageUrl),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    subtitle: Text(
                                      _submissions[index].fullname +
                                          '\n' +
                                          lists.substring(1, lists.length - 1),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          TextButton.icon(
                            label: Text('Cancel'),
                            icon: Icon(Icons.cancel),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                          TextButton.icon(
                            label: Text('Remove'),
                            icon: Icon(Icons.delete),
                            onPressed: () {},
                          ),
                          TextButton.icon(
                            label: Text('Save'),
                            icon: Icon(Icons.done_all),
                            onPressed: _changed ? () {} : null,
                          ),
                        ],
                      )
                    ],
                  );
                }),
          ),
        ),
      ),
    );
  }
}
