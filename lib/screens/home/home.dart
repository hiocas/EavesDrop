import 'package:flutter/services.dart';
import 'package:eavesdrop/screens/gwa_drawer/gwa_drawer.dart';
import 'package:eavesdrop/states/global_state.dart';
import 'package:provider/provider.dart';
import 'package:draw/draw.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:eavesdrop/widgets/gradient_appbar_flexible_space.dart';

import 'local_widgets/home_section.dart';

//FIXME: Sometimes certain lists don't load.
@Deprecated('Was replaced with NewHome')
class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

@deprecated
class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: Theme.of(context).backgroundColor,
        appBar: AppBar(
          title: Text('Home'),
          elevation: 15.0,
          backgroundColor: Colors.transparent,
          backwardsCompatibility: false,
          systemOverlayStyle: SystemUiOverlayStyle.light,
          flexibleSpace: GradientAppBarFlexibleSpace(),
          leading: IconButton(
            icon: Icon(Icons.menu),
            onPressed: () {
              _scaffoldKey.currentState.openDrawer();
            },
          ),
        ),
        drawer: GwaDrawer(),
        body: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              HomeSection(
                title: 'Top Posts of The Month',
                waitDuration: Duration(milliseconds: 800),
                contentStream: Provider.of<GlobalState>(context, listen: false)
                    .getTopStream(TimeFilter.month, 21),
                homeSectionPageContentStream:
                    Provider.of<GlobalState>(context, listen: false)
                        .getTopStream(TimeFilter.month, 99),
              ),
              HomeSection(
                title: 'Top Posts of The Week',
                waitDuration: Duration(milliseconds: 700),
                contentStream: Provider.of<GlobalState>(context, listen: false)
                    .getTopStream(TimeFilter.week, 21),
                homeSectionPageContentStream:
                    Provider.of<GlobalState>(context, listen: false)
                        .getTopStream(TimeFilter.week, 99),
              ),
              HomeSection(
                title: 'Hot Posts',
                waitDuration: Duration(milliseconds: 600),
                contentStream: Provider.of<GlobalState>(context, listen: false)
                    .getHotStream(21),
                homeSectionPageShufflePages: true,
                homeSectionPageContentStream:
                    Provider.of<GlobalState>(context, listen: false)
                        .getHotStream(99),
              )
            ],
          ),
        ),
      ),
    );
  }
}
