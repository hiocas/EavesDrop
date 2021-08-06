import 'dart:ui';
import 'package:draw/draw.dart' hide Visibility;
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'website_viewer.dart';
import 'package:eavesdrop/utils/util_functions.dart';
import 'package:markdown/markdown.dart' as md;

//TODO: This doesn't handle spoilers ('>!...<' I think). Try to extend it.
class MarkdownViewer extends StatelessWidget {
  final String text;
  final Color bodyTextColor;
  final double bodyTextFontSize;
  final TextStyle subtitle1TextStyle;
  final Color tableBorderColor;
  final BoxDecoration blockQuoteDecoration;
  final BoxDecoration horizontalRuleDecoration;

  // This determines if the MarkdownViewer is in a popup card.
  final bool inPopupCard;

  const MarkdownViewer({
    Key key,
    @required this.text,
    this.bodyTextColor,
    this.bodyTextFontSize,
    this.subtitle1TextStyle,
    this.tableBorderColor,
    this.blockQuoteDecoration,
    this.horizontalRuleDecoration,
    @required this.inPopupCard,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    /*TODO: For now I'm handling &lt;, &gt; myself since it isn't handled by the
       package, should find a better way to handle it (custom inline syntax
       won't work since it needs to be read as a markdown for the quote effect. */
    String markdown = this.text;
    markdown = markdown.replaceAll('&lt;', '<');
    markdown = markdown.replaceAll('&gt;', '>');

    return Container(
      child: MarkdownBody(
        data: markdown,
        onTapLink: (text, url, title) {
          if (url.contains('reddit.com/r/gonewildaudio/comments/')) {
            String fullname = SubmissionRef.idFromUrl(url);
            pushSubmissionPageWithReturnData(context, fullname);
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
                headline5:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                headline6: TextStyle(color: Colors.grey[200]),
                subtitle1: subtitle1TextStyle ??
                    TextStyle(
                        color: Colors.grey[300],
                        fontSize: 18,
                        fontWeight: FontWeight.w500),
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
                    width: 2.0,
                    color: Colors.black26,
                  ),
                ),
              ),
        ),
        builders: {
          "username": RedditUserMarkdownElementBuilder(
              onTap: (String username, String text) {
            /* FIXME: Not sure if popping here does any harm. I'm doing this
                so that clicking the user from the Details button on
                SubmissionPage could also query the user. */
            if (inPopupCard) {
              Navigator.pop(context);
            }
            popSubmissionPageWithData(context,
                query: 'author:$username',
                sort: Sort.newest,
                timeFilter: TimeFilter.all);
          }),
          "spoiler": RedditSpoilerMarkdownElementBuilder(),
        },
        inlineSyntaxes: [
          RedditUserInlineSyntax(),
          RedditSpoilerSyntax(),
          ZeroWidthSpaceSyntax(),
          NbspSyntax(),
          AmpersandSyntax(),
        ],
      ),
    );
  }
}

class RedditUserInlineSyntax extends md.InlineSyntax {
  RedditUserInlineSyntax({
    String pattern = r'u\/([\w-]+)',
  }) : super(pattern);

  @override
  bool onMatch(md.InlineParser parser, Match match) {
    final noUserPrefix = match.group(0);
    md.Element element = md.Element.text("username", noUserPrefix);
    parser.addNode(element);
    return true;
  }
}

class AmpersandSyntax extends md.InlineSyntax {
  AmpersandSyntax({
    String pattern = r'(&amp;)',
  }) : super(pattern);

  @override
  bool onMatch(md.InlineParser parser, Match match) {
    md.Element element = md.Element.text("&amp;", "&");
    parser.addNode(element);
    return true;
  }
}

class NbspSyntax extends md.InlineSyntax {
  NbspSyntax({
    String pattern = r'(&amp;nbsp;)|(&nbsp;)',
  }) : super(pattern);

  @override
  bool onMatch(md.InlineParser parser, Match match) {
    md.Element element = md.Element.text("&nbsp;", "\u{00A0}");
    parser.addNode(element);
    return true;
  }
}

class ZeroWidthSpaceSyntax extends md.InlineSyntax {
  ZeroWidthSpaceSyntax({
    String pattern = r'(&amp;#x200B;)|(&#x200B;)',
  }) : super(pattern);

  @override
  bool onMatch(md.InlineParser parser, Match match) {
    md.Element element = md.Element.text("&nbsp;", "\u{200B}");
    parser.addNode(element);
    return true;
  }
}

class RedditSpoilerSyntax extends md.InlineSyntax {
  RedditSpoilerSyntax({String pattern = r'\>\!.*\!\<'}) : super(pattern);

  @override
  bool onMatch(md.InlineParser parser, Match match) {
    final spoiler = match.group(0);
    md.Element element =
        md.Element.text("spoiler", spoiler.substring(2, spoiler.length - 2));
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

class RedditSpoilerMarkdownElementBuilder extends MarkdownElementBuilder {
  RedditSpoilerMarkdownElementBuilder();

  @override
  Widget visitElementAfter(md.Element element, TextStyle preferredStyle) {
    return RedditSpoiler(element: element);
  }
}

class RedditSpoiler extends StatefulWidget {
  final md.Element element;

  const RedditSpoiler({Key key, @required this.element}) : super(key: key);

  @override
  _RedditSpoilerState createState() => _RedditSpoilerState();
}

class _RedditSpoilerState extends State<RedditSpoiler> {
  bool _visible = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() {
        _visible = !_visible;
      }),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6.0),
          color: _visible
              ? Colors.black26
              : Theme.of(context).errorColor.withOpacity(0.7),
        ),
        child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: Text(
            widget.element.textContent,
            style: TextStyle(
                color: _visible ? Colors.grey[300] : Colors.transparent),
          ),
        ),
      ),
    );
  }
}
