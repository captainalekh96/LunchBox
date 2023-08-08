import 'dart:async';

import 'package:flutter/material.dart';
import 'package:lunchbox/Screens/Customer_HomeScreen.dart';
import 'package:lunchbox/Screens/Home_Screen.dart';
import 'package:lunchbox/Screens/Signin_screen.dart';
import 'package:lunchbox/Screens/WelcomeScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../reusable_widgets/reusable_widget.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> {
  static const String keyLogin = "login";
  static const String keyUserType = "user_type";
  @override
  void initState() {
    super.initState();
    whereToGo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.white,
        child: Center(
          child: logoWidget("assets/images/logo.png", 200),
        ),
      ),
    );
  }

  void whereToGo() async {
    var sharedPref = await SharedPreferences.getInstance();
    var isLoggedIn = sharedPref.getBool(keyLogin);
    var userType = sharedPref.getString(keyUserType);
    Timer(const Duration(seconds: 1), () {
      if (isLoggedIn != null && userType != null) {
        if (isLoggedIn) {
          if (userType == "client") {
            print("Hi i am client");
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => CustHomeScreen(),
              ),
            );
          } else if (userType == "hotel_owner") {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const HomeScreen(),
              ),
            );
          }
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const WelcomeScreen(),
            ),
          );
        }
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const WelcomeScreen(),
          ),
        );
      }
    });
  }
}
