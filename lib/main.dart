import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:lunchbox/Screens/Signin_screen.dart';
import 'package:get/get.dart';
import 'package:lunchbox/Screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    await Firebase.initializeApp(
      options: FirebaseOptions(
          apiKey: "AIzaSyAAg1c9QpfdvQ1F6VEUsMBpk8OG9uushQI",
          authDomain: "lunchbox-6e3da.firebaseapp.com",
          databaseURL: "https://lunchbox-6e3da-default-rtdb.firebaseio.com",
          projectId: "lunchbox-6e3da",
          storageBucket: "lunchbox-6e3da.appspot.com",
          messagingSenderId: "177278746030",
          appId: "1:177278746030:web:47bf35a4c95575fd589c3f",
          measurementId: "G-QEF3SW6TNT"),
    );
  } else {
    await Firebase.initializeApp();
  }
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'LunchBox',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: SplashScreen(),
    );
  }
}
