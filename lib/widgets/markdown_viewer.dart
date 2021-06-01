import 'dart:ui';
import 'package:draw/draw.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'website_viewer.dart';
import 'package:gwa_app/utils/util_functions.dart';
import 'package:markdown/markdown.dart' as md;

//TODO: This doesn't handle spoilers ('>!...<' I think). Try to extend it.
class MarkdownViewer extends StatelessWidget {
  final String text;
  final Color bodyTextColor;
  final double bodyTextFontSize;
  final Color tableBorderColor;
  final BoxDecoration blockQuoteDecoration;
  final BoxDecoration horizontalRuleDecoration;
  final bool fromLibrary;

  const MarkdownViewer({
    Key key,
    @required this.text,
    this.bodyTextColor,
    this.bodyTextFontSize,
    this.tableBorderColor,
    this.blockQuoteDecoration,
    this.horizontalRuleDecoration,
    @required this.fromLibrary,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    /*TODO: For now I'm handling &amp; myself since it isn't handled by the
       package, should find a better way to handle it. Same thing for &nbsp;,
       &lt;, &gt; and &#x200B;. I'm just replacing it with a space character (and not
       very efficiently). */
    String markdown = this.text.replaceAll('&amp;', '&');
    markdown = markdown.replaceAll('&nbsp;', ' ');
    markdown = markdown.replaceAll('&lt;', '<');
    markdown = markdown.replaceAll('&gt;', '>');
    markdown = markdown.replaceAll(r'&#x200B;', '\u{200B}');

    return Container(
      child: MarkdownBody(
        data: markdown,
        onTapLink: (text, url, title) {
          if (url.contains('reddit.com/r/gonewildaudio/comments/')) {
            String fullname = url.substring(
              url.indexOf('comments/') + 9,
            );
            fullname = fullname.substring(0, fullname.indexOf('/'));
            pushSubmissionPageWithReturnData(context, fullname, false);
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => WebsiteViewer(
                  url: url,
                ),
              ),
            );
          }
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
        builders: {
          "username": RedditUserMarkdownElementBuilder(
              onTap: (String username, String text) {
            popSubmissionPageWithData(context,
                query: 'author:$username',
                sort: Sort.newest,
                timeFilter: TimeFilter.all);
          }),
        },
        inlineSyntaxes: [
          RedditUserInlineSyntax(),
        ],
      ),
    );
  }
}

class RedditUserInlineSyntax extends md.InlineSyntax {
  RedditUserInlineSyntax({
    String pattern = r'u\/(\w+)',
  }) : super(pattern);

  @override
  bool onMatch(md.InlineParser parser, Match match) {
    final noUserPrefix = match.group(0);

    md.Element element = md.Element.text("username", noUserPrefix);

    parser.addNode(element);
    return true;
  }
}

// FIXME: Handle usernames that are encased with hyperlink syntax.
class RedditUserMarkdownElementBuilder extends MarkdownElementBuilder {
  final void Function(String username, String text) onTap;

  RedditUserMarkdownElementBuilder({this.onTap});

  @override
  Widget visitElementAfter(md.Element element, TextStyle preferredStyle) {
    String username = element.textContent.substring(2);
    return RichText(
        text: TextSpan(
      text: element.textContent,
      style: TextStyle(color: Colors.deepPurpleAccent),
      recognizer: new TapGestureRecognizer()
        ..onTap = () => onTap.call(username, element.textContent),
    ));
  }
}