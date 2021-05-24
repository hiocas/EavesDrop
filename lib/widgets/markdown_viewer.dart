import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:url_launcher/url_launcher.dart';

//TODO: This doesn't handle spoilers ('>!...<' I think). Try to extend it.
class MarkdownViewer extends StatelessWidget {
  final String text;
  final Color bodyTextColor;
  final double bodyTextFontSize;
  final Color tableBorderColor;
  final BoxDecoration blockQuoteDecoration;
  final BoxDecoration horizontalRuleDecoration;

  const MarkdownViewer({
    Key key,
    @required this.text,
    this.bodyTextColor,
    this.bodyTextFontSize,
    this.tableBorderColor,
    this.blockQuoteDecoration,
    this.horizontalRuleDecoration,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    /*TODO: For now I'm handling &amp; myself since it isn't handled by the
       package, should find a better way to handle it. Same thing for &nbsp;,
       &lt; and &gt;. I'm just replacing it with a space character (and not
       very efficiently). */
    String markdown = this.text.replaceAll('&amp;', '&');
    markdown = markdown.replaceAll('&nbsp;', ' ');
    markdown = markdown.replaceAll('&lt;', '<');
    markdown = markdown.replaceAll('&gt;', '>');

    return Container(
      child: MarkdownBody(
        data: markdown,
        onTapLink: (text, url, title) {
          launch(url);
        },
        styleSheet: MarkdownStyleSheet.fromTheme(ThemeData(
            dividerColor: this.tableBorderColor ?? Colors.grey[600],
            textTheme: Theme.of(context).textTheme.copyWith(
                    bodyText2: TextStyle(
                  fontSize: this.bodyTextFontSize ?? 15.0,
                  color: this.bodyTextColor ?? Colors.grey[400],
                )))).copyWith(
          blockquoteDecoration: this.blockQuoteDecoration ??
              BoxDecoration(
                border: Border(
                    left: BorderSide(width: 2.0, color: Colors.blueAccent)),
                color: Theme.of(context).backgroundColor,
              ),
          horizontalRuleDecoration: this.horizontalRuleDecoration ??
              BoxDecoration(
                border: Border(
                  top: BorderSide(
                    width: 5.0,
                    color: Theme.of(context).dividerColor,
                  ),
                ),
              ),
        ),
      ),
    );
  }
}
