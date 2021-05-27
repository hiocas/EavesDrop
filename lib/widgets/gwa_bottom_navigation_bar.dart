import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

@Deprecated('This class is no longer useful, the bottom navigation bar now'
    'lives in main')
class GWABottomNavigationBar extends StatelessWidget {
  final int currentPageIndex;

  const GWABottomNavigationBar({
    Key key,
    @required this.currentPageIndex,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentPageIndex,
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
      onTap: (index) {
        switch (index) {
          case 0:
            if (currentPageIndex != 0){
              Navigator.pushReplacementNamed(context, 'SubmissionList');
            }
            break;
          case 2:
            if (currentPageIndex != 2){
              Navigator.pushReplacementNamed(context, 'Library');
            }
            break;
        }
      },
    );
  }
}
