import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class GWABottomNavigationBar extends StatelessWidget {
  const GWABottomNavigationBar({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      backgroundColor: Theme.of(context).backgroundColor,
      selectedItemColor: Theme.of(context).primaryColor,
      unselectedItemColor: Colors.grey[700],
      elevation: 15.0,
      items: [
        BottomNavigationBarItem(
          icon: Icon(Icons.search),
          label: 'Search',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.book),
          label: 'Library',
        )
      ],
    );
  }
}