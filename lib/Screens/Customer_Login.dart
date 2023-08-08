import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:lunchbox/Screens/Customer_HomeScreen.dart';
import 'package:lunchbox/Screens/Customer_signinupScreen.dart';
import 'package:lunchbox/Screens/Home_Screen.dart';
import 'package:lunchbox/Screens/signup_screen.dart';
import 'package:lunchbox/Screens/splash_screen.dart';
import 'package:lunchbox/utils/color_utils.dart';
import 'package:lunchbox/reusable_widgets/reusable_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';
import '../services/firebase_services.dart';

class CustomerLoginScreen extends StatefulWidget {
  const CustomerLoginScreen({super.key});

  @override
  _CustomerLoginScreenState createState() => _CustomerLoginScreenState();
}

class _CustomerLoginScreenState extends State<CustomerLoginScreen> {
  TextEditingController _passwordTextController = TextEditingController();
  TextEditingController _emailTextController = TextEditingController();
  Future<void> requestLocationPermission(BuildContext context) async {
    LocationPermission permission;

    // Request permission from user
    do {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        // Show dialog box
        await showDialog(
          context: context,
          builder: (BuildContext context) => AlertDialog(
            title: Text('Location Permission Required'),
            content: Text(
              'Please grant location permission to use this feature.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('CANCEL'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text('OKAY'),
              ),
            ],
          ),
        );
      }
    } while (permission != LocationPermission.always &&
        permission != LocationPermission.whileInUse);

    // Permission granted
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                logoWidget("assets/images/logo.png", 200),
                SizedBox(
                  height: 30,
                ),
                reusableTextField("Enter UserName", Icons.person_outline, false,
                    _emailTextController),
                SizedBox(
                  height: 20,
                ),
                reusableTextField("Enter Password", Icons.lock_outline, true,
                    _passwordTextController),
                SizedBox(
                  height: 20,
                ),
                signInSignUpButton(context, true, () {
                  requestLocationPermission(context);
                  FirebaseAuth.instance
                      .signInWithEmailAndPassword(
                          email: _emailTextController.text,
                          password: _passwordTextController.text)
                      .then((userCredential) async {
                    if (userCredential.user?.emailVerified == true) {
                      //Login check

                      var sharedPref = await SharedPreferences.getInstance();
                      sharedPref.setBool(SplashScreenState.keyLogin, true);
                      sharedPref.setString(
                          SplashScreenState.keyUserType, "client");

                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => CustHomeScreen()));
                    } else {
                      showSnackBar(context,
                          "Please verify your email using link sent in mail before logging in.");
                    }
                  }).onError((error, stackTrace) {
                    Get.bottomSheet(SingleChildScrollView(
                        child: ClipRRect(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(10.0),
                              topRight: Radius.circular(10.0),
                            ),
                            child: Container(
                                color: Color.fromARGB(255, 253, 253, 253),
                                height: 250,
                                child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.stretch,
                                        children: [
                                          const Text(
                                            "Invalid Login Please\n Enter correct Details",
                                            style: TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold),
                                            textAlign: TextAlign.center,
                                          ),
                                          const SizedBox(
                                            height: 10,
                                          ),
                                        ]))))));
                  });
                }),
                signUpOption(),
                TextButton(
                  onPressed: () {
                    _showPasswordResetDialog();
                  },
                  child: Text(
                    'Forgot Password?',
                    style: TextStyle(
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Divider(
                          thickness: 1,
                          color: Color.fromARGB(255, 0, 0, 0), // corrected line
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 25.0),
                        child: Text('Or Sigin with'),
                      ),
                      Expanded(
                        child: Divider(
                          thickness: 1,
                          color: Color.fromARGB(255, 0, 0, 0), // corrected line
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 25,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                        height: 50,
                        child: GestureDetector(
                          onTap: () async {
                            requestLocationPermission(context);
                            try {
                              // final googleSignInAccount =
                              await FirebaseServices().signInWithGoogle();
                              /*if (googleSignInAccount == null) {
                                print("++++++++++++User did not Signed in");
                                return;
                              }*/
                              var sharedPref =
                                  await SharedPreferences.getInstance();
                              sharedPref.setBool(
                                  SplashScreenState.keyLogin, true);
                              sharedPref.setString(
                                  SplashScreenState.keyUserType, "client");
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => CustHomeScreen()),
                              );
                            } catch (e) {
                              // Handle sign-in error here.
                              print(e.toString());
                            }
                          },
                          child: Image.asset("assets/images/google.png"),
                        )),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  void showSnackBar(BuildContext context, String message) {
    final snackBar = SnackBar(content: Text(message));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  Row signUpOption() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("Don't have account? ",
            style: TextStyle(color: Color.fromARGB(255, 255, 0, 0))),
        GestureDetector(
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => CustomerSignUpScreen()));
          },
          child: const Text(
            "Sign Up",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
        )
      ],
    );
  }

  void _showPasswordResetDialog() {
    TextEditingController emailController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Reset Password'),
          content: TextField(
            controller: emailController,
            decoration: InputDecoration(
              hintText: 'Enter your email',
            ),
          ),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Reset'),
              onPressed: () async {
                try {
                  await FirebaseAuth.instance
                      .sendPasswordResetEmail(email: emailController.text);
                  Navigator.of(context).pop();
                  // ignore: use_build_context_synchronously
                  showSnackBar(context,
                      'Password reset email sent to ${emailController.text}');
                } on FirebaseAuthException catch (e) {
                  Navigator.of(context).pop();
                  showSnackBar(context, e.message ?? 'An error occurred');
                }
              },
            ),
          ],
        );
      },
    );
  }
}
