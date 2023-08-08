import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../reusable_widgets/reusable_widget.dart';
import '../utils/color_utils.dart';
import 'Home_Screen.dart';
import 'Signin_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  File? pickedImage;
  void imagePickerOption() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.camera,
      Permission.storage,
    ].request();
    print("Camera permission: ${statuses[Permission.camera]},"
        "Storage permission: ${statuses[Permission.storage]}");

    Get.bottomSheet(
      SingleChildScrollView(
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
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    "Pic Image From",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      pickImage(ImageSource.camera);
                    },
                    icon: const Icon(Icons.camera),
                    label: const Text("CAMERA"),
                  ),
                  ElevatedButton.icon(
                    onPressed: () async {
                      pickImage(ImageSource.gallery);
                    },
                    icon: const Icon(Icons.image),
                    label: const Text("GALLERY"),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      Get.back();
                    },
                    icon: const Icon(Icons.close),
                    label: const Text("CANCEL"),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  TextEditingController _passwordTextController = TextEditingController();
  TextEditingController _emailTextController = TextEditingController();
  TextEditingController _resturantNameTextController = TextEditingController();
  TextEditingController _OwnerNameTextController = TextEditingController();
  TextEditingController _PhoneNumberTextController = TextEditingController();
  TextEditingController _Location = TextEditingController();

  // Create a GeoPoint object with the user's current location

  GeoPoint userLocation = const GeoPoint(18.519995, 73.874158);
  Future<void> requestLocationPermission(BuildContext context) async {
    // Permission granted
  }
  Future<void> setSourceLocation() async {
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

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    // update sourceLocation with the new location
    userLocation = GeoPoint(position.latitude, position.longitude);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => SignInScreen()));
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
                Align(
                  alignment: Alignment.center,
                  child: Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.indigo, width: 2),
                          borderRadius: const BorderRadius.all(
                            Radius.circular(100),
                          ),
                        ),
                        child: ClipOval(
                            child: pickedImage != null
                                ? Image.file(
                                    pickedImage!,
                                    width: 150,
                                    height: 150,
                                    fit: BoxFit.cover,
                                  )
                                : logoWidget("assets/images/logo.png", 150)),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 5,
                        child: IconButton(
                          onPressed: imagePickerOption,
                          icon: const Icon(
                            Icons.add_a_photo_outlined,
                            color: Color.fromARGB(255, 51, 186, 244),
                            size: 20,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton.icon(
                    onPressed: imagePickerOption,
                    icon: const Icon(Icons.add_a_photo_sharp,
                        color: Colors.black),
                    label: const Text(
                      'UPLOAD IMAGE',
                      style: const TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.bold,
                          fontSize: 10),
                    ),
                    style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.resolveWith((states) {
                          if (states.contains(MaterialState.pressed)) {
                            return Colors.black26;
                          }
                          return Colors.white;
                        }),
                        shape:
                            MaterialStateProperty.all<RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30)))),
                  ),
                ),
                reusableTextField(
                    "Enter Resturant Name",
                    Icons.restaurant_rounded,
                    false,
                    _resturantNameTextController),
                const SizedBox(
                  height: 20,
                ),
                reusableTextField("Enter Owner Name", Icons.person_outline,
                    false, _OwnerNameTextController),
                const SizedBox(
                  height: 20,
                ),
                reusableTextField(
                    "Enter Address", Icons.location_city, false, _Location),
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
                TextField(
                  controller: _PhoneNumberTextController,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(10),
                  ],
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.phone_android),
                    hintText: 'Enter your phone number',
                  ),
                ),
                signInSignUpButton(context, false, () async {
                  await setSourceLocation();
                  File file = File(pickedImage!.path);

                  print(pickedImage!.path);
                  String imageUrl = await uploadImageAndGetUrl(file);
                  print("***************" + imageUrl);
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

                      final tasks = [
                        FirebaseFirestore.instance
                            .collection('Hotels')
                            .doc(firebaseUser?.uid)
                            .set({
                          'resturantName': _resturantNameTextController.text,
                          'ownerName': _OwnerNameTextController.text,
                          'Location': _Location.text,
                          'email': _emailTextController.text,
                          'phoneNumber': _PhoneNumberTextController.text,
                          'imageUrl': imageUrl,
                          'currentHotel': userLocation,
                        }),
                        firebaseUser!.sendEmailVerification()
                      ];

                      int completedTasks = 0;
                      tasks.asMap().forEach((index, task) async {
                        await task;
                        completedTasks++;
                        if (index == tasks.length - 1) {
                          Navigator.pop(context);
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const SignInScreen()));
                        }
                      });
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

  pickImage(ImageSource imageType) async {
    try {
      final photo = await ImagePicker().pickImage(source: imageType);
      if (photo == null) {
        return;
      }

      setState(() {
        pickedImage = File(photo.path);
      });

      Get.back();
    } catch (error) {
      print("Heres the error");
      debugPrint(error.toString());
    }
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

  Future<String> uploadImageAndGetUrl(File file) async {
    try {
      String fileName = file.path.split('/').last;
      Reference ref = FirebaseStorage.instance.ref().child(fileName);
      UploadTask uploadTask = ref.putFile(file);
      await uploadTask;
      String downloadUrl = await ref.getDownloadURL();
      return downloadUrl;
    } catch (error) {
      print('Error uploading image to Firebase Storage: $error');
      throw Exception('Failed to upload image to Firebase Storage.');
    }
  }
}
