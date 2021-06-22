import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:gwa_app/models/gwa_submission_preview.dart';
import 'package:gwa_app/utils/util_functions.dart';

class GwaListItem extends StatelessWidget {
  final GwaSubmissionPreview submission;

  const GwaListItem({Key key, this.submission}) : super(key: key);

  /*FIXME: This is a very weird item design. It happened by mistake and
     should be better thought of. Try to redesign it or if you're going with
     it implement it better. */
  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Container(
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.all(Radius.circular(15)),
          image: new DecorationImage(
            image: NetworkImage(submission.thumbnailUrl),
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
            submission.title,
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
          onTap: () {
            pushSubmissionPageWithReturnData(
                context, submission.fullname, false);
          },
        ),
      )
    ]);
  }
}

class GwaLibraryListItem extends StatelessWidget {
  final String title;
  final String fullname;
  final String thumbnailUrl;

  const GwaLibraryListItem({
    Key key,
    this.title,
    this.fullname,
    this.thumbnailUrl,
  }) : super(key: key);

  /*FIXME: This is a very weird item design. It happened by mistake and
     should be better thought of. Try to redesign it or if you're going with
     it implement it better. */
  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Container(
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.all(Radius.circular(15)),
          image: new DecorationImage(
            image: NetworkImage(thumbnailUrl == null || thumbnailUrl.isEmpty
                ? 'https://styles.redditmedia.com/t5_2u463/styles/communityIcon_1lj5xecdisi31.png?width=256&s=98e8187f0403751b02c03e7ffb9f059ce0ce18d9'
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
          onTap: () {
            pushSubmissionPageWithReturnData(
              context,
              fullname,
              true,
            );
          },
        ),
      )
    ]);
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
          borderRadius: BorderRadius.all(Radius.circular(15)),
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
