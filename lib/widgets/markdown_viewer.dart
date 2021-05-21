import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:url_launcher/url_launcher.dart';

//TODO: This doesn't handle '&gt;'. Try to extend it.
class MarkdownViewer extends StatelessWidget {
  final String text;
  final Color bodyTextColor;
  final double bodyTextFontSize;
  final Color tableBorderColor;

  const MarkdownViewer({
    Key key,
    @required this.text,
    this.bodyTextColor,
    this.bodyTextFontSize,
    this.tableBorderColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: MarkdownBody(
        data: this.text,
        onTapLink: (text, url, title) {
          launch(url);
        },
        styleSheet: MarkdownStyleSheet.fromTheme(ThemeData(
            dividerColor: this.tableBorderColor ?? Colors.grey[600],
            textTheme: Theme.of(context).textTheme.copyWith(
                    bodyText2: TextStyle(
                  fontSize: this.bodyTextFontSize ?? 15.0,
                  color: this.bodyTextColor ?? Colors.grey[400],
                )))),
      ),
    );
  }
}
