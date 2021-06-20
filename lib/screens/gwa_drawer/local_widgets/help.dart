import 'package:flutter/material.dart';
import 'package:gwa_app/widgets/gradient_title_appbar.dart';

class Help extends StatelessWidget {
  const Help({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<Widget> children = [
      _HelpSectionTextOnly(
        title: "Why do I need to log into my Reddit account?",
        content: "You do not need to log into your Reddit account. "
            "This app is almost fully functional without one.\n\n"
            "My design philosophy for this project was to get out the user's "
            "way as much as possible. I wanted this app to require no setup "
            "and just work from the get-go.\n"
            "Unfortunately, some features require me to have your Reddit "
            "account logged in. The main one is being able to view post "
            "preview thumbnails.\n\n"
            "When you are logged out your Reddit preferences are set to the "
            "default, which means that the preference that lets you view "
            "preview thumbnails on GoneWildAudio posts isn't the one active. "
            "Additionally, Reddit doesn't provide logged-out users nsfw "
            "thumbnails.\n\n"
            "Then there is of course the ability to upvote a post, but "
            "that's not the main point since you can open the post on your "
            "browser/Reddit app with the \"Open\" button and upvote it "
            "there.\n\n"
            "These are just the things I found. If you know of another way "
            "in which we could get nsfw thumbnails from GoneWildAudio "
            "without being logged in, please contribute to this project on "
            "GitHub! You would make all of us much happier :)",
      ),
      _HelpSectionTextOnly(
        title: "I can't see post preview thumbnails",
        content: "To see post preview thumbnails, you must be logged in AND "
            "have  \"media - Thumbnails\" set to \"Show thumbnails next "
            "to links\" in your Reddit account preferences.\n\n"
            "This can be done automatically by logging in, going to "
            "\"Account\" and clicking on \"Change Account Settings\".\n\n"
            "It can also be done manually. See how in \"How do I "
            "manually set my Reddit account preferences?\" in this page.",
      ),
      _HelpSection(
          title: "How do I manually set my Reddit account preferences?",
          content: [
            ListTile(
              title: Text(
                "To manually set your Reddit account preferences so that you'd "
                "be able to see post preview thumbnails, go to "
                "\"https://old.reddit.com/prefs\".\n",
                style: _Styles.contentStyle,
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
                style: _Styles.contentStyle,
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
          ]),
      //TODO: Add an "My Issue isn't on here" help section
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
  }) : super(
          iconColor: Colors.white,
          collapsedIconColor: Colors.white,
          title: Text(
            title,
            style: _Styles.titleStyle,
          ),
          children: [
            ListTile(
              title: Text(
                content,
                style: _Styles.contentStyle,
              ),
            )
          ],
        );
}

class _HelpSection extends ExpansionTile {
  _HelpSection({
    @required String title,
    @required List<Widget> content,
  }) : super(
          iconColor: Colors.white,
          collapsedIconColor: Colors.white,
          title: Text(
            title,
            style: _Styles.titleStyle,
          ),
          children: content,
        );
}

class _Styles {
  static final TextStyle titleStyle = TextStyle(
    color: Colors.white,
    fontSize: 16.0,
    fontWeight: FontWeight.bold,
  );

  static final TextStyle contentStyle = TextStyle(
    color: Colors.grey[400],
    fontSize: 16.0,
  );
}
