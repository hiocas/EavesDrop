import 'dart:core';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

//THIS ISN'T ALL MY CODE I COPIED SOME OF IT
class _LinkTextSpan extends TextSpan {
  _LinkTextSpan({TextStyle style, String url, String text})
      : super(
          style: style,
          text: text ?? url,
          recognizer: new TapGestureRecognizer()..onTap = () => print(url),
        );
}

@Deprecated('Replaced with markdown_viewer')
class SubmissionSelftextViewer extends StatelessWidget {
  final String text;

  SubmissionSelftextViewer({@required this.text});

  int _isTextLink(String input, int i) {
    // Start Checking for this pattern: [...](...) - I called this a "text link"...
    if ((input.length - i > 7) && (input[i] == '[' && input[i + 1] != ']')) {
      var closeBr = false, closeP = false, lastIndex;
      for (var j = i + 2; j < input.length - 1; j++) {
        if (input[j] == ']') {
          closeBr = true;
          if (input[j + 1] != '(') {
            break;
          }
        } else if (input[j] != '(' && input[j + 1] == ')') {
          closeP = true;
          lastIndex = j + 2;
          break;
        }
      }
      if (closeBr && closeP) {
        return lastIndex;
      }
    }
    return i;
  }

  //TODO: Implement bolded TextLink detection.
  //TODO: Implement slanted text detection.

  int _isBold(String input, int i) {
    // Start checking for this pattern **...** - Bolded text.
    if ((input.length - i > 4) &&
        (input[i] == '*' && input[i + 1] == '*' && input[i + 2] != '*')) {
      var closeAs = false, lastIndex;
      for (int j = i + 3; j < input.length - 1; j++) {
        if (input[j] == '*' && input[j + 1] == '*') {
          closeAs = true;
          lastIndex = j + 2;
          break;
        }
      }
      if (closeAs) {
        return lastIndex;
      }
    }
    return i;
  }

  //TODO: Implement regular link detection.
  bool _isLink(String input, int i) {
    var exp = RegExp(
      r"""\b((?:https?://|www\d{0,3}[.]|[a-z0-9.\-]+[.][a-z]{2,4}/)(?:[^\s()<>]+|\(([^\s()<>]+|(\([^\s()<>]+\)))*\))+(?:\(([^\s()<>]+|(\([^\s()<>]+\)))*\)|[^\s`!()\[\]{};:'\".,<>?«»“”‘’]))""",
      caseSensitive: false,
    );
    return exp.hasMatch(input);
  }

  @override
  Widget build(BuildContext context) {
    final _style =
        Theme.of(context).textTheme.bodyText2.copyWith(color: Colors.grey[400]);
    if (text.length > 0) {
      //This is an int which represent the last recognized special pattern (bolded text or text link) so that we can add the other none special text to the text span.
      int pedal = 0;
      List<TextSpan> span = [];
      for (int i = 0; i < text.length; i++) {
        var isTextLink = _isTextLink(text, i);
        var isBold = _isBold(text, i);
        //First check if the text is a text link.
        if (isTextLink != i) {
          span.add(new TextSpan(text: text.substring(pedal, i), style: _style));
          var textLink = text.substring(i, isTextLink);
          var word = textLink.substring(1, textLink.indexOf(']'));
          var link = textLink.substring(
              textLink.indexOf('(') + 1, textLink.length - 1);
          span.add(new _LinkTextSpan(
              text: word,
              url: link,
              style: _style.copyWith(color: Colors.blue)));
          i = isTextLink;
          pedal = isTextLink;
          //Then check if the text is a bolded text.
        } else if (isBold != i) {
          span.add(new TextSpan(text: text.substring(pedal, i), style: _style));
          var textBold = text.substring(i, isBold);
          var bold = textBold.substring(2, textBold.length - 2);
          span.add(
            new TextSpan(
              text: bold,
              style: _style.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          );
          i = isBold;
          pedal = isBold;
        }
      }
      span.add(new TextSpan(
          text: text.substring(pedal - 1, text.length - 1), style: _style));

      if (span.length > 0) {
        return new RichText(
          text: new TextSpan(text: '', children: span),
        );
      } else {
        return new Text(text);
      }
    } else
      return new Text(
        'Post has no body text.',
        style: _style,
      );
  }
}
