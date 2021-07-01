import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gwa_app/services/reddit_client_service.dart';
import 'package:gwa_app/utils/util_functions.dart';
import 'package:gwa_app/states/global_state.dart';
import 'package:gwa_app/widgets/GwaGradientShaderMask.dart';
import 'package:provider/provider.dart';
import 'local_widgets/all_local_widgets.dart';

class GwaDrawer extends StatelessWidget {
  const GwaDrawer({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    RedditClientService _redditClientService =
        Provider.of<GlobalState>(context, listen: false).redditClientService;
    return SafeArea(
      child: ClipRRect(
        borderRadius: BorderRadius.only(topRight: Radius.circular(22.0)),
        clipBehavior: Clip.antiAliasWithSaveLayer,
        child: Drawer(
          elevation: 15.0,
          child: Material(
            color: Theme.of(context).backgroundColor,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                GwaGradientShaderMask(
                  context,
                  child: ListTile(
                    visualDensity: VisualDensity.compact,
                    title: Text(
                      'GoneWildAudio App',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 24.0,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 16.0, right: 48),
                  child: Divider(
                    color: Colors.black,
                    thickness: 1.0,
                  ),
                ),
                _GwaDrawerListTile(
                  leading: _redditClientService.loggedIn
                      ? ClipOval(
                          child: Image.network(
                          _redditClientService.iconImg,
                          width: 30.0,
                          height: 30.0,
                        ))
                      : null,
                  icon: Icons.login,
                  title: _redditClientService.loggedIn
                      ? 'Account (u/${_redditClientService.displayName})'
                      : 'Log in',
                  onTap: () => pushLogin(context,
                      redditClientService: _redditClientService),
                ),
                _GwaDrawerListTile(
                  icon: Icons.import_export,
                  title: 'Open Post (Link or ID)',
                  onTap: () => Navigator.push(
                      context,
                      CupertinoPageRoute(
                        builder: (context) => OpenSubmissionScreen(),
                      )),
                ),
                _GwaDrawerListTile(
                  icon: Icons.settings,
                  title: 'Settings',
                  onTap: () => Navigator.push(
                      context,
                      CupertinoPageRoute(
                        builder: (context) => Settings(),
                      )),
                ),
                _GwaDrawerListTile(
                  icon: Icons.info,
                  title: 'About',
                ),
                _GwaDrawerListTile(
                  icon: Icons.help,
                  title: 'Help',
                  onTap: () => Navigator.push(
                      context,
                      CupertinoPageRoute(
                        builder: (context) => Help(),
                      )),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _GwaDrawerListTile extends StatelessWidget {
  const _GwaDrawerListTile({
    Key key,
    this.icon,
    this.leading,
    this.title,
    this.onTap,
  }) : super(key: key);

  final IconData icon;
  final Widget leading;
  final String title;
  final void Function() onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
        leading: leading ??
            Icon(
              icon,
              color: Colors.white,
            ),
        horizontalTitleGap: 0.0,
        title: Text(
          title,
          style: TextStyle(color: Colors.white),
        ),
        onTap: onTap);
  }
}
