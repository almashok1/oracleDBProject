import 'package:bottom_navy_bar/bottom_navy_bar.dart';
import 'package:db_project/rating.dart';
import 'package:db_project/schedule.dart';
import 'package:db_project/students.dart';
import 'package:db_project/teachers.dart';
import 'package:flutter/material.dart';

import 'courses.dart';

void main() => runApp(
  MaterialApp(
    theme: ThemeData(primaryColor: Color(0xff202040), 
      accentColor: Color(0xff543864),
    ),
    home: MyHomePage(title: "Database Oracle",)
  )
);

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _currentIndex = 0;
  PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() => _currentIndex = index);
        },
        children: <Widget>[
          Courses(),
          Teachers(),
          Students(),
          Schedule(),
          Rating(),
        ],
      ),
      bottomNavigationBar: BottomNavyBar(
        showElevation: true,
        backgroundColor: Theme.of(context).primaryColor,
        selectedIndex: _currentIndex,
        curve: Curves.fastOutSlowIn,
        onItemSelected: (index) {
          setState(() => _currentIndex = index);
          _pageController.jumpToPage(index);
        },
        items: <BottomNavyBarItem>[
          BottomNavyBarItem(
            title: Text('Courses'),
            icon: Icon(Icons.book),
            inactiveColor: Colors.white70,
            activeColor: Color(0xffffbd69),
          ),
          BottomNavyBarItem(
            title: Text('Teachers'),
            icon: Icon(Icons.person),
            inactiveColor: Colors.white70,
            activeColor: Color(0xffffbd69),
          ),
          BottomNavyBarItem(
            title: Text('Students'),
            icon: Icon(Icons.contact_mail),
            inactiveColor: Colors.white70,
            activeColor: Color(0xffffbd69),
          ),
          BottomNavyBarItem(
            title: Text('Schedules'),
            icon: Icon(Icons.schedule),
            inactiveColor: Colors.white70,
            activeColor: Color(0xffffbd69),
          ),
          BottomNavyBarItem(
            title: Text('Ratings'),
            icon: Icon(Icons.stars),
            inactiveColor: Colors.white70,
            activeColor: Color(0xffffbd69),
          ),
        ],
      ),
    );
  }
}