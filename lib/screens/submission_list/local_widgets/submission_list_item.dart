import 'package:draw/draw.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:gwa_app/models/gwa_submission_preview.dart';
import '../../submission_page/submission_page.dart';

class SubmissionListItem extends StatelessWidget {
  final GwaSubmissionPreview submission;
  /*FIXME:Fix the fact that it takes a reddit instance as a parameter.
     Maybe use some sort of state which will have it. */
  final Reddit reddit;

  const SubmissionListItem({Key key, this.submission, this.reddit}) : super(key: key);

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
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SubmissionPage(
              reddit: reddit, submissionFullname: submission.fullname,
                ),
              ),
            );
          },
        ),
      )
    ]);
  }
}
