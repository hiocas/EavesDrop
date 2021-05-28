import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';
import 'package:webview_flutter/webview_flutter.dart';

// Make sure the min sdk in .android/app/build.gradle is 19.
class WebsiteViewer extends StatefulWidget {
  final String title;
  final String url;

  const WebsiteViewer({Key key, this.title, @required this.url})
      : super(key: key);

  @override
  _WebsiteViewerState createState() => _WebsiteViewerState();
}

class _WebsiteViewerState extends State<WebsiteViewer> {
  @override
  void initState() {
    if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title ?? 'Opened Link'),
        backgroundColor: Colors.grey[600],
        leading: IconButton(
          icon: Icon(Icons.close),
          onPressed: Navigator.of(context).pop,
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.launch,
              color: Colors.white,
            ),
            onPressed: () {
              launch(widget.url);
            },
          )
        ],
      ),
      body: WebView(
        initialUrl: widget.url,
        javascriptMode: JavascriptMode.unrestricted,
      ),
    );
  }
}
