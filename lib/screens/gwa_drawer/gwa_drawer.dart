import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gwa_app/screens/gwa_drawer/local_widgets/open_submission_screen.dart';

class GwaDrawer extends StatelessWidget {
  const GwaDrawer({
    Key key,
    @required this.fromLibrary,
  }) : super(key: key);

  // TODO: Figure out if it's needed here.
  final bool fromLibrary;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Material(
        color: Theme.of(context).primaryColor,
        child: ListView(
          itemExtent: 50.0,
          children: [
            DrawerHeader(child: Text('GoneWildAudio App')),
            ListTile(
              title: Text('Settings'),
            ),
            ListTile(
              title: Text('Open Post'),
              onTap: () => Navigator.push(
                  context,
                  CupertinoPageRoute(
                    builder: (context) => OpenSubmissionScreen(fromLibrary: fromLibrary,),
                  )),
            ),
            ListTile(
              title: Text('About'),
            ),
          ],
        ),
      ),
    );
  }
}
