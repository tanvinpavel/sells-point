import 'dart:io';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/services.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class Post extends StatefulWidget {
  const Post({super.key});

  @override
  State<Post> createState() => _PostState();
}

class _PostState extends State<Post> {
  // final _formKey = GlobalKey<FormState>();
  // TextEditingController postController = TextEditingController();
  // bool _isPrivate = false;

  // @override
  // Widget build(BuildContext context) {
  //   return Form(
  //       key: _formKey,
  //       child: Padding(
  //           padding: EdgeInsets.all(16.0),
  //           child: Column(
  //             mainAxisAlignment: MainAxisAlignment.center,
  //             children: [
  //               Padding(
  //                 padding:
  //                     const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
  //                 child: TextFormField(
  //                   controller: postController,
  //                   decoration: const InputDecoration(
  //                       border: OutlineInputBorder(), labelText: "Post"),
  //                   validator: (value) {
  //                     if (value == null || value.isEmpty) {
  //                       return 'Please enter your email';
  //                     }
  //                     return null;
  //                   },
  //                 ),
  //               ),
  //               Padding(
  //                 padding:
  //                     const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
  //                 child: Checkbox(
  //                 value: _isPrivate,
  //                 onChanged: (value) {
  //                   setState(() {
  //                     _isPrivate = value ?? false;
  //                   });
  //                 },
  //               ),
  //               Text('Private'),
  //               ),
  //             ],
  //           ))
  //           );
  // }

  final TextEditingController _postController = TextEditingController();
  final TextEditingController _price = TextEditingController();
  File? _image;
  bool _isPrivate = false;
  Uint8List? registrationImage;
  bool isUploading = false;

  final baseURL = dotenv.env['BASE_API'];

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
        inAsyncCall: isUploading,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                // _image != null
                //     ? Image.file(
                //         _image!,
                //         height: 150,
                //         fit: BoxFit.cover,
                //       )
                //     : ElevatedButton(
                //         onPressed: _getImage,
                //         child: Text('Add Image'),
                //       ),
                registrationImage != null
                    ? Image.memory(
                        registrationImage!,
                        fit: BoxFit.cover,
                        height: 150,
                      )
                    : ElevatedButton(
                        onPressed: _getImage,
                        child: Text('Add Image'),
                      ),
                TextField(
                  controller: _postController,
                  decoration: const InputDecoration(labelText: 'Post'),
                  maxLines: null,
                ),
                TextField(
                  controller: _price,
                  decoration: const InputDecoration(labelText: 'Price'),
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Checkbox(
                      value: _isPrivate,
                      onChanged: (value) {
                        setState(() {
                          _isPrivate = value ?? false;
                        });
                      },
                    ),
                    Text('Private'),
                  ],
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _uploadImage,
                  child: const Text('Submit'),
                ),
              ],
            ),
          ),
        ));
  }

  Future<void> _getImage() async {
    XFile? pickedImage = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 90,
    );

    setState(() {
      _image = File(pickedImage!.path);
    });

    final Uint8List? bytImage = await pickedImage!.readAsBytes();
    if (bytImage != null) {
      setState(() {
        registrationImage = bytImage;
      });
    }
  }

  Future<void> _uploadImage() async {
    final prefs = await SharedPreferences.getInstance();
    final String? userData = prefs.getString('userInfo_');

    setState(() {
      isUploading = true;
    });

    String isPrivate = _isPrivate ? 'true' : 'false';

    if (userData != null) {
      Map<String, dynamic> userDataParse = jsonDecode(userData);
      String token = userDataParse['accessToken'];

      var request =
          http.MultipartRequest("POST", Uri.parse('$baseURL/post/create'));

      Map<String, String> headers = {
        "Content-type": "multipart/form-data",
        "Authorization": 'Bearer $token'
      };

      request.headers.addAll(headers);

      if (_image != null) {
        var stream = _image!.readAsBytes().asStream();

        print("multipartFile $stream");

        var length = _image!.lengthSync();
        print("multipartFile $length");

        var multipartFile = http.MultipartFile(
          "image",
          stream,
          length,
        );
        var stringMPF = multipartFile.toString();
        print("multipartFile $stringMPF");
        request.files.add(multipartFile);
      }

      request.fields['post'] = _postController.text;
      request.fields['price'] = _price.text;
      request.fields['private'] = isPrivate;

      var res = await request.send();
      http.Response response = await http.Response.fromStream(res);

      print(jsonDecode(response.body));

      _postController.clear();
      registrationImage = null;
      _isPrivate = false;
      _image = null;
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Successful.')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed.')),
        );
      }
    }

    setState(() {
      isUploading = false;
    });
  }
}
