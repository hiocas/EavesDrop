import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:gwa_app/widgets/markdown_viewer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:gwa_app/models/gwa_submission.dart';
import '../../widgets/popup_card_button.dart';
import 'package:gwa_app/widgets/particles_icon_text_button.dart';
import 'package:gwa_app/utils/util_functions.dart';
import 'local_widgets/all_page_local.dart';
import 'package:provider/provider.dart';
import 'package:gwa_app/states/global_state.dart';

class SubmissionPage extends StatefulWidget {
  final String submissionFullname;

  ///Are we coming here from the [Library] page?
  final bool fromLibrary;

  const SubmissionPage({
    Key key,
    this.submissionFullname,
    @required this.fromLibrary,})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => SubmissionPageState();
}

class SubmissionPageState extends State<SubmissionPage> {
  String _fullname;
  GwaSubmission _submission;
  List<bool> _selectedTags = [];
  bool _isOneSelected = false;

  //These are all thresholds for elements in the sliver app bar to appear or disappear.
  var top = 0.0;
  var maxTitleTop = 120;
  var maxTitleAlignTop = 200;

  @override
  void initState() {
    super.initState();
    _fullname = widget.submissionFullname.substring(3);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future:
      Provider.of<GlobalState>(context).populateSubmission(id: _fullname),
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        } else {
          _submission = new GwaSubmission(snapshot.data);
          /*FIXME: This gets called every setState so if I want the selected
                   tags to not get overridden I used this check, seems a bit
                   scuffed. */
          if (_selectedTags.length == 0) {
            _selectedTags =
            List<bool>.generate(_submission.tags.length, (index) => false);
            if (!_isOneSelected) {
              for (bool tag in _selectedTags) {
                if (tag) {
                  _isOneSelected = true;
                  break;
                }
              }
            }
          }
          return RefreshIndicator(
            //TODO: Implement pull to refresh.
            onRefresh: () {
              print('User requested a refresh');
              return Future.value();
            },
            child: Scaffold(
              backgroundColor: Theme
                  .of(context)
                  .backgroundColor,
              body: SafeArea(
                child: CustomScrollView(
                  physics: const BouncingScrollPhysics(
                      parent: AlwaysScrollableScrollPhysics()),
                  slivers: [
                    //Sliver App Bar
                    SliverAppBar(
                      /*TODO(Design): Decide whether the app bar should be
                         pinned or not. */
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
                        builder:
                            (BuildContext context, BoxConstraints constraints) {
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
                                            maxWidth: top >= maxTitleAlignTop
                                                ? 2000
                                                : 330),
                                        child: PopupTextButton(
                                          heroTag: 'popup-fulltitle-card',
                                          fullText: _submission.fullTitle,
                                          text: Text(
                                            _submission.title,
                                            overflow: top >= maxTitleTop
                                                ? TextOverflow.visible
                                                : TextOverflow.ellipsis,
                                            style: TextStyle(fontSize: 20),
                                          ),
                                        ),
                                      ),
                                      Visibility(
                                        visible: top >= maxTitleTop,
                                        child: Text(
                                          _submission.author,
                                          style: TextStyle(
                                            color: Colors.grey,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                      Visibility(
                                        visible: top >= maxTitleAlignTop,
                                        child: Text(
                                          '\n' +
                                              _submission.fromNow +
                                              ', \u{2b06}' +
                                              _submission.upvotes.toString(),
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            height: 0.8,
                                            color: Colors.grey,
                                            fontSize: 8,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              background: PopupImageGradientButton(
                                heroTag: 'popup-image-gradient',
                                image: _submission.img,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    //Buttons
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.only(
                          left: 4.0,
                          right: 4.0,
                          bottom: 10.0,
                          top: 15.0,
                        ),
                        //TODO(Design): Design these buttons better.
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            PopupAddCardButton(
                              icon: Icons.add,
                              label: 'Save',
                              subtext: 'Save this post to your library',
                              color: Theme
                                  .of(context)
                                  .primaryColor,
                              gwaSubmission: _submission,
                              heroTag: 'save-submission-popup',
                              usePlaceholder: true,
                              fromLibrary: widget.fromLibrary,
                            ),
                            ParticlesIconTextButton(
                              icon: Icons.favorite_border,
                              label: 'Open',
                              subtext: 'Upvote this and show your support!',
                              color: Theme
                                  .of(context)
                                  .primaryColor,
                              onPressed: () {
                                launch(_submission.shortlink.toString());
                              },
                              confettiDuration: Duration(milliseconds: 300),
                            ),
                            PopupCardButton(
                              icon: Icons.expand,
                              label: 'Details',
                              subtext: "Show all of the post's details",
                              color: Theme
                                  .of(context)
                                  .primaryColor,
                              heroTag: 'submission-details-popup',
                              child: Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: SubmissionDetails(
                                  gwaSubmission: _submission,
                                ),
                              ),
                              usePlaceholder: true,
                            ),
                            PopupTagsCardButton(
                              icon: Icons.search,
                              label: 'Tags',
                              subtext: "View and query all of the post's tags",
                              color: Theme
                                  .of(context)
                                  .primaryColor,
                              heroTag: 'submission-tags-popup',
                              gwaSubmission: _submission,
                              selectedTags: _selectedTags,
                              onSelected: (bool value, int index) {
                                print(_submission.tags[index]);
                                setState(() {
                                  _selectedTags[index] = value;
                                  print(_selectedTags[index]);
                                });
                              },
                              usePlaceholder: true,
                            ),
                          ],
                        ),
                      ),
                    ),
                    //Tags
                    SliverToBoxAdapter(
                      child: _submission.tags.length > 0 ? Container(
                        margin: const EdgeInsets.only(
                            left: 10.0, top: 4.0, bottom: 4.0),
                        height: 35,
                        child: ListView.builder(
                          itemBuilder: (BuildContext context, int index) {
                            var tagList = _submission.tags;
                            var avatarCreator =
                            UtilFunctions.tagChipAvatar(tagList[index]);
                            Widget avatar = avatarCreator[0];
                            int chars = avatarCreator[1];
                            //If there are 2 chars as an avatar.
                            if (chars == 2)
                              return Container(
                                padding: const EdgeInsets.only(right: 4.0),
                                child: FilterChip(
                                  labelPadding: const EdgeInsets.only(
                                      left: 2.0, right: 10.0),
                                  padding: const EdgeInsets.only(left: 4.0),
                                  visualDensity: VisualDensity.compact,
                                  selected: _selectedTags[index],
                                  label: Text(tagList[index]),
                                  backgroundColor:
                                  Theme
                                      .of(context)
                                      .primaryColor,
                                  selectedColor: Theme
                                      .of(context)
                                      .accentColor,
                                  side: BorderSide(width: 0.0),
                                  avatar: avatar,
                                  onSelected: (bool value) {
                                    print(tagList[index]);
                                    setState(() {
                                      _selectedTags[index] = value;
                                      print(_selectedTags[index]);
                                    });
                                  },
                                ),
                              );
                            //If there is any other number of chars as an avatar.
                            else
                              return Container(
                                padding: const EdgeInsets.only(right: 4.0),
                                child: FilterChip(
                                  labelPadding: const EdgeInsets.only(
                                      left: 3.0, right: 6.0),
                                  visualDensity: VisualDensity.compact,
                                  selected: _selectedTags[index],
                                  label: Text(tagList[index]),
                                  backgroundColor:
                                  Theme
                                      .of(context)
                                      .primaryColor,
                                  selectedColor: Theme
                                      .of(context)
                                      .accentColor,
                                  side: BorderSide(width: 0.0),
                                  avatar: avatar,
                                  onSelected: (bool value) {
                                    print(tagList[index]);
                                    setState(() {
                                      _selectedTags[index] = value;
                                      print(_selectedTags[index]);
                                    });
                                  },
                                ),
                              );
                          },
                          itemCount: _submission.tags.length,
                          shrinkWrap: true,
                          scrollDirection: Axis.horizontal,
                        ),
                        /* This makes it so we won't show the tag list if the
                        post has no tags. */
                      ) : null,
                    ),
                    //SelftextViewer
                    SliverPadding(
                      padding: const EdgeInsets.all(10.0),
                      sliver: SliverToBoxAdapter(
                          child: Material(
                            color: Theme
                                .of(context)
                                .backgroundColor,
                            elevation: 15.0,
                            shape: RoundedRectangleBorder(
                                borderRadius:
                                BorderRadius.all(Radius.circular(32.0))),
                            child: Padding(
                              padding: const EdgeInsets.all(14.0),
                              child: MarkdownViewer(
                                text: _submission.selftext,
                                bodyTextFontSize: 14.0,
                              ),
                            ),
                          )),
                    ),
                    /*FIXME(Design): This makes sure the SelfTextViewer (now the
                        MarkdownViewer) can be fully read without the floating
                        action button blocking the text at the end of the
                        CustomScrollView. Find a better solution or redesign
                        the ui. */
                    SliverToBoxAdapter(
                      child: Container(
                        height: 70,
                      ),
                    )
                  ],
                ),
              ),
              floatingActionButton: FloatingPlayButton(
                heroTag: 'floating-play-button-popup',
                submission: _submission,
              ),
              floatingActionButtonLocation:
              FloatingActionButtonLocation.centerFloat,
            ),
          );
        }
      },
    );
  }
}
