import 'package:flutter/material.dart';
import 'package:gwa_app/widgets/gradient_title_appbar.dart';

class Help extends StatelessWidget {
  const Help({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final TextStyle _textStyle = TextStyle(color: Colors.white, fontSize: 16.0);
    final List<Widget> children = [
      _HelpSectionTextOnly(
          title: "I can't see post preview thumbnails",
          content: "To see post preview thumbnails, you must be logged in AND "
              "have  \"media - Thumbnails\" set to \"Show thumbnails next "
              "to links\" in your Reddit account preferences.\n\n"
              "This can be done automatically by logging in, going to "
              "\"Account\" and clicking on \"Change Account Settings\".\n\n"
              "It can also be done manually. See how in \"How do I "
              "manually set my Reddit account preferences?\" in this page.",
          textStyle: _textStyle),
      _HelpSection(
          title: "How do I manually set my Reddit account preferences?",
          content: [
            ListTile(
              title: Text(
                "To manually set your Reddit account preferences so that you'd "
                "be able to see post preview thumbnails, go to "
                "\"https://old.reddit.com/prefs\".\n",
                style: _textStyle,
              ),
            ),
            Material(
              color: Theme.of(context).primaryColor,
              elevation: 15.0,
              borderRadius: BorderRadius.circular(32.0),
              child: Container(
                margin: const EdgeInsets.all(6.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(32.0),
                  child: const Image(
                      image: AssetImage(
                          'lib/assets/images/help/old reddit prefs url.png')),
                ),
              ),
            ),
            ListTile(
              title: Text(
                "\nMake sure you're logged into your Reddit account that you "
                "use with this app.\n\n"
                "Then, in \"media\", set \"Thumbnails\" to \"Show thumbnails "
                "next to links\".\n",
                style: _textStyle,
              ),
            ),
            Material(
              color: Theme.of(context).primaryColor,
              elevation: 15.0,
              borderRadius: BorderRadius.circular(32.0),
              child: Container(
                margin: const EdgeInsets.all(6.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(32.0),
                  child: InteractiveViewer(
                    child: const Image(
                        image: AssetImage(
                            'lib/assets/images/help/old reddit prefs media '
                            'thumbnails setting.png')),
                  ),
                ),
              ),
            ),
          ],
          textStyle: _textStyle)
    ];

    return Scaffold(
      appBar: GradientTitleAppBar(context, title: 'Help'),
      backgroundColor: Theme.of(context).backgroundColor,
      body: ListView.separated(
          physics: BouncingScrollPhysics(),
          itemBuilder: (BuildContext context, int index) {
            return children.elementAt(index);
          },
          separatorBuilder: (_, __) => Divider(
                thickness: 1.0,
                color: Colors.black26,
              ),
          itemCount: children.length),
    );
  }
}

class _HelpSectionTextOnly extends ExpansionTile {
  _HelpSectionTextOnly({
    @required String title,
    @required String content,
    @required TextStyle textStyle,
  }) : super(
          iconColor: Colors.white,
          collapsedIconColor: Colors.white,
          title: Text(
            title,
            style: textStyle.copyWith(fontWeight: FontWeight.bold),
          ),
          children: [
            ListTile(
              title: Text(
                content,
                style: textStyle,
              ),
            )
          ],
        );
}

class _HelpSection extends ExpansionTile {
  _HelpSection({
    @required String title,
    @required List<Widget> content,
    @required TextStyle textStyle,
  }) : super(
          iconColor: Colors.white,
          collapsedIconColor: Colors.white,
          title: Text(
            title,
            style: textStyle.copyWith(fontWeight: FontWeight.bold),
          ),
          children: content,
        );
}
