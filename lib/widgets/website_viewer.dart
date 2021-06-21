import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wakelock/wakelock.dart';
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
  WebViewController _webViewController;
  bool _wakelock = false;
  final GlobalKey<ScaffoldState> _key = new GlobalKey<ScaffoldState>();

  @override
  void initState() {
    if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();
    super.initState();
  }

  @override
  void dispose() {
    Wakelock.disable();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Wakelock.toggle(enable: _wakelock);
    return Scaffold(
      key: _key,
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
              Icons.refresh,
              color: Colors.white,
            ),
            tooltip: 'Refresh current web page',
            onPressed: () {
              if (_webViewController != null) {
                _webViewController.reload();
              }
            },
          ),
          IconButton(
            icon: Icon(
              Icons.launch,
              color: Colors.white,
            ),
            tooltip: 'Launch current web page in your browser',
            onPressed: () {
              launch(widget.url);
            },
          ),
          IconButton(
            icon: Icon(
              _wakelock ? Icons.lock_open : Icons.lock,
              color: Colors.white,
            ),
            tooltip: 'Lock your screen from turning off',
            onPressed: () async {
              if (await Wakelock.enabled) {
                setState(() {
                  _wakelock = false;
                });
              } else {
                setState(() {
                  _wakelock = true;
                });
              }
            },
          )
        ],
      ),
      body: WebView(
        initialUrl: widget.url,
        javascriptMode: JavascriptMode.unrestricted,
        onWebViewCreated: (controller) {
          _webViewController = controller;
        },
      ),
    );
  }

}
