import 'dart:convert';

import 'package:FlutterProjectp/view/myPosts.dart';
import 'package:flutter/material.dart';
import 'package:FlutterProjectp/route/route.dart' as route;
import 'package:FlutterProjectp/view/post.dart';
import 'package:FlutterProjectp/view/posts.dart';
import 'package:FlutterProjectp/view/profile.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
  }

  _changeTab(int index) async {
    if (index == 4) {
      final prefs = await SharedPreferences.getInstance();
      prefs.remove("userInfo_");
      prefs.remove("isLoggedIn_");

      return Navigator.of(context).pushNamedAndRemoveUntil(
          route.loginPage, (Route<dynamic> route) => false);
    }
    setState(() {
      _selectedTab = index;
    });
  }

  int _selectedTab = 0;
  List<String> tabsTitle = [
    "Home",
    "Profile",
    "Create Post",
    "Posts",
    "Logout"
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(tabsTitle[_selectedTab]),
        ),
        body: <Widget>[Posts(), Profile(), Post(), MyPosts()][_selectedTab],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedTab,
          onTap: (index) => _changeTab(index),
          selectedItemColor: Colors.red,
          unselectedItemColor: Colors.grey,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: "About"),
            BottomNavigationBarItem(
                icon: Icon(Icons.add_box), label: "Create Post"),
            BottomNavigationBarItem(
                icon: Icon(Icons.person_pin_outlined), label: "Posts"),
            BottomNavigationBarItem(
                icon: Icon(Icons.logout_outlined), label: "Logout"),
          ],
        ));
  }
}
