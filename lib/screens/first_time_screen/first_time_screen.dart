import 'package:flutter/material.dart';
import 'package:gwa_app/services/reddit_client_service.dart';
import 'package:gwa_app/states/global_state.dart';
import 'package:gwa_app/utils/util_functions.dart' show pushLogin;
import 'package:gwa_app/widgets/gradient_title_appbar.dart';
import 'package:gwa_app/widgets/markdown_viewer.dart';
import 'package:provider/provider.dart';

class FirstTimeScreen extends StatelessWidget {
  const FirstTimeScreen({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GradientTitleAppBar(
        context,
        // FIXME: New Name Flag.
        title: 'Welcome!',
      ),
      backgroundColor: Theme.of(context).backgroundColor,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Material(
            color: Theme.of(context).backgroundColor,
            elevation: 15.0,
            borderRadius: BorderRadius.circular(32.0),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Welcome to the GoneWildAudio Browser App!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 22.0),
                  ),
                  SizedBox(height: 15.0),
                  MarkdownViewer(
                    text: "Some things before you start:"
                        "\n\n* You don't need to log in with your Reddit "
                        "account, just know that some app features (like seeing "
                        "post preview thumbnails and upvoting posts) do require "
                        "one. These features are completely optional though."
                        "\n\n* If you do choose to log in, it's recommended that "
                        "you make a new Reddit account for this app, or use one "
                        "that's not very important to you.\nYou can read more "
                        "about this in the Help page -> \"Why do I need to log "
                        "into my Reddit account?\""
                        // FIXME: Where to contribute flag
                        "\n\n* This project is open sourced, so if you see "
                        "anything here that you think you can improve or help with "
                        "(doesn't have to be programming related!) please consider "
                        "contributing on GitHub! :)",
                    fromLibrary: false,
                    inPopupCard: false,
                    bodyTextFontSize: 15.0,
                    bodyTextColor: Colors.white,
                  ),
                  SizedBox(height: 15.0),
                  Divider(thickness: 1.0, color: Colors.black26),
                  SizedBox(height: 15.0),
                  Text('Log in?',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18.0)),
                  SizedBox(height: 15.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text('Nope!'),
                        style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(
                                Theme.of(context).primaryColor)),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          final RedditClientService _redditClientService =
                              Provider.of<GlobalState>(context, listen: false)
                                  .redditClientService;
                          pushLogin(context,
                              redditClientService: _redditClientService);
                        },
                        child: Text('Ok!'),
                        style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(
                                Theme.of(context).primaryColor)),
                      )
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}