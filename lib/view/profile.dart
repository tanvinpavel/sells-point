import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:FlutterProjectp/modal/user_modla.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  String? firstName = "";
  String? lastName = "";
  String? email = "";
  String? birthDate = "";

  final baseURL = dotenv.env['BASE_API'];

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late TextEditingController _firstName =
      TextEditingController(text: firstName);
  late TextEditingController _lastName = TextEditingController(text: lastName);
  late TextEditingController _email = TextEditingController(text: email);
  late TextEditingController _birthDate =
      TextEditingController(text: birthDate);

  Future<void> _getUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final String? authData = prefs.getString('userInfo_');

    if (authData != null) {
      Map<String, dynamic> userDataParse = jsonDecode(authData);

      String token = userDataParse['accessToken'];

      final response = await http.get(
        Uri.parse('$baseURL/user/getProfile'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token'
        },
      );

      if (response.statusCode == 200) {
        UserModal data =
            UserModal.fromJson(jsonDecode(response.body.toString()));

        _firstName = TextEditingController(text: data.firstName);
        _lastName = TextEditingController(text: data.lastName);
        _email = TextEditingController(text: data.email);
        _birthDate = TextEditingController(text: data.birthDate);

        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();

    _getUserProfile();
  }

  bool isLoading = true;

  Future<void> _formHandler() async {
    if (_formKey.currentState!.validate()) {
      final prefs = await SharedPreferences.getInstance();
      final String? authData = prefs.getString('userInfo_');

      if (authData != null) {
        Map<String, dynamic> userDataParse = jsonDecode(authData);

        String token = userDataParse['accessToken'];

        final response =
            await http.post(Uri.parse('$baseURL/user/updateProfile'),
                headers: <String, String>{
                  'Content-Type': 'application/json; charset=UTF-8',
                  'Accept': 'application/json',
                  'Authorization': 'Bearer $token'
                },
                body: jsonEncode({
                  'firstName': _firstName.text,
                  "lastName": _lastName.text,
                  'birthDate': _birthDate.text
                }));

        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile data update successfully.')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to update profile data.')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
        inAsyncCall: isLoading,
        child: Form(
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: _firstName,
                    decoration: InputDecoration(labelText: 'First Name'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "This field can't be empty";
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20),
                  TextFormField(
                    controller: _lastName,
                    decoration: InputDecoration(labelText: 'Last Name'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "This field can't be empty";
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20),
                  TextFormField(
                    controller: _email,
                    decoration: InputDecoration(labelText: 'Email'),
                    readOnly: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "This field can't be empty";
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20),
                  TextFormField(
                    controller: _birthDate,
                    decoration: InputDecoration(labelText: 'Date Of Birth'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "This field can't be empty";
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _formHandler,
                    child: Text('Update'),
                  ),
                ],
              ),
            )));
  }
}
