import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gwa_app/models/gwa_submission.dart';
import 'package:gwa_app/utils/util_functions.dart';
import 'package:gwa_app/widgets/navigator_routes/hero_dialog_route.dart';
import 'package:gwa_app/widgets/rect_tweens/calm_rect_tween.dart';
import 'package:gwa_app/widgets/website_viewer.dart';

class FloatingPlayButton extends StatelessWidget {
  const FloatingPlayButton({
    Key key,
    @required this.submission,
    this.heroTag,
  }) : super(key: key);

  final GwaSubmission submission;
  final String heroTag;

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: this.heroTag,
      createRectTween: (begin, end) => CalmRectTween(begin: begin, end: end),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(15.0)),
          gradient: RadialGradient(
            radius: 4.0,
            colors: [
              Theme.of(context).primaryColor,
              Theme.of(context).cardColor,
            ],
          ),
        ),
        width: 220.0,
        child: RawMaterialButton(
          shape: new CircleBorder(),
          onPressed: () {
            Navigator.of(context).push(HeroDialogRoute(builder: (context) {
              return _PopupCard(
                submission: this.submission,
                heroTag: this.heroTag,
              );
            }));
          },
          child: Icon(
            Icons.play_arrow,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

class _PopupCard extends StatelessWidget {
  final String heroTag;
  final GwaSubmission submission;

  const _PopupCard({
    Key key,
    @required this.heroTag,
    @required this.submission,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print(submission.audioUrls.length);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Hero(
          tag: this.heroTag,
          createRectTween: (begin, end) =>
              CalmRectTween(begin: begin, end: end),
          child: Material(
            color: Theme.of(context).backgroundColor,
            elevation: 2.0,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(32.0)),
            child: ListView.builder(
              itemBuilder: (context, index) {
                return Container(
                  decoration: BoxDecoration(border: Border(top: BorderSide(color: Colors.black, width: 3.0))),
                  child: ListTile(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => WebsiteViewer(
                            title: submission.title,
                            url: submission.audioUrls[index],
                          ),
                        ),
                      );
                    },
                    title: Text(
                      getUrlTitle(submission.audioUrls[index]),
                      style: TextStyle(
                        color: Colors.grey[300],
                      ),
                    ),
                    subtitle: Text(
                      submission.audioUrls[index],
                      style: TextStyle(
                        color: Colors.grey[500],
                      ),
                    ),
                  ),
                );
              },
              itemCount: submission.audioUrls.length,
              shrinkWrap: true,
            ),
          ),
        ),
      ),
    );
  }
}
