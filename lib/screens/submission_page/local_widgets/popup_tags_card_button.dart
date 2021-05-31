import 'package:draw/draw.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:gwa_app/models/gwa_submission.dart';
import 'package:gwa_app/utils/util_functions.dart';
import 'package:gwa_app/widgets/custom_popup_widget_button.dart';

class PopupTagsCardButton extends StatelessWidget {
  final String label;
  final String subtext;
  final IconData icon;
  final Color color;
  final Color subtextColor;
  final String heroTag;
  final void Function(bool value, int index) onSelected;
  final GwaSubmission gwaSubmission;
  final List<bool> selectedTags;

  ///If this is true, the placeholder will be the default one I made unless the [placeholder] parameter is specified. If it isn't the placeholder will be the normal default placeholder.
  final bool usePlaceholder;
  final Widget placeholder;

  const PopupTagsCardButton({
    Key key,
    this.label,
    this.subtext,
    this.icon,
    this.color,
    this.subtextColor,
    @required this.heroTag,
    @required this.onSelected,
    @required this.gwaSubmission,
    @required this.selectedTags,
    this.usePlaceholder,
    this.placeholder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomPopupWidgetButton(
      label: this.label,
      subtext: this.subtext,
      color: this.color,
      subtextColor: this.subtextColor,
      icon: this.icon,
      heroTag: this.heroTag,
      widget: PopupStatefulTagsCard(
        onSelected: this.onSelected,
        gwaSubmission: this.gwaSubmission,
        selectedTags: this.selectedTags,
      ),
      usePlaceholder: this.usePlaceholder,
      placeholder: this.placeholder,
    );
  }
}

class PopupStatefulTagsCard extends StatefulWidget {
  final void Function(bool value, int index) onSelected;
  final GwaSubmission gwaSubmission;
  final List<bool> selectedTags;

  const PopupStatefulTagsCard({
    Key key,
    @required this.onSelected,
    @required this.gwaSubmission,
    @required this.selectedTags,
  }) : super(key: key);

  @override
  PopupStatefulTagsCardState createState() => PopupStatefulTagsCardState();
}

class PopupStatefulTagsCardState extends State<PopupStatefulTagsCard> {
  /*TODO: Find a way to make this one function that would work also on
     submission_page instead of two different ones... */
  List<Widget> getChipList() {
    List<Widget> chips = [];
    for (var i = 0; i < widget.gwaSubmission.tags.length; i++) {
      var avatarCreator =
          UtilFunctions.tagChipAvatar(widget.gwaSubmission.tags[i]);
      Widget avatar = avatarCreator[0];
      int chars = avatarCreator[1];
      switch (chars) {
        case 1:
          chips.add(
            FilterChip(
              selected: widget.selectedTags[i],
              label: Text(widget.gwaSubmission.tags[i]),
              backgroundColor: Theme.of(context).primaryColor,
              labelPadding: const EdgeInsets.only(left: 3.0, right: 6.0),
              selectedColor: Theme.of(context).accentColor,
              side: BorderSide(width: 0.0),
              avatar: avatar,
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
            ),
          );
          break;
        case 2:
          chips.add(
            /*FIXME: Some tags are too long to display on this widget and can't
                be seen fully. */
            FilterChip(
              selected: widget.selectedTags[i],
              label: Text(widget.gwaSubmission.tags[i]),
              backgroundColor: Theme.of(context).primaryColor,
              labelPadding: const EdgeInsets.only(left: 3.0, right: 6.0),
              padding: const EdgeInsets.only(left: 4.0),
              selectedColor: Theme.of(context).accentColor,
              side: BorderSide(width: 0.0),
              avatar: avatar,
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
            ),
          );
          break;
      }
    }
    return chips;
  }

  bool _isOneSelected() {
    for (bool tag in widget.selectedTags) {
      if (tag) return true;
    }
    return false;
  }

  String _makeHardTagQuery() {
    String query = '';
    for (var i = 0; i < widget.gwaSubmission.tags.length; i++) {
      if (widget.selectedTags[i]) {
        query += 'title:${widget.gwaSubmission.tags[i]} ';
      }
    }
    return query;
  }

  String _makeForgivingTagQuery() {
    String query = '';
    for (var i = 0; i < widget.gwaSubmission.tags.length; i++) {
      if (widget.selectedTags[i]) {
        query += '${widget.gwaSubmission.tags[i]} ';
      }
    }
    return query;
  }

  @override
  Widget build(BuildContext context) {
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
                children: getChipList(),
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
                      widget.selectedTags
                          .fillRange(1, widget.selectedTags.length, false);
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
