import 'dart:async';
import 'dart:convert';
import 'package:FlutterProjectp/modal/user_modla.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class Users extends StatefulWidget {
  const Users({super.key});

  @override
  State<Users> createState() => _UsersState();
}

class _UsersState extends State<Users> {
  Map<String, dynamic>? paymentIntent;
  List<UserModal> userList = [];

  final baseURL = dotenv.env['BASE_API'];

  Future<List<UserModal>> getAllUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final String? userData = prefs.getString('userInfo_');

    if (userData != null && userList.isEmpty) {
      Map<String, dynamic> userDataParse = jsonDecode(userData);

      String token = userDataParse['accessToken'];
      String userId = userDataParse['email'];
      String role = userDataParse['role'];

      print('role form user $role');

      final response = await http.get(
        Uri.parse('$baseURL/user/getAllUsers'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
          'role': role
        },
      );
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body.toString());
        for (Map<String, dynamic> i in data) {
          userList.add(UserModal.fromJson(i));
        }
        return userList;
      } else {
        print(response.body);
        return userList;
      }
    } else {
      return [];
    }
  }

  Future<void> deleteUser(UserId, index) async {
    final prefs = await SharedPreferences.getInstance();
    final String? userData = prefs.getString('userInfo_');

    if (userData != null) {
      Map<String, dynamic> userDataParse = jsonDecode(userData);

      String token = userDataParse['accessToken'];
      String role = userDataParse['role'];

      final response = await http.delete(
        Uri.parse('$baseURL/user/delete?id=$UserId'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
          'role': role
        },
      );
      if (response.statusCode == 200) {
        setState(() {
          userList.removeAt(index);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User delete successfully.')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to delete User.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
            child: FutureBuilder(
                future: getAllUsers(),
                builder: (content, snapshot) {
                  if (snapshot.hasData) {
                    if (snapshot.data!.isNotEmpty) {
                      return ListView.builder(
                          itemCount: userList.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Center(
                                child: Card(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      ListTile(
                                        title: Text(userList[index]
                                            .firstName
                                            .toString()),
                                        subtitle:
                                            Text('${userList[index].email}'),
                                      ),
                                      ButtonBar(
                                        children: [
                                          TextButton(
                                            child: const Text("Delete"),
                                            onPressed: () async {
                                              await deleteUser(userList[index].sId, index);
                                            },
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          });
                    } else {
                      return const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [Text('Document not found')],
                          )
                        ],
                      );
                    }
                  } else {
                    return const Center(child: CircularProgressIndicator());
                  }
                })),
      ],
    );
  }
}
