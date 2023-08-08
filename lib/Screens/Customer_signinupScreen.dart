import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lunchbox/Screens/Customer_Login.dart';
import '../reusable_widgets/reusable_widget.dart';
import '../utils/color_utils.dart';
import 'Signin_screen.dart';

class CustomerSignUpScreen extends StatefulWidget {
  const CustomerSignUpScreen({Key? key}) : super(key: key);

  @override
  _CustomerSignUpScreenState createState() => _CustomerSignUpScreenState();
}

class _CustomerSignUpScreenState extends State<CustomerSignUpScreen> {
  TextEditingController _passwordTextController = TextEditingController();
  TextEditingController _emailTextController = TextEditingController();
  TextEditingController _userNameController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const CustomerLoginScreen()));
          },
        ),
        title: Text('Sign UP'),
      ),
      body: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          decoration: BoxDecoration(
              gradient: LinearGradient(colors: [
            hexStringTOColor("3DFFF1"),
            hexStringTOColor("C5FEFA"),
            hexStringTOColor("F6F6F6")
          ], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
          child: SingleChildScrollView(
              child: Padding(
            padding: EdgeInsets.fromLTRB(
                20, MediaQuery.of(context).size.height * 0.1, 10, 0),
            child: Column(
              children: <Widget>[
                reusableTextField(
                    "Enter UserName", Icons.email, false, _userNameController),
                const SizedBox(
                  height: 20,
                ),
                reusableTextField(
                    "Enter Email ID", Icons.email, false, _emailTextController),
                const SizedBox(
                  height: 20,
                ),
                reusableTextField("Enter Password", Icons.lock_outline, true,
                    _passwordTextController),
                const SizedBox(
                  height: 20,
                ),
                signInSignUpButton(context, false, () async {
                  bool emailInUse =
                      await isEmailAlreadyInUse(_emailTextController.text);
                  if (emailInUse) {
                    showSnackBar(context,
                        "Email id already in use please login or enter another email id.");
                  } else {
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircularProgressIndicator(),
                              SizedBox(height: 10),
                              Text("Uploading data..."),
                            ],
                          ),
                        );
                      },
                    );
                    try {
                      final firebaseUserCredential = await FirebaseAuth.instance
                          .createUserWithEmailAndPassword(
                              email: _emailTextController.text,
                              password: _passwordTextController.text);
                      final firebaseUser = firebaseUserCredential.user;
                      final snapshot = await FirebaseFirestore.instance
                          .collection('Clients')
                          .get();
                      if (snapshot.docs.any((doc) =>
                          doc.data()['Username'] == _userNameController.text)) {
                        Get.snackbar('Username already exists', '');
                        throw Exception;
                      }
                      if (snapshot.docs.any((doc) =>
                          doc.data()['email'] == _userNameController.text)) {
                        Get.snackbar('email already exists', '');
                        throw Exception;
                      }
                      FirebaseFirestore.instance
                          .collection('Clients')
                          .doc(firebaseUser?.uid)
                          .set({
                        'Username': _userNameController.text,
                        'email': _emailTextController.text,
                      });
                      firebaseUser!.sendEmailVerification();

                      Navigator.pop(context);
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  const CustomerLoginScreen()));
                    } catch (e) {
                      print(e);
                      Navigator.pop(context);
                      Get.snackbar("Error creating account", e.toString());
                    }
                  }
                }),
              ],
            ),
          ))),
    );
  }

  void showSnackBar(BuildContext context, String message) {
    final snackBar = SnackBar(content: Text(message));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  Future<bool> isEmailAlreadyInUse(String email) async {
    try {
      List<String> signInMethods =
          await FirebaseAuth.instance.fetchSignInMethodsForEmail(email);
      return signInMethods.isNotEmpty;
    } catch (e) {
      print('Error checking email: $e');
      return false;
    }
  }
}
