import 'package:FlutterProjectp/view/auth.dart';
import 'package:FlutterProjectp/view/myPosts.dart';
import 'package:FlutterProjectp/view/registration.dart';
import 'package:flutter/material.dart';

import 'package:FlutterProjectp/view/home.dart';
import 'package:FlutterProjectp/view/login.dart';

const String authPage = 'auth';
const String loginPage = 'login';
const String homePage = 'page';
const String postsPage = 'posts';
const String registrationPage = 'registration';

MaterialPageRoute controller(RouteSettings settings) {
  switch (settings.name) {
    case authPage:
      return MaterialPageRoute<dynamic>(builder: (context) => Auth());
    case loginPage:
      return MaterialPageRoute<dynamic>(builder: (context) => LoginPage());
    case registrationPage:
      return MaterialPageRoute<dynamic>(builder: (context) => RegistrationPage());
    case homePage:
      return MaterialPageRoute<dynamic>(builder: (context) => HomePage());
    case postsPage:
      return MaterialPageRoute<dynamic>(builder: (context) => MyPosts());
    default:
      throw ('Not found');
  }
}
