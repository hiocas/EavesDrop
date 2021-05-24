import 'package:flutter/material.dart';
import 'dart:io';
import 'package:webview_flutter/webview_flutter.dart';

class WebsiteViewer extends StatefulWidget {
  final String title;
  final String url;
  const WebsiteViewer({Key key, this.title, @required this.url}) : super(key: key);

  @override
  _WebsiteViewerState createState() => _WebsiteViewerState();
}

class _WebsiteViewerState extends State<WebsiteViewer> {
  @override
  void initState() {
    if(Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title ?? 'Opened Link'),
      ),
      body: WebView(
        initialUrl: widget.url,
        javascriptMode: JavascriptMode.unrestricted,
      )
      // Text('Nothing here for the moment.'),
    );
  }
}
