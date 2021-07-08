import 'package:draw/draw.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gwa_app/screens/gwa_drawer/gwa_drawer.dart';
import 'package:gwa_app/states/global_state.dart';
import 'package:provider/provider.dart';
import 'local_widgets/flat_home_section.dart';

class NewHome extends StatefulWidget {
  const NewHome({Key key}) : super(key: key);

  @override
  _NewHomeState createState() => _NewHomeState();
}

class _NewHomeState extends State<NewHome> {
  @override
  Widget build(BuildContext context) {
    final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
    return WillPopScope(
      onWillPop: () async => false,
      child: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topLeft,
            radius: 2.0,
            stops: [0.07, 0.5, 1.0],
            colors: [
              Theme.of(context).primaryColor,
              Theme.of(context).cardColor,
              Theme.of(context).backgroundColor,
            ],
          ),
        ),
        child: Scaffold(
          key: _scaffoldKey,
          appBar: AppBar(
            title: Text('Home'),
            elevation: 0.0,
            backgroundColor: Colors.transparent,
            backwardsCompatibility: false,
            systemOverlayStyle: SystemUiOverlayStyle.light,
            leading: IconButton(
              icon: Icon(Icons.menu),
              onPressed: () {
                _scaffoldKey.currentState.openDrawer();
              },
            ),
          ),
          onDrawerChanged: (open) {
            // In case a setting change occurred that requires a rebuild.
            if (!open && GwaDrawerManager.updateOnReturn) {
              GwaDrawerManager.updateOnReturn = false;
              setState(() {});
            }
          },
          drawer: GwaDrawer(),
          backgroundColor: Colors.transparent,
          body: SingleChildScrollView(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  FlatHomeSection(
                    title: 'Top Posts of The Month',
                    size: 175,
                    showAuthors: true,
                    authorTextSize: 14.0,
                    textSize: 15.5,
                    waitDuration: Duration(milliseconds: 600),
                    contentStream:
                        Provider.of<GlobalState>(context, listen: false)
                            .getTopStream(TimeFilter.month, 21),
                    homeSectionPageContentStream:
                        Provider.of<GlobalState>(context, listen: false)
                            .getTopStream(TimeFilter.month, 99),
                  ),
                  FlatHomeSection(
                    title: 'Top Posts of The Week',
                    size: 150,
                    sizeRatio: 1.3,
                    showAuthors: true,
                    authorTextSize: 13.0,
                    waitDuration: Duration(milliseconds: 700),
                    contentStream:
                        Provider.of<GlobalState>(context, listen: false)
                            .getTopStream(TimeFilter.week, 21),
                    homeSectionPageContentStream:
                        Provider.of<GlobalState>(context, listen: false)
                            .getTopStream(TimeFilter.week, 99),
                  ),
                  FlatHomeSection(
                    title: 'Hot Posts',
                    size: 130,
                    sizeRatio: 1.2,
                    waitDuration: Duration(milliseconds: 800),
                    contentStream:
                        Provider.of<GlobalState>(context, listen: false)
                            .getHotStream(21),
                    homeSectionPageContentStream:
                        Provider.of<GlobalState>(context, listen: false)
                            .getHotStream(99),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
