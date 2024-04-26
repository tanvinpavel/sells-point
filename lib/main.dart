import 'dart:convert';

import 'package:flutter/material.dart';
import 'route/route.dart' as route;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  Stripe.publishableKey =
      "pk_test_51P8xza073MHpr3y2LgK9ZwqGHNQY272m98AGRkjIsLkcMgmP80j329Ft2M12CsMdqAf9ayPXpVNWOEVRsp4TiQSS00eJOg8Ls4";
  await dotenv.load(fileName: ".env");
  runApp(const FlutterProject());
}

class FlutterProject extends StatelessWidget {
  const FlutterProject({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sells Point',
      theme: ThemeData(useMaterial3: true),
      onGenerateRoute: route.controller,
      initialRoute: route.authPage,
    );
  }
}
