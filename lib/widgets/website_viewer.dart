import 'package:flutter/material.dart';
import 'dart:io';

class WebsiteViewer extends StatefulWidget {
  const WebsiteViewer({Key key}) : super(key: key);

  @override
  _WebsiteViewerState createState() => _WebsiteViewerState();
}

class _WebsiteViewerState extends State<WebsiteViewer> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hello'),
      ),
      body: Text('Nothing here for the moment.'),
    );
  }
}
