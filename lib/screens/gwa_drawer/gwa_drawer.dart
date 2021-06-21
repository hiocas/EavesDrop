import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gwa_app/services/reddit_client_service.dart';
import 'package:gwa_app/utils/util_functions.dart';
import 'package:gwa_app/states/global_state.dart';
import 'package:provider/provider.dart';
import 'local_widgets/all_local_widgets.dart';

class GwaDrawer extends StatelessWidget {
  const GwaDrawer({
    Key key,
    @required this.fromLibrary,
  }) : super(key: key);

  // TODO: Figure out if it's needed here.
  final bool fromLibrary;

  @override
  Widget build(BuildContext context) {
    RedditClientService _redditClientService =
        Provider.of<GlobalState>(context, listen: false).redditClientService;
    return Drawer(
      child: Material(
        color: Theme.of(context).primaryColor,
        child: ListView(
          itemExtent: 50.0,
          children: [
            DrawerHeader(child: Text('GoneWildAudio App')),
            ListTile(
              title: Text(_redditClientService.loggedIn
                  ? 'Account (u/${_redditClientService.displayName})'
                  : 'Log in'),
              onTap: () =>
                  pushLogin(context, redditClientService: _redditClientService),
            ),
            ListTile(
              title: Text('Open Post (Link or ID)'),
              onTap: () => Navigator.push(
                  context,
                  CupertinoPageRoute(
                    builder: (context) => OpenSubmissionScreen(
                      fromLibrary: fromLibrary,
                    ),
                  )),
            ),
            ListTile(
              title: Text('Settings'),
              onTap: () => Navigator.push(
                  context,
                  CupertinoPageRoute(
                    builder: (context) => Settings(),
                  )),
            ),
            ListTile(
              title: Text('About'),
            ),
            ListTile(
              title: Text('Help'),
              onTap: () => Navigator.push(
                  context,
                  CupertinoPageRoute(
                    builder: (context) => Help(),
                  )),
            )
          ],
        ),
      ),
    );
  }
}
