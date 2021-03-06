import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:eavesdrop/models/gwa_submission_preview.dart';
import 'package:eavesdrop/utils/gwa_functions.dart';
import 'package:eavesdrop/utils/util_functions.dart';

class GwaListItem extends StatelessWidget {
  final GwaSubmissionPreview submission;

  const GwaListItem({Key key, this.submission}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListPreviewItem(
      title: submission.title,
      fullname: submission.fullname,
      thumbnailUrl: submission.thumbnailUrl,
    );
  }
}

class ListPreviewItem extends StatelessWidget {
  final String title;
  final String fullname;
  final String thumbnailUrl;
  final void Function() onReturn;

  const ListPreviewItem({
    Key key,
    @required this.title,
    @required this.fullname,
    this.thumbnailUrl,
    this.onReturn,
  }) : super(key: key);

  /*FIXME: This is a very weird item design. It happened by mistake and
     should be better thought of. Try to redesign it or if you're going with
     it implement it better. */

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
            image: new DecorationImage(
              image: NetworkImage(thumbnailUrl == null || thumbnailUrl.isEmpty
                  ? GwaFunctions.getPlaceholderImageUrl(this.fullname)
                  : thumbnailUrl),
              fit: BoxFit.cover,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                offset: Offset(4, 4),
                blurRadius: 5.0,
                spreadRadius: 1.0,
              ),
            ],
          ),
        ),
        Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [Colors.black, Colors.transparent],
          )),
        ),
        Padding(
          padding: EdgeInsets.all(4.0),
          child: Align(
            alignment: Alignment.bottomLeft,
            child: Text(
              title,
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 14,
                color: Colors.white,
              ),
            ),
          ),
        ),
        Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.vertical(top: Radius.circular(15.0)),
            onTap: () {
              pushSubmissionPageWithReturnData(
                context,
                fullname,
              ).then((value) {
                if (onReturn != null) onReturn.call();
              });
            },
          ),
        )
      ],
    );
  }
}

class DummyListItem extends StatelessWidget {
  const DummyListItem({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Container(
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              offset: Offset(4, 4),
              blurRadius: 5.0,
              spreadRadius: 1.0,
            ),
          ],
        ),
      ),
      Container(
        decoration: BoxDecoration(
            gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [Colors.black, Colors.transparent],
        )),
      ),
      Padding(
        padding: EdgeInsets.all(4.0),
        child: Align(
          alignment: Alignment.bottomLeft,
        ),
      ),
    ]);
  }
}
