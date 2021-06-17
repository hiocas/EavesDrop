import 'package:flutter/material.dart';
import 'package:gwa_app/services/reddit_client_service.dart';
import 'package:gwa_app/utils/util_functions.dart';

class Login extends StatefulWidget {
  final RedditClientService redditClientService;

  const Login({
    Key key,
    @required this.redditClientService,
  }) : super(key: key);

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.redditClientService.loggedIn ? 'Log Out' : 'Log In'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: FutureBuilder<bool>(
            future: widget.redditClientService.eligiblePreferences(),
            builder: (context, futureEligible) {
              if (!futureEligible.hasData)
                return CircularProgressIndicator();
              bool eligible = futureEligible.data;
              if (widget.redditClientService.loggedIn) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Log out from '
                      'u/${widget.redditClientService.displayName}',
                    ),
                    ElevatedButton(
                      child: Text('Logout'),
                      onPressed: () {
                        widget.redditClientService.logout();
                        popLogin(context, redirect: true);
                        Navigator.pop(context);
                      },
                    ),
                    Text(eligible
                        ? 'Your current reddit preferences allow you to view '
                            'post preview thumbnails.'
                        : "Your current reddit preferences don't allow you to "
                            "view post preview thumbnails."),
                    eligible
                        ? Container()
                        : ElevatedButton(
                            child: Text('Change Account Settings'),
                            onPressed: () async {
                              await widget.redditClientService
                                  .setEligiblePreferences();
                              setState(() {});
                            },
                          ),
                  ],
                );
              }
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ElevatedButton(
                    child: Text('Login'),
                    onPressed: () async {
                      widget.redditClientService.login(
                          onClientAllows: () async {
                        var eligible = await widget.redditClientService
                            .eligiblePreferences();
                        if (eligible) {
                          popLogin(context, redirect: true);
                          Navigator.pop(context);
                        } else {
                          showDialog<String>(
                            barrierDismissible: false,
                            context: context,
                            builder: (BuildContext context) => AlertDialog(
                              title:
                                  const Text('Change Your Reddit Preferences'),
                              /* TODO: Add a tutorial for changing the
                                  preferences so that the user could see
                                  submission preview thumbnails in GwaDrawer. */
                              content: const Text(
                                  "Your current reddit account preferences "
                                  "won't allow you to see post preview "
                                  "thumbnails. You can change this yourself "
                                  "(see how in the app drawer) or this can "
                                  "be changed now programmatically.\n"
                                  "You can still use this app without this "
                                  "setting on in your preferences."),
                              actions: <Widget>[
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    popLogin(context, redirect: true);
                                    Navigator.pop(context);
                                  },
                                  child: const Text("I'll Change It Myself"),
                                ),
                                TextButton(
                                  onPressed: () async {
                                    await widget.redditClientService
                                        .setEligiblePreferences();
                                    Navigator.pop(context);
                                    popLogin(context, redirect: true);
                                    Navigator.pop(context);
                                  },
                                  child: const Text('Change It For Me'),
                                ),
                              ],
                            ),
                          );
                        }
                      });
                    },
                  ),
                  Text(
                    "Log in to see post preview thumbnails.\n\n"
                    "It is recommended that you make a new account for this "
                    "app.",
                    textAlign: TextAlign.center,
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
