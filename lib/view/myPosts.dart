import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:FlutterProjectp/modal/post_modal.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class MyPosts extends StatefulWidget {
  const MyPosts({super.key});

  @override
  State<MyPosts> createState() => _MyPostsState();
}

class _MyPostsState extends State<MyPosts> {
  Map<String, dynamic>? paymentIntent;
  List<PostModal> postList = [];

  final baseURL = dotenv.env['BASE_API'];

  Future<List<PostModal>> getUsersApi() async {
    final prefs = await SharedPreferences.getInstance();
    final String? userData = prefs.getString('userInfo_');

    if (userData != null && postList.isEmpty) {
      Map<String, dynamic> userDataParse = jsonDecode(userData);

      String token = userDataParse['accessToken'];
      String userId = userDataParse['email'];

      final response = await http.get(
        Uri.parse('$baseURL/post/all/$userId'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token'
        },
      );
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body.toString());
        for (Map<String, dynamic> i in data) {
          postList.add(PostModal.fromJson(i));
        }

        return postList;
      } else {
        return postList;
      }
    } else {
      return [];
    }
  }

  Future<void> deletePost(postId, publicId, index) async {
    final prefs = await SharedPreferences.getInstance();
    final String? userData = prefs.getString('userInfo_');

    if (userData != null) {
      Map<String, dynamic> userDataParse = jsonDecode(userData);

      String token = userDataParse['accessToken'];

      final response = await http.delete(
        Uri.parse('$baseURL/post/delete?id=$postId&publicId=$publicId'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token'
        },
      );
      if (response.statusCode == 200) {
        setState(() {
          postList.removeAt(index);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Post delete successfully.')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to delete post.')),
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
                future: getUsersApi(),
                builder: (content, snapshot) {
                  if (snapshot.hasData) {
                    if (snapshot.data!.isNotEmpty) {
                      return ListView.builder(
                          itemCount: postList.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Center(
                                child: Card(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      Image.network(
                                          postList[index].image ?? ""),
                                      ListTile(
                                        title: Text(postList[index]
                                            .userDetails!
                                            .firstName
                                            .toString()),
                                        subtitle:
                                            Text('${postList[index].post}'),
                                      ),
                                      ListTile(
                                        title: Text(
                                            'Price: ${postList[index].price} USD'),
                                      ),
                                      ButtonBar(
                                        children: [
                                          postList[index].status == 'sold'
                                              ? Text('Sold')
                                              : Text("Unsold"),
                                          TextButton(
                                            child:  const Text("Delete"),
                                            onPressed: () async {
                                              deletePost(
                                                  postList[index].sId,
                                                  postList[index].publicId,
                                                  index);
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
