import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:FlutterProjectp/modal/auth_modal.dart';
import 'package:FlutterProjectp/route/route.dart' as route;
import 'package:http/http.dart' as http;
import '../config/api.dart' as config;
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:shared_preferences/shared_preferences.dart';

class RegistrationPage extends StatelessWidget {
  const RegistrationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Registration"),
        ),
        body: Center(child: RegistrationForm()
            // ElevatedButton(onPressed: () => Navigator.pushNamed(context, route.homePage),
            //  child: Text("Go to home page")),
            // )
            ));
  }
}

class RegistrationForm extends StatefulWidget {
  @override
  _RegistrationFormState createState() => _RegistrationFormState();
}

class _RegistrationFormState extends State<RegistrationForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _name = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final TextEditingController _renterPassword = TextEditingController();

  final baseURL = dotenv.env['BASE_API'];

  RegExp get _emailRegex => RegExp(r'^\S+@\S+\.\S+$');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Form(
        key: _formKey,
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                    controller: _name,
                    decoration: const InputDecoration(
                        border: OutlineInputBorder(), labelText: 'Name'),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter your name.';
                      }
                      // You can add more complex email validation logic here if needed
                      return null;
                    }),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                    controller: _email,
                    decoration: const InputDecoration(
                        border: OutlineInputBorder(), labelText: 'Email'),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter your email address.';
                      }
                      if (!_emailRegex.hasMatch(value)) {
                        return 'Email address is not valid';
                      }
                      return null;
                    }),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                    controller: _password,
                    decoration: const InputDecoration(
                        border: OutlineInputBorder(), labelText: 'Password'),
                    obscureText: true,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter a password.';
                      }
                      return null;
                    }),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                    controller: _renterPassword,
                    decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Renter Password'),
                    obscureText: true,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please renter a password.';
                      }
                      if (_password.text != value) {
                        return 'Password not match';
                      }
                      return null;
                    }),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: InkWell(
                  onTap: _submitForm,
                  child: Container(
                    height: 50,
                    width: MediaQuery.of(context).size.width,
                    decoration: const BoxDecoration(
                        color: Colors.black87,
                        borderRadius: BorderRadius.all(Radius.circular(5))),
                    child: const Center(
                      child: Text(
                        "Registration",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ),
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: InkWell(
                      child: const Text(
                        "Already have an account? Login here",
                        style: TextStyle(
                          decoration: TextDecoration.underline,
                        ),
                      ),
                      onTap: () => Navigator.of(context)
                          .pushNamedAndRemoveUntil(
                              route.loginPage, (Route<dynamic> route) => false),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final response = await http.post(
        Uri.parse('$baseURL/auth/signup'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({'name': _name.text, 'email': _email.text, 'password': _password.text}),
      );

      if (response.statusCode == 200) {
        // then parse the JSON.
        final prefs = await SharedPreferences.getInstance();
        AuthModal data =
            AuthModal.fromJson(jsonDecode(response.body.toString()));

        final dataString = jsonEncode(data);
        prefs.setString('userInfo_', dataString);
        prefs.setString('isLoggedIn_', 'true');

        Navigator.of(context).pushNamedAndRemoveUntil(
            route.homePage, (Route<dynamic> route) => false);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('This email already have an account.')),
        );
      }
    }
  }
}
