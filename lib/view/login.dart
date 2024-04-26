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

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Login"),
        ),
        body: Center(child: LoginForm()
            // ElevatedButton(onPressed: () => Navigator.pushNamed(context, route.homePage),
            //  child: Text("Go to home page")),
            // )
            ));
  }
}

class LoginForm extends StatefulWidget {
  @override
  _LoginFormState createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  var isLoading = false;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();

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
                    controller: _email,
                    decoration: InputDecoration(
                        border: OutlineInputBorder(), labelText: 'Email'),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter your email address.';
                      }
                      if (!_emailRegex.hasMatch(value)) {
                        return 'Email address is not valid';
                      }
                      // You can add more complex email validation logic here if needed
                      return null;
                    }),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                    controller: _password,
                    decoration: InputDecoration(
                        border: OutlineInputBorder(), labelText: 'Password'),
                    obscureText: true,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter a password.';
                      }
                      // You can add more password validation logic here if needed
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
                    child: Center(
                      child: isLoading
                          ? const CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 3,
                            )
                          : const Text(
                              "Login",
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
                        "Don't have an account? Register here",
                        style: TextStyle(
                          decoration: TextDecoration.underline,
                        ),
                      ),
                      onTap: () => Navigator.of(context)
                          .pushNamedAndRemoveUntil(route.registrationPage,
                              (Route<dynamic> route) => false),
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
    setState(() {
      isLoading = true;
    });
    if (_formKey.currentState!.validate()) {
      final response = await http.post(
        Uri.parse('$baseURL/auth/login'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({'email': _email.text, 'password': _password.text}),
      );

      if (response.statusCode == 200) {
        // then parse the JSON.
        final prefs = await SharedPreferences.getInstance();
        AuthModal data =
            AuthModal.fromJson(jsonDecode(response.body.toString()));

        final dataString = jsonEncode(data);
        prefs.setString('userInfo_', dataString);
        prefs.setString('isLoggedIn_', 'true');

        if (data.role == '8274') {
          Navigator.of(context).pushNamedAndRemoveUntil(
              route.adminPage, (Route<dynamic> route) => false);
        } else {
          Navigator.of(context).pushNamedAndRemoveUntil(
              route.homePage, (Route<dynamic> route) => false);
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Wrong email and password.')),
        );
      }
    }
    setState(() {
      isLoading = false;
    });
  }
}
