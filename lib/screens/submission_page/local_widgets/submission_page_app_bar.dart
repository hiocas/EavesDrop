import 'package:flutter/material.dart';
import 'package:gwa_app/models/gwa_submission.dart';
import 'package:gwa_app/screens/submission_page/local_widgets/gwa_link_flair_button.dart';
import 'package:gwa_app/screens/submission_page/local_widgets/popup_image_gradient_button.dart';
import 'package:gwa_app/screens/submission_page/local_widgets/popup_text_button.dart';
import 'package:gwa_app/utils/util_functions.dart';
import 'package:draw/draw.dart' as Draw;
import 'package:gwa_app/widgets/gwa_author_flair.dart';

class SubmissionPageAppBar extends StatelessWidget {
  const SubmissionPageAppBar({
    Key key,
    @required this.submission,
    this.maxTitleTop,
    this.maxTitleAlignTop,
  }) : super(key: key);

  final GwaSubmission submission;
  final double maxTitleTop;
  final double maxTitleAlignTop;

  @override
  Widget build(BuildContext context) {
    double top;
    int authorNameTapCounts = 0;
    return SliverAppBar(
      // TODO: Hide this app bar when tapping to hide the FloatingPlayButton
      pinned: true,
      elevation: 15.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(25.0),
            bottomRight: Radius.circular(25.0)),
      ),
      automaticallyImplyLeading: false,
      expandedHeight: 300,
      stretch: true,
      actions: [
        IconButton(
            icon: Icon(Icons.arrow_downward),
            onPressed: () {
              Navigator.pop(context);
            })
      ],
      flexibleSpace: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          top = constraints.biggest.height;
          return ClipRRect(
            borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(25.0),
                bottomRight: Radius.circular(25.0)),
            child: FlexibleSpaceBar(
              centerTitle: true,
              stretchModes: [
                StretchMode.zoomBackground,
                StretchMode.blurBackground
              ],
              /*TODO: Some titles (like futa gf is pent up)
                                 don't align to the left of the sliver app bar,
                                 fix this. */
              title: Align(
                alignment: top >= maxTitleAlignTop
                    ? Alignment.bottomLeft
                    : Alignment.center,
                child: Padding(
                  padding: top >= maxTitleAlignTop
                      ? EdgeInsets.only(left: 10.0)
                      : EdgeInsets.all(0.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: top >= maxTitleAlignTop
                        ? CrossAxisAlignment.start
                        : CrossAxisAlignment.center,
                    children: [
                      ConstrainedBox(
                        constraints: BoxConstraints(
                            maxWidth: top >= maxTitleAlignTop ? 2000 : 310),
                        child: PopupTextButton(
                          heroTag: 'popup-fulltitle-card',
                          fullText: submission.fullTitle,
                          text: Text(
                            submission.title,
                            maxLines: top >= maxTitleTop
                                ? (top >= maxTitleAlignTop ? 4 : 2)
                                : 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: top >= maxTitleAlignTop
                                ? TextAlign.start
                                : TextAlign.center,
                            style: TextStyle(fontSize: 20),
                          ),
                        ),
                      ),
                      Visibility(
                        visible: top >= maxTitleTop,
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              if (authorNameTapCounts > 1) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content:
                                        Text("If you want to see this author's "
                                            "posts, long press their name."),
                                  ),
                                );
                                authorNameTapCounts = 0;
                              } else {
                                authorNameTapCounts++;
                              }
                            },
                            onLongPress: () {
                              popSubmissionPageWithData(context,
                                  query: 'author:${submission.author}',
                                  sort: Draw.Sort.newest,
                                  timeFilter: Draw.TimeFilter.all);
                            },
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  submission.author,
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                GwaAuthorFlair(
                                  width: 16,
                                  height: 14,
                                  flair: submission.authorFlairText,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Visibility(
                        visible: top >= maxTitleAlignTop,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '\n${submission.fromNow}, '
                              '\u{2b06}${submission.upvotes}',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                height: 0.8,
                                color: Colors.grey,
                                fontSize: 8,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            GwaLinkFlairButton(
                              linkFlair: submission.linkFlairText,
                              height: 9.0,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              background: PopupImageGradientButton(
                heroTag: 'popup-image-gradient',
                image: submission.img,
              ),
            ),
          );
        },
      ),
    );
  }
}
