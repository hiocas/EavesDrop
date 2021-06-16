import 'package:draw/draw.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class Login extends StatefulWidget {
  Login({Key key}) : super(key: key);

  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  bool error = false;
  String url = '';
  String errorText = '';
  String errorReason = '';
  String state = 'GwaApp/0.0.2';
  Reddit reddit;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Expanded(
              child: url != ''
                  ? WebView(
                      initialUrl: this.url,
                      onPageStarted: (page) {
                        print('Page: $page');
                        loadPageStart(page);
                      },
                    )
                  : Container(
                      child: Center(
                        child: this.error
                            ? Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Text(this.errorText + ' '),
                                  Text(this.errorReason),
                                  ButtonTheme(
                                    child: RaisedButton(
                                      child: Text('Retry'),
                                      onPressed: () {
                                        Navigator.pushReplacement(context,
                                            new MaterialPageRoute(builder:
                                                (BuildContext context) {
                                          return Login();
                                        }));
                                      },
                                    ),
                                  )
                                ],
                              )
                            : Container(),
                      ),
                    ))
        ],
      ),
    );
  }

  @override
  void initState() {
    this.loginToReddit();
    super.initState();
  }

  void loadPageStart(String url) {
    if (url.toString().contains('code=')) {
      String code = Uri.parse(url).queryParameters["code"];
      this.confirmRedditLogin(code);
    } else if (url.toString().contains('error')) {
      setState(() {
        this.url = '';
        this.error = true;
        this.errorText = 'Error while authenticating, please try again.';
        this.errorReason = url.replaceAll(
            'gwa-app://cornet.dev?state=' + this.state + '&error=', '');
      });
    }
  }

  void loginToReddit() {
    reddit = Reddit.createInstalledFlowInstance(
        clientId: 'KzSdiSDWgu-XhQ',
        userAgent: 'GwaApp/0.0.2',
        redirectUri: Uri.parse('gwa-app://cornet.dev'));

    final String authUrl =
        reddit.auth.url(['*'], this.state, compactLogin: true).toString();

    setState(() {
      this.url = authUrl.toString();
    });
  }

  void confirmRedditLogin(String code) async {
    print('Code: $code');
    try {
      await reddit.auth.authorize(code);
      var me = await reddit.user.me();
      print('Me: ${me.displayName}');
    } catch (e) {
      setState(() {
        this.url = '';
        this.error = true;
        this.errorText = 'Error while authenticating! Please try again';
        this.errorReason = 'Unknown Reason';
      });
      return;
    }
    Navigator.pushReplacement(context,
        new MaterialPageRoute(builder: (BuildContext context) {
      return Scaffold(
        body: Center(
          child: Text('home'),
        ),
      );
    }));
  }
}
