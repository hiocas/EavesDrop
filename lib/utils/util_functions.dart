import 'package:draw/draw.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:gwa_app/screens/submission_page/submission_page.dart';

import '../main.dart';

class UtilFunctions {
  //TODO: Implement per tag icons.
  //Use the live templates "tagt" and tagt2.
  static List tagChipAvatar(String tag) {
    if (tag.contains(RegExp('mf4|fm4', caseSensitive: false)))
      return [Text('\u{1f46b}'), 1];
    else if (tag.contains(RegExp('f4', caseSensitive: false)))
      return [Text('\u{1f469}'), 1];
    else if (tag.contains(RegExp('m4', caseSensitive: false)))
      return [Text('\u{1f9d1}'), 1];
    else if (tag.contains(RegExp('fingering', caseSensitive: false)))
      return [Text('\u{1f595}'), 1];
    else if (tag.contains(
        RegExp('neko|catgirl|cat girl|purr|nyaa', caseSensitive: false)))
      return [
        Image.asset(
          'lib/assets/images/headband.png',
          width: 18,
          height: 18,
        ),
        1
      ];
    else if (tag.contains(RegExp('kiss', caseSensitive: false)))
      return [Text('\u{1f48b}'), 1];
    else if (tag.contains(RegExp('script', caseSensitive: false)))
      return [Text('\u{1f4c3}'), 1];
    else if (tag.contains(RegExp('(ft)([^a-z])', caseSensitive: false)))
      return [Text('\u{1f31f}'), 1];
    else if (tag.contains(
        RegExp('hypnosis|((mind)(.*)(control))', caseSensitive: false)))
      return [Text('\u{1f441}\u{fe0f}\u{200d}\u{1f5e8}\u{fe0f}'), 1];
    else if (tag.contains(RegExp('asmr', caseSensitive: false)))
      return [Text('\u{1f399}'), 1];
    else if (tag.contains(RegExp('((l)(-| )(bombs))', caseSensitive: false)))
      return [Text('\u{1f496}'), 1];
    else if (tag.contains(RegExp('blowjob', caseSensitive: false)))
      return [
        Row(children: [
          Text('\u{1f346}', style: TextStyle(fontSize: 12)),
          Text('\u{1f445}', style: TextStyle(fontSize: 12))
        ]),
        2
      ];
    else if (tag.contains(
        RegExp('(?<=cum)(.*)(in|on)(.*)(?=mouth)', caseSensitive: false)))
      return [
        Row(children: [
          Text('\u{1f4a6}', style: TextStyle(fontSize: 12)),
          Text('\u{1f444}', style: TextStyle(fontSize: 12))
        ]),
        2
      ];
    //TODO(Design): Maybe rethink this one.
    else if (tag
        .contains(RegExp('(?<=enemies)(.*)(?=lovers)', caseSensitive: false)))
      return [
        Row(children: [
          Text('\u{2764}', style: TextStyle(fontSize: 12)),
          Text('\u{1fa79}', style: TextStyle(fontSize: 12))
        ]),
        2
      ];
    else if (tag.contains(RegExp('creampie', caseSensitive: false)))
      return [
        Row(children: [
          Text('\u{1f4a6}', style: TextStyle(fontSize: 12)),
          Text('\u{270c}', style: TextStyle(fontSize: 12))
        ]),
        2
      ];
    else
      return [Icon(Icons.info), 1];
  }
}

Future<Map<String, dynamic>> parseJsonFromAssets(String assetsPath) {
  return rootBundle.loadString(assetsPath).then((value) => jsonDecode(value));
}

String getUrlTitle(String url) {
  if (url.contains('soundgasm')) {
    return url.substring(url.lastIndexOf('/') + 1).replaceAll('-', ' ');
  }
  return url;
}

void pushSubmissionPageWithReturnData(
    BuildContext context, String submissionFullname, bool fromLibrary) async {
  final result = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => SubmissionPage(
              submissionFullname: submissionFullname,
              fromLibrary: fromLibrary)));
  if (result != null) {
    Navigator.pushReplacementNamed(
        context, ExtractArgumentsSubmissionList.routeName,
        arguments: SubmissionListArguments(
            result['query'], result['sort'], result['timeFilter']));
  }

}

void popSubmissionPageWithDate(
    BuildContext context, {String query, Sort sort, TimeFilter timeFilter}) {
  Navigator.pop(
      context, {'query': query, 'sort': sort, 'timeFilter': timeFilter});
}
