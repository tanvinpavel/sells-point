import 'dart:async';

import 'package:FlutterProjectp/view/home.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:FlutterProjectp/route/route.dart' as route;

class Auth extends StatefulWidget {
  const Auth({super.key});

  @override
  State<Auth> createState() => _AuthState();
}

class _AuthState extends State<Auth> {
  @override
  void initState() {
    super.initState();

    authChecker();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.blue, // Change the color to your desired color
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Loading...',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24.0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void authChecker() async {
    final prefs = await SharedPreferences.getInstance();

    final String? isLoggedIn = prefs.getString('isLoggedIn_');

    Timer(Duration(seconds: 2), () {
      if (isLoggedIn != null) {
        if(isLoggedIn == 'true') {
          Navigator.of(context).pushNamedAndRemoveUntil(
            route.homePage, (Route<dynamic> route) => false);
        } else {
          Navigator.of(context).pushNamedAndRemoveUntil(
            route.loginPage, (Route<dynamic> route) => false);
        }
      } else {
        Navigator.of(context).pushNamedAndRemoveUntil(
            route.loginPage, (Route<dynamic> route) => false);
      }
    });
  }
}
