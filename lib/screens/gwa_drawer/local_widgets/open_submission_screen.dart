import 'package:flutter/material.dart';
import 'package:gwa_app/states/global_state.dart';

import 'package:gwa_app/utils/util_functions.dart';
import 'package:gwa_app/widgets/gradient_title_appbar.dart';
import 'package:provider/provider.dart';

class OpenSubmissionScreen extends StatelessWidget {
  const OpenSubmissionScreen({
    Key key,
    @required this.fromLibrary,
  }) : super(key: key);

  final bool fromLibrary;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: GradientTitleAppBar(context, title: 'Open Post'),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _OpenSubmissionSection(
              fromLibrary: fromLibrary,
              title: 'Open A Post From A Link:',
              emptyError: 'No input was given.',
              getFullname: (url) async {
                var result = Future.value('');
                await Provider.of<GlobalState>(context, listen: false)
                    .populateSubmissionUrl(url: url)
                    .then((value) {
                  result = Future.value(value.fullname);
                }).catchError((e) {
                  ScaffoldMessenger.of(context)
                    ..removeCurrentSnackBar()
                    ..showSnackBar(SnackBar(
                        content: Text(
                            "Invalid link. Please input a reddit post link.")));
                  return Future.value('');
                });
                return result;
              },
            ),
            _OpenSubmissionSection(
              fromLibrary: fromLibrary,
              title: 'Open A Post From An ID:',
              emptyError: 'No input was given.',
              getFullname: (id) async {
                var result = Future.value('');
                if (id.startsWith('t3_')) id = id.substring(3);
                await Provider.of<GlobalState>(context, listen: false)
                    .populateSubmission(id: id)
                    .then((value) {
                  result = Future.value(id);
                }).catchError((e) {
                  ScaffoldMessenger.of(context)
                    ..removeCurrentSnackBar()
                    ..showSnackBar(SnackBar(
                        content: Text(
                            "Invalid ID. Please input a post ID (with or without \"t3_\").")));
                  return Future.value('');
                });
                return result;
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _OpenSubmissionSection extends StatelessWidget {
  const _OpenSubmissionSection({
    Key key,
    @required this.fromLibrary,
    @required this.title,
    this.subtitle,
    @required this.emptyError,
    @required this.getFullname,
  }) : super(key: key);

  final bool fromLibrary;
  final String title;
  final String subtitle;
  final String emptyError;
  final Future<String> Function(String) getFullname;

  @override
  Widget build(BuildContext context) {
    String data;
    return Column(
      children: [
        Text(
          title,
          style: TextStyle(color: Colors.white),
        ),
        (subtitle == null
            ? SizedBox()
            : Text(subtitle, style: TextStyle(color: Colors.white))),
        TextField(
          style: TextStyle(color: Colors.white),
          decoration: InputDecoration(
            focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Theme.of(context).accentColor)),
            enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Theme.of(context).primaryColor)),
          ),
          onChanged: (newData) {
            data = newData;
          },
        ),
        SizedBox(height: 15.0,),
        ElevatedButton.icon(
          icon: Icon(Icons.open_in_new),
          label: Text(title),
          style: ButtonStyle(
              elevation: MaterialStateProperty.all(15.0),
              backgroundColor:
              MaterialStateProperty.all(Theme.of(context).primaryColor)),
          onPressed: () async {
            if (data != null && data.isNotEmpty) {
              var fullname = await getFullname.call(data);
              if (fullname.isNotEmpty) {
                pushSubmissionPageWithReturnData(
                    context, fullname, fromLibrary);
              }
            } else {
              ScaffoldMessenger.of(context)
                ..removeCurrentSnackBar()
                ..showSnackBar(SnackBar(content: Text(emptyError)));
            }
          },
        )
      ],
    );
  }
}
