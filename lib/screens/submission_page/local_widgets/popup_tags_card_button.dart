import 'package:draw/draw.dart';
import 'package:eavesdrop/models/tag_list.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:eavesdrop/models/gwa_submission.dart';
import 'package:eavesdrop/screens/submission_page/local_widgets/gwa_tag.dart';
import 'package:eavesdrop/utils/util_functions.dart';
import 'package:eavesdrop/widgets/custom_popup_widget_button.dart';

class PopupTagsCardButton extends StatelessWidget {
  final String label;
  final String subtext;
  final IconData icon;
  final Color color;
  final Color subtextColor;
  final String heroTag;
  final void Function(bool value, int index) onSelected;
  final GwaSubmission gwaSubmission;
  final TagList tagList;

  ///If this is true, the placeholder will be the default one I made unless the [placeholder] parameter is specified. If it isn't the placeholder will be the normal default placeholder.
  final bool usePlaceholder;
  final Widget placeholder;

  final bool mini;

  const PopupTagsCardButton({
    Key key,
    this.label,
    this.subtext,
    this.icon,
    this.color,
    this.subtextColor,
    @required this.heroTag,
    @required this.tagList,
    @required this.onSelected,
    @required this.gwaSubmission,
    this.usePlaceholder,
    this.placeholder,
    this.mini = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomPopupWidgetButton(
      label: this.label,
      subtext: this.subtext,
      color: this.color,
      subtextColor: this.subtextColor,
      icon: this.icon,
      mini: this.mini,
      heroTag: this.heroTag,
      widget: PopupStatefulTagsCard(
        onSelected: this.onSelected,
        gwaSubmission: this.gwaSubmission,
        tagList: this.tagList,
      ),
      usePlaceholder: this.usePlaceholder,
      placeholder: this.placeholder,
    );
  }
}

class PopupStatefulTagsCard extends StatefulWidget {
  final void Function(bool value, int index) onSelected;
  final GwaSubmission gwaSubmission;
  final TagList tagList;

  const PopupStatefulTagsCard({
    Key key,
    @required this.tagList,
    @required this.onSelected,
    @required this.gwaSubmission,
  }) : super(key: key);

  @override
  PopupStatefulTagsCardState createState() => PopupStatefulTagsCardState();
}

class PopupStatefulTagsCardState extends State<PopupStatefulTagsCard> {
  List<Widget> _getChipList() {
    List<Widget> chips = [];
    for (var i = 0; i < widget.gwaSubmission.tags.length; i++) {
      chips.add(GwaTag(
        tag: widget.tagList.tags[i],
        selected: widget.tagList.selectedTags[i],
        onSelected: (bool value) {
          /*Update the tags on the submission page, this is also where the
                  * selected bool list is so update it also.*/
          widget.onSelected.call(value, i);
          /*Update the tags on this card (the selected list which is in the
           * submission page widget is used here, it is updated a line above
           * this one so all we need to do is call setState since the list's
           * values have changed.*/
          setState(() {});
        },
      ));
    }
    return chips;
  }

  bool _isOneSelected() {
    for (bool tag in widget.tagList.selectedTags) {
      if (tag) return true;
    }
    return false;
  }

  String _makeHardTagQuery() {
    String query = 'title:';
    String specialQueries = '';
    bool onlySpecials = true;
    for (var i = 0; i < widget.gwaSubmission.tags.length; i++) {
      if (widget.tagList.selectedTags[i]) {
        String _specialQuery =
            _findSpecialTagNameQuery(widget.gwaSubmission.tags[i]);
        if (_specialQuery.isEmpty) {
          onlySpecials = false;
          query += '"${widget.gwaSubmission.tags[i]}" ';
        } else {
          specialQueries = specialQueries + _specialQuery;
        }
      }
    }
    if (onlySpecials)
      return specialQueries;
    query = specialQueries + query;
    return query;
  }

  String _makeForgivingTagQuery() {
    String query = '';
    for (var i = 0; i < widget.gwaSubmission.tags.length; i++) {
      if (widget.tagList.selectedTags[i]) {
        String _specialQuery =
            _findSpecialTagNameQuery(widget.gwaSubmission.tags[i]);
        if (_specialQuery.isEmpty) {
          query += '${widget.gwaSubmission.tags[i]} ';
        } else {
          query += _specialQuery;
        }
      }
    }
    return query;
  }

  String _findSpecialTagNameQuery(String tag) {
    String query = '';
    if (tag.startsWith('{author:}')) {
      query += tag.substring(1, 8) + '"' + tag.substring(9) + '" ';
    }
    return query;
  }

  @override
  Widget build(BuildContext context) {
    // If there are no tags stored in the GwaSubmission...
    if (widget.gwaSubmission.tags.length == 0) {
      return Material(
        color: Theme.of(context).backgroundColor,
        elevation: 2.0,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(32.0)),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              "Couldn't find any tags for this post.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20.0,
                color: Colors.grey[700],
              ),
            ),
          ),
        ),
      );
    }
    // If there are tags stored in the GwaSubmission...
    return Material(
      color: Theme.of(context).backgroundColor,
      elevation: 2.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32.0)),
      child: CustomScrollView(
        shrinkWrap: true,
        scrollDirection: Axis.vertical,
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.all(16.0),
            sliver: SliverToBoxAdapter(
              child: Wrap(
                spacing: 5.0,
                children: _getChipList(),
              ),
            ),
          ),
          SliverPadding(
              padding: const EdgeInsets.all(16.0),
              sliver: SliverToBoxAdapter(
                  child: Wrap(
                alignment: WrapAlignment.spaceEvenly,
                children: [
                  _TagElevatedButton(
                    label: 'Identical Search',
                    icon: Icons.title,
                    onPressed: () {
                      Navigator.pop(context);
                      popSubmissionPageWithData(context,
                          query: _makeHardTagQuery(),
                          sort: Sort.relevance,
                          timeFilter: TimeFilter.all);
                    },
                    snackBarText: "An identical search, searching post"
                        " titles with these exact tag names in"
                        " them.",
                    enabled: _isOneSelected(),
                  ),
                  _TagElevatedButton(
                    label: 'Search',
                    icon: Icons.search,
                    onPressed: () {
                      Navigator.pop(context);
                      popSubmissionPageWithData(context,
                          query: _makeForgivingTagQuery(),
                          sort: Sort.relevance,
                          timeFilter: TimeFilter.all);
                    },
                    snackBarText: 'Regular reddit search using these tags.',
                    enabled: _isOneSelected(),
                  ),
                  _TagElevatedButton(
                    label: 'Clear Selected Tags',
                    icon: Icons.close,
                    onPressed: () {
                      widget.tagList.selectedTags
                          .fillRange(1, widget.tagList.selectedTags.length, false);
                      //Just so we setState() in SubmissionPage.
                      widget.onSelected.call(false, 0);
                      setState(() {});
                    },
                    snackBarText: 'Clear currently selected tags.',
                    enabled: _isOneSelected(),
                  ),
                ],
              )))
        ],
      ),
    );
  }
}

class _TagElevatedButton extends StatelessWidget {
  const _TagElevatedButton(
      {Key key,
      this.label,
      this.icon,
      @required this.onPressed,
      @required this.snackBarText,
      @required this.enabled})
      : super(key: key);

  final String label;
  final IconData icon;
  final void Function() onPressed;
  final String snackBarText;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
        label: Text(label,
            style: TextStyle(
              color: enabled ? Colors.white : Colors.black38,
            )),
        icon: Icon(
          icon,
          color: enabled ? Colors.white : Colors.black38,
        ),
        style: ButtonStyle(
          elevation: MaterialStateProperty.all<double>(15.0),
          backgroundColor:
              MaterialStateProperty.all<Color>(Theme.of(context).accentColor),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14.0))),
        ),
        onPressed: () {
          if (enabled) {
            onPressed.call();
          }
        },
        onLongPress: () {
          ScaffoldMessenger.of(context)
            ..removeCurrentSnackBar()
            ..showSnackBar(SnackBar(
              content: Text(snackBarText),
            ));
        });
  }
}
