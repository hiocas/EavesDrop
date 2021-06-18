import 'package:flutter/material.dart';
import 'package:gwa_app/widgets/gradient_title_appbar.dart';

class Help extends StatelessWidget {
  const Help({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final TextStyle _textStyle = TextStyle(color: Colors.white);
    final List<Widget> children = [
      ExpansionTile(
        iconColor: Colors.white,
        collapsedIconColor: Colors.white,
        title: Text(
          "I can't see post preview thumbnails",
          style: _textStyle.copyWith(fontWeight: FontWeight.bold),
        ),
        children: [
          ListTile(
            title: Text(
              "To see post preview thumbnails, you must be logged in AND "
              "have  \"media - Thumbnails\" set to \"Show thumbnails next "
              "to links\" in your Reddit account preferences.\n\n"
              "This can be done automatically by logging in, going to "
              "\"Account\" and clicking on \"Change Account Settings\".\n\n"
              "It can also be done manually. See how in \"How do I "
              "manually set my Reddit account preferences?\" in this page.",
              style: _textStyle,
            ),
          )
        ],
      ),
      ExpansionTile(
        iconColor: Colors.white,
        collapsedIconColor: Colors.white,
        title: Text(
          "How do I manually set my Reddit account preferences?",
          style: _textStyle.copyWith(fontWeight: FontWeight.bold),
        ),
        children: [
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
              margin: const EdgeInsets.all(14.0),
              child: const Image(
                  image: AssetImage(
                      'lib/assets/images/help/old reddit prefs url.png')),
            ),
          ),
          ListTile(
            title: Text(
              "\nMake sure you're logged into your Reddit account that you use "
              "with this app.\n\n"
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
              margin: const EdgeInsets.all(14.0),
              child: InteractiveViewer(
                child: const Image(
                    image: AssetImage(
                        'lib/assets/images/help/old reddit prefs media thumbnails '
                            'setting.png')),
              ),
            ),
          ),
        ],
      )
    ];

    return Scaffold(
      appBar: GradientTitleAppBar(context, title: 'Help'),
      backgroundColor: Theme.of(context).backgroundColor,
      body: ListView.separated(
        physics: BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
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
