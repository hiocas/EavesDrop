import 'package:flutter/material.dart';
import 'package:eavesdrop/widgets/gradient_title_appbar.dart';
import 'package:url_launcher/url_launcher.dart';

class Help extends StatelessWidget {
  const Help({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<Widget> children = [
      _HelpSectionTextOnly(
        title: "Why do I need to log into my Reddit account?",
        content: "YOU DO NOT NEED TO LOG INTO YOUR REDDIT ACCOUNT. "
            "This app is almost fully functional without being logged into "
            "one.\n\n"
            "My design philosophy for this project was to get out of the "
            "user's way as much as possible. I wanted this app to require no "
            "setup and just work from the get-go.\n"
            "Unfortunately, some features require me to have your Reddit "
            "account logged in. The main one is being able to view post "
            "preview thumbnails.\n\n"
            "When you aren't logged in your Reddit preferences are the default "
            "ones, which means that the preference that lets you view preview "
            "thumbnails on GoneWildAudio posts isn't the one active. "
            "Additionally, Reddit doesn't provide nsfw thumbnails to "
            "logged-out users.\n\n"
            "Then there's of course the ability to upvote a post, but "
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
      _HelpSectionTextOnly(
          title: 'How do I downvote posts?',
          content: "First, make sure you're logged in."
              "\n\nIf the post isn't archived, just long-press the \"Vote\" "
              "button."),
      _HelpSectionTextOnly(
          title: 'Searching outputs only a small amounts of posts',
          content: "If you got less results than you know you should get, this "
              "probably isn't a bug."
              "\n\nThe official reddit api (the thingy I get data from) lets "
              "me receive up to 250 posts on a subreddit search."
              "\n\nIf you just get the newest/hottest or top posts the limit "
              "is different, but for searching it's 250."
              "\n\nIn the future, we may switch to a different api that "
              "supposedly has a far greater limit,"
              " but for now this is what's implemented, sorry!"
              "\n\nIf you're looking for a specific post, try to search for it "
              "more specifically (include more of it's title etc...)."
              "\n\nIn case you got less results than 250-ish and you know for "
              "sure you're supposed to get more, please report this as an "
              "issue (see how in \"My issue isn't on here\")."
              "\n\nThank you for reading this, have a great day!"
              "\n\ntldr: reddit bad limits results uwu (but not really since "
              "they're holding a lot of data that needs to be supplied to a "
              "lot of users)."),
      _HelpSection(
        title: "My issue isn't on here",
        headerColor: Theme.of(context).primaryColor,
        content: [
          ListTile(
            title: Text(
              "If you're issue isn't in here, you can report it on our GitHub "
              "repository."
              "\n\nBefore doing so, please make sure your issue isn't already "
              "reported"
              "\n\nIf it hasn't been reported yet, click on \"New Issue\", "
              "choose \"Bug Report\" and follow the instructions there."
              "\n\nThank You!",
              style: _Styles.contentStyle,
            ),
          ),
          ElevatedButton.icon(
            icon: Icon(Icons.launch),
            label: Text('Open Issues'),
            onPressed: () => launch(
                'https://github.com/hiocas/EavesDrop/issues?q=is%3Aissue'),
            style: ButtonStyle(
                backgroundColor:
                    MaterialStateProperty.all(Theme.of(context).primaryColor)),
          )
        ],
      ),
      _HelpSection(
        title: "I wanna help! How can I contribute?",
        headerColor: Theme.of(context).primaryColor,
        content: [
          ListTile(
            title: Text(
              "Whether you can code or not, there are things you can help us "
              "improve in and any kind of contribution is always welcomed!"
              "\n\nYou can head to Contributions.md on our GitHub repository "
              "to get started!"
              "\n",
              style: _Styles.contentStyle,
            ),
          ),
          ElevatedButton.icon(
            icon: Icon(Icons.launch),
            label: Text('Open Contributions.md'),
            onPressed: () => launch(
              'https://github.com/hiocas/EavesDrop/blob/master/Contributions.md',
            ),
            style: ButtonStyle(
                backgroundColor:
                    MaterialStateProperty.all(Theme.of(context).primaryColor)),
          )
        ],
      )
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
    Color headerColor,
    @required String content,
  }) : super(
          iconColor: headerColor ?? Colors.white,
          collapsedIconColor: headerColor ?? Colors.white,
          title: Text(
            title,
            style: _Styles.titleStyle.copyWith(color: headerColor),
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
    Color headerColor,
    @required List<Widget> content,
  }) : super(
          iconColor: headerColor ?? Colors.white,
          collapsedIconColor: headerColor ?? Colors.white,
          title: Text(
            title,
            style: _Styles.titleStyle.copyWith(color: headerColor),
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
