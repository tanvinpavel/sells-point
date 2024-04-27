import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:FlutterProjectp/modal/post_modal.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_stripe/flutter_stripe.dart' as _strip;

class Posts extends StatefulWidget {
  const Posts({super.key});

  @override
  State<Posts> createState() => _PostsState();
}

class _PostsState extends State<Posts> {
  Map<String, dynamic>? paymentIntent;
  
  List<PostModal> postList = [];

  final baseURL = dotenv.env['BASE_API'];
  var isLoading = false;

  Future<List<PostModal>> getUsersApi() async {
    final prefs = await SharedPreferences.getInstance();
    final String? userData = prefs.getString('userInfo_');

    if (userData != null && postList.isEmpty) {
      Map<String, dynamic> userDataParse = jsonDecode(userData);

      String token = userDataParse['accessToken'];

      final response = await http.get(
        Uri.parse('$baseURL/post/all'),
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

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
            child: FutureBuilder(
                future: getUsersApi(),
                builder: (content, snapshot) {
                  var data = snapshot.data;
                  if (data == null) {
                    return const Center(child: CircularProgressIndicator());
                  } else {
                    var datalength = data.length;
                    if (datalength == 0) {
                      return const Center(
                        child: Text('no data found'),
                      );
                    } else {
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
                                          TextButton(
                                            child: isLoading
                                                ? Container(
                                                    width: 24,
                                                    height: 24,
                                                    padding:
                                                        const EdgeInsets.all(
                                                            2.0),
                                                    child:
                                                        const CircularProgressIndicator(
                                                      color: Colors.white,
                                                      strokeWidth: 3,
                                                    ),
                                                  )
                                                : postList[index].status ==
                                                        'sold'
                                                    ? const Text("Sold")
                                                    : const Text("Buy"),
                                            onPressed: () async {
                                              if (postList[index].status !=
                                                  'sold') {
                                                setState(() {
                                                  isLoading = true;
                                                });
                                                await makePayment(
                                                    postList[index].price,
                                                    postList[index].sId,
                                                    index);
                                                // await confirmPurchase(
                                                //     postList[index].sId, index);
                                              }
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
                    }
                  }
                })),
      ],
    );
  }

  Future<void> makePayment(price, postId, index) async {
    try {
      //STEP 1: Create Payment Intent
      final priceDouble = price.toString();
      paymentIntent = await createPaymentIntent(priceDouble, 'USD');

      setState(() {
        isLoading = false;
      });

      //STEP 2: Initialize Payment Sheet
      await _strip.Stripe.instance
          .initPaymentSheet(
            paymentSheetParameters: _strip.SetupPaymentSheetParameters(
              paymentIntentClientSecret: paymentIntent!['client_secret'],
              style: ThemeMode.dark,
              merchantDisplayName: 'Pavel',
            ),
          )
          .then((value) {});

      //STEP 3: Display Payment sheet
      displayPaymentSheet(postId, index);
    } catch (err) {
      print(err.toString());
    }
  }

  displayPaymentSheet(postId, index) async {
    try {
      await _strip.Stripe.instance.presentPaymentSheet().then((value) async {
        await confirmPurchase(postId, index);

        showDialog(
            context: context,
            builder: (_) => const AlertDialog(
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: 100.0,
                      ),
                      SizedBox(height: 10.0),
                      Text("Payment Successful!"),
                    ],
                  ),
                ));

        paymentIntent = null;
      }).onError((error, stackTrace) {
        throw Exception(error);
      });
    } on _strip.StripeException catch (e) {
      const AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(
                  Icons.cancel,
                  color: Colors.red,
                ),
                Text("Payment Failed"),
              ],
            ),
          ],
        ),
      );
    } catch (e) {
      print('$e');
    }
  }

  createPaymentIntent(String amount, String currency) async {
    try {
      //Request body
      Map<String, dynamic> body = {
        'amount': calculateAmount(amount),
        'currency': currency,
      };

      //Make post request to Stripe
      var response = await http.post(
        Uri.parse('https://api.stripe.com/v1/payment_intents'),
        headers: {
          'Authorization': 'Bearer ${dotenv.env['STRIPE_SECRET']}',
          'Content-Type': 'application/x-www-form-urlencoded'
        },
        body: body,
      );
      return jsonDecode(response.body.toString());
    } catch (err) {
      throw Exception(err.toString());
    }
  }

  calculateAmount(String amount) {
    final calculatedAmount = (int.parse(amount)) * 100;
    return calculatedAmount.toString();
  }

  confirmPurchase(postId, index) async {
    try {
      //Request body
      final prefs = await SharedPreferences.getInstance();
      final String? authData = prefs.getString('userInfo_');

      if (authData != null) {
        Map<String, dynamic> userDataParse = jsonDecode(authData);

        String token = userDataParse['accessToken'];
        final response =
            await http.post(Uri.parse('$baseURL/post/confirmPurchase'),
                headers: <String, String>{
                  'Content-Type': 'application/json; charset=UTF-8',
                  'Accept': 'application/json',
                  'Authorization': 'Bearer $token'
                },
                body: jsonEncode({
                  'postId': postId,
                }));

        setState(() {
          isLoading = false;
        });
        setState(() {
          postList[index].status = "sold";
        });
      }
    } catch (err) {
      setState(() {
        isLoading = false;
      });
      throw Exception(err.toString());
    }
  }
}
