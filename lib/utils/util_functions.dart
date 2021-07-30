import 'package:html/parser.dart';
import 'package:draw/draw.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import 'package:eavesdrop/models/audio_launch_options.dart';
import 'package:eavesdrop/models/placeholders_options.dart';
import 'package:eavesdrop/screens/gwa_drawer/local_widgets/login.dart';
import 'package:eavesdrop/screens/submission_page/submission_page.dart';
import 'package:eavesdrop/services/reddit_client_service.dart';

import '../main.dart';

String getTagName(String tag) {
  if (tag.startsWith('{author:}'))
    return tag.substring(9);
  else
    return tag;
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

/// Use this function when you want to push a SubmissionPage. It'll handle
/// returning the query data from it (if it exists).
Future<void> pushSubmissionPageWithReturnData(
    BuildContext context, String submissionFullname) async {
  final result = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) =>
              SubmissionPage(submissionFullname: submissionFullname)));
  if (result != null) {
    Navigator.pushNamedAndRemoveUntil(
        context,
        ExtractArgumentsSubmissionList.routeName,
        (Route<dynamic> route) => false,
        arguments: SubmissionListArguments(
            result['query'], result['sort'], result['timeFilter']));
  }
}

/// Use this function when you want to replace the current rout and push a
/// SubmissionPage. It'll handle returning the query data from it
/// (if it exists).
void pushReplacementSubmissionPageWithReturnData(
    BuildContext context, String submissionFullname) async {
  final result = await Navigator.pushReplacement(
      context,
      MaterialPageRoute(
          builder: (context) =>
              SubmissionPage(submissionFullname: submissionFullname)));
  if (result != null) {
    Navigator.pushNamedAndRemoveUntil(
        context,
        ExtractArgumentsSubmissionList.routeName,
        (Route<dynamic> route) => false,
        arguments: SubmissionListArguments(
            result['query'], result['sort'], result['timeFilter']));
  }
}

/// Use this function when you want to pop SubmissionList and return data with
/// it.
void popSubmissionPageWithData(BuildContext context,
    {String query, Sort sort, TimeFilter timeFilter}) {
  Navigator.pop(
      context, {'query': query, 'sort': sort, 'timeFilter': timeFilter});
}

/// Pushes [Login] with a [RedditClientService] so that later when it pops with
/// [popLogin] the [HomeScaffold] will be updated.
void pushLogin(BuildContext context,
    {RedditClientService redditClientService}) async {
  final redirect = await Navigator.push(
      context,
      CupertinoPageRoute(
          builder: (context) => Login(
                redditClientService: redditClientService,
              )));
  if (redirect != null && redirect) {
    Navigator.pushNamedAndRemoveUntil(
        context, RedirectToHome.routeName, (Route<dynamic> route) => false);
  }
}

/// Pops [Login] and redirect [HomeScaffold] to [Home] based on [redirect].
/// To use this make sure you pushed [Login] with [pushLogin].
void popLogin(BuildContext context, {bool redirect}) {
  Navigator.pop(context, redirect);
}

String audioLaunchOptionToString(AudioLaunchOptions audioLaunchOptions) {
  switch (audioLaunchOptions) {
    case AudioLaunchOptions.ChromeCustomTabs:
      return 'Chrome Custom Tabs';
    case AudioLaunchOptions.WebView:
      return 'WebView';
    case AudioLaunchOptions.EavesDrop:
      return 'EavesDrop';
  }
  return '';
}

String placeholdersOptionsToString(PlaceholdersOptions placeholdersOptions) {
  switch (placeholdersOptions) {
    case PlaceholdersOptions.Abstract:
      return 'Abstract';
    case PlaceholdersOptions.Gradients:
      return 'Gradients';
    case PlaceholdersOptions.GoneWildAudioLogo:
      return 'GoneWildAudioLogo';
  }
  return '';
}

Color darken(Color color, [double amount = .1]) {
  assert(amount >= 0 && amount <= 1);

  final hsl = HSLColor.fromColor(color);
  final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));

  return hslDark.toColor();
}

Color lighten(Color color, [double amount = .1]) {
  assert(amount >= 0 && amount <= 1);

  final hsl = HSLColor.fromColor(color);
  final hslLight = hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0));

  return hslLight.toColor();
}

Future<String> getAudioSource(String url) async {
  if (url.contains('soundgasm.net')) {
    //FIXME: This is kinda scuffed.
    var response = await http.Client().get(Uri.parse(url));
    var document = parse(response.body);
    var html = document.body.innerHtml;
    var script = html.substring(html.indexOf(r'$(document)'));
    script = script.substring(script.indexOf(r'm4a: "') + 6);
    return Future.value(script.substring(0, script.indexOf('"')));
  }
  return Future.value('');
}
