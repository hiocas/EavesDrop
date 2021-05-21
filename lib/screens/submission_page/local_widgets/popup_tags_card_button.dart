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

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).backgroundColor,
      elevation: 2.0,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(32.0)),
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Wrap(
            spacing: 5.0,
            children: getChipList(),
          ),
        ),
      ),
    );
  }
}
