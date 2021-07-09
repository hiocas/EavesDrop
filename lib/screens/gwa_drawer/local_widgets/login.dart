import 'package:flutter/material.dart';
import 'package:eavesdrop/services/reddit_client_service.dart';
import 'package:eavesdrop/utils/util_functions.dart';
import 'package:eavesdrop/widgets/gradient_title_appbar.dart';

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
  bool eligible = false;
  TextStyle _textStyle = TextStyle(color: Colors.white);
  double _spacing = 15.0;

  Widget _makeLoggedInView() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Log out from '
          'u/${widget.redditClientService.displayName}.',
          style: _textStyle,
        ),
        SizedBox(
          height: _spacing,
        ),
        ElevatedButton.icon(
          icon: Icon(Icons.logout),
          label: Text(
            'Logout',
          ),
          style: ButtonStyle(
              elevation: MaterialStateProperty.all(15.0),
              backgroundColor:
                  MaterialStateProperty.all(Theme.of(context).primaryColor)),
          onPressed: () async {
            await widget.redditClientService.logout();
            popLogin(context, redirect: true);
            Navigator.pop(context);
          },
        ),
        SizedBox(
          height: _spacing,
        ),
        Text(
          "When logging out, you will stop seeing post preview thumbnails "
          "(see why in \"Help\").",
          textAlign: TextAlign.center,
          style: _textStyle,
        ),
        SizedBox(
          height: _spacing,
        ),
        Divider(
          thickness: 3.0,
          color: Colors.black26,
        ),
        SizedBox(
          height: _spacing,
        ),
        Text(
          "Change your account settings to be able to see post preview "
          "thumbnails.",
          textAlign: TextAlign.center,
          style: _textStyle,
        ),
        SizedBox(
          height: _spacing,
        ),
        ElevatedButton.icon(
          icon: Icon(Icons.settings_applications_outlined),
          label: Text('Change Account Settings'),
          onPressed: eligible
              ? null
              : () async {
                  showDialog<String>(
                    barrierDismissible: false,
                    context: context,
                    builder: (BuildContext context) => AlertDialog(
                      backgroundColor: Theme.of(context).backgroundColor,
                      elevation: 25.0,
                      title: Text(
                        'Change Your Reddit Preferences',
                        style: _textStyle,
                      ),
                      content: const Text(
                        "This will change your reddit account preferences!\n"
                        "If you're logged-in with your main reddit account, "
                        "or one that you actively use, it is recommended "
                        "you log out of it and create a new account for "
                        "this app.\n"
                        "You can also manually change your account settings. "
                        "See how in \"Help\".",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14.0,
                        ),
                      ),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text(
                            "I'll Change It Myself",
                          ),
                        ),
                        TextButton(
                          onPressed: () async {
                            Navigator.pop(context);
                            await widget.redditClientService
                                .setEligiblePreferences();
                            setState(() {});
                          },
                          child: Text(
                            'Change It!',
                          ),
                        ),
                      ],
                    ),
                  );
                },
          style: ButtonStyle(
              elevation: MaterialStateProperty.all(15.0),
              backgroundColor:
                  MaterialStateProperty.all(Theme.of(context).primaryColor)),
        ),
        SizedBox(
          height: _spacing,
        ),
        Text(
          eligible
              ? 'Your current reddit preferences allow you to view '
                  'post preview thumbnails.'
              : "Your current reddit preferences don't allow you to "
                  "view post preview thumbnails.",
          textAlign: TextAlign.center,
          style: _textStyle,
        ),
        SizedBox(
          height: _spacing,
        )
      ],
    );
  }

  Widget _makeLoggedOutView() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          "Log in to see post preview thumbnails.",
          style: _textStyle,
        ),
        SizedBox(
          height: _spacing,
        ),
        ElevatedButton.icon(
          icon: Icon(Icons.login),
          label: Text('Login'),
          style: ButtonStyle(
              elevation: MaterialStateProperty.all(15.0),
              backgroundColor:
                  MaterialStateProperty.all(Theme.of(context).primaryColor)),
          onPressed: () async {
            widget.redditClientService.login(onClientAllows: () async {
              var eligible =
                  await widget.redditClientService.eligiblePreferences();
              if (eligible) {
                popLogin(context, redirect: true);
                Navigator.pop(context);
              } else {
                showDialog<String>(
                  barrierDismissible: false,
                  context: context,
                  builder: (BuildContext context) => AlertDialog(
                    backgroundColor: Theme.of(context).backgroundColor,
                    elevation: 25.0,
                    title: Text(
                      'Change Your Reddit Preferences',
                      style: _textStyle,
                    ),
                    content: const Text(
                      "Your current reddit account preferences "
                      "won't allow you to see post preview "
                      "thumbnails."
                      "\n\nYou can change this yourself (see how in the Help "
                      "page -> \"How do I manually set my Reddit account "
                      "preferences?\") or this can be changed now "
                      "programmatically."
                      "\n\nYou can still use this app without this "
                      "setting on in your preferences.",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14.0,
                      ),
                    ),
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
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Remember me: ',
              style: _textStyle,
            ),
            Theme(
              child: Checkbox(
                  tristate: false,
                  value: widget.redditClientService.rememberClient,
                  onChanged: (value) {
                    setState(() {
                      widget.redditClientService.rememberClient = value;
                    });
                  }),
              data: ThemeData(
                  accentColor: Theme.of(context).accentColor,
                  unselectedWidgetColor: Colors.white),
            ),
          ],
        ),
        Divider(
          thickness: 3.0,
          color: Colors.black26,
        ),
        SizedBox(
          height: _spacing,
        ),
        Text(
          "It is recommended that you make a new reddit account specifically "
          "for this app.",
          textAlign: TextAlign.center,
          style: _textStyle,
        ),
        SizedBox(
          height: _spacing,
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GradientTitleAppBar(
        context,
        title: widget.redditClientService.loggedIn ? 'Log Out' : 'Log In',
        elevation: 15.0,
      ),
      backgroundColor: Theme.of(context).backgroundColor,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Material(
            elevation: 15.0,
            color: Theme.of(context).backgroundColor,
            borderRadius: BorderRadius.circular(32.0),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: FutureBuilder<bool>(
                  future: widget.redditClientService.eligiblePreferences(),
                  builder: (context, futureEligible) {
                    if (!futureEligible.hasData)
                      return CircularProgressIndicator();
                    eligible = futureEligible.data;
                    if (widget.redditClientService.loggedIn) {
                      return _makeLoggedInView();
                    }
                    return _makeLoggedOutView();
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
