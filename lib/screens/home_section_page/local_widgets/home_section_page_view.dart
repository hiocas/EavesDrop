import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:eavesdrop/models/gwa_submission_preview.dart';
import 'package:eavesdrop/utils/util_functions.dart';
import 'package:eavesdrop/widgets/gwa_author_flair.dart';

// THIS IS NOT MY DESIGN AND CODE I LOOKED AT A TUTORIAL BY Marcus Ng.
class HomeSectionPageView extends StatefulWidget {
  const HomeSectionPageView({
    Key key,
    @required this.previews,
  }) : super(key: key);

  final List<GwaSubmissionPreviewWithAuthor> previews;

  @override
  _HomeSectionPageViewState createState() => _HomeSectionPageViewState();
}

class _HomeSectionPageViewState extends State<HomeSectionPageView> {
  PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    this._pageController = PageController(viewportFraction: 0.9);
    // Auto Scroll Pages:
    Timer.periodic(Duration(seconds: 8), (timer) {
      if (this._currentPage < widget.previews.length) {
        this._currentPage++;
      } else {
        this._currentPage = 0;
      }

      /* To get rid of errors that happen when the page controller isn't
      attached to any scroll views. */
      if (this._pageController.hasClients) {
        this._pageController.animateToPage(_currentPage,
            duration: Duration(milliseconds: 800),
            curve: Curves.easeInOutQuint);
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 230.0,
      child: PageView.builder(
        controller: this._pageController,
        itemCount: widget.previews.length,
        itemBuilder: (BuildContext context, int index) {
          return Container(
            margin: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
            width: 120.0,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.0),
              image: DecorationImage(
                image: NetworkImage(
                  widget.previews[index].thumbnailUrl,
                ),
                fit: BoxFit.cover,
              ),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  offset: Offset(0.0, 2.0),
                  blurRadius: 6.0,
                )
              ],
            ),
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withOpacity(0.8),
                        Colors.transparent
                      ],
                    ),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16.0, 0.0, 4.0, 16.0),
                  child: Align(
                    alignment: Alignment.bottomLeft,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.previews[index].title,
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18.0),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ConstrainedBox(
                              constraints: BoxConstraints(maxWidth: 300.0),
                              child: Text(widget.previews[index].author,
                                  style: TextStyle(
                                      color: Colors.grey[500],
                                      fontWeight: FontWeight.w500,
                                      fontSize: 14.0),
                                  overflow: TextOverflow.ellipsis),
                            ),
                            GwaAuthorFlair(
                              width: 16.0,
                              height: 14.0,
                              flair: widget.previews[index].authorFlairText,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                Material(
                  type: MaterialType.transparency,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(10.0),
                    onTap: () {
                      pushSubmissionPageWithReturnData(
                          context, widget.previews[index].fullname);
                    },
                  ),
                ),
              ],
            ),
          );
        },
        onPageChanged: (int pageIndex) {
          this._currentPage = pageIndex;
        },
      ),
    );
  }
}
