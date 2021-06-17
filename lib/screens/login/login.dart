import 'package:flutter/material.dart';
import 'package:gwa_app/services/reddit_client_service.dart';
import 'package:gwa_app/utils/util_functions.dart';

class Login extends StatelessWidget {
  final RedditClientService redditClientService;

  const Login({
    Key key,
    @required this.redditClientService,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(redditClientService.loggedIn ? 'Log Out' : 'Log In'),
      ),
      body: Center(
        child: Builder(
          builder: (context) {
            if (redditClientService.loggedIn) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ElevatedButton(
                    child: Text('Logout'),
                    onPressed: () {
                      redditClientService.logout();
                      popLogin(context, redirect: true);
                      Navigator.pop(context);
                    },
                  )
                ],
              );
            }
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton(
                  child: Text('Login'),
                  onPressed: () {
                    redditClientService.login(onClientAllows: () {
                      popLogin(context, redirect: true);
                      Navigator.pop(context);
                    });
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
