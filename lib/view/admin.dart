import 'dart:convert';

import 'package:FlutterProjectp/view/users.dart';
import 'package:flutter/material.dart';
import 'package:FlutterProjectp/route/route.dart' as route;
import 'package:FlutterProjectp/view/posts.dart';
import 'package:FlutterProjectp/view/profile.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdminPage extends StatefulWidget {
  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(["Home", "Users", "Profile", "Logout"][_selectedTab]),
        ),
        body: [Posts(), Users(), Profile()][_selectedTab],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedTab,
          onTap: (index) => _changeTab(index),
          selectedItemColor: Colors.red,
          unselectedItemColor: Colors.grey,
          items: [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
            BottomNavigationBarItem(icon: Icon(Icons.people), label: "Users"),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
            BottomNavigationBarItem(
                icon: Icon(Icons.logout_outlined), label: "Logout"),
          ],
        ));
  }
}
