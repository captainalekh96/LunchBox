import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:lunchbox/Screens/Home_Screen.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lunchbox/Screens/Hotel_Owner_profile.dart';

import '../reusable_widgets/reusable_widget.dart';
import '../utils/color_utils.dart';
import 'Signin_screen.dart';

class UpdateMenu extends StatefulWidget {
  const UpdateMenu({super.key});

  @override
  State<UpdateMenu> createState() => _UpdateMenuState();
}

class _UpdateMenuState extends State<UpdateMenu> {
  int _selectedIndex = 1;
  TextEditingController _DishName = TextEditingController();
  TextEditingController _NameofVegitable = TextEditingController();
  TextEditingController _Details = TextEditingController();
  TextEditingController _Price = TextEditingController();
  static TimeOfDay? startTime;
  static TimeOfDay? endTime;
  File? _image;
  Future<void> _getImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const HomeScreen()));
            },
          ),
          title: Text("Update Menu")),
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
                  child: GestureDetector(
                    onTap: _getImage,
                    child: Stack(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                                color: Color.fromARGB(255, 0, 0, 0), width: 2),
                          ),
                          child: ClipRRect(
                            child: _image != null
                                ? Image.file(
                                    _image!,
                                    width: 150,
                                    height: 150,
                                    fit: BoxFit.cover,
                                  )
                                : Container(
                                    width: 150,
                                    height: 150,
                                    color: Colors.grey[200],
                                    child: Icon(
                                      Icons.camera_alt,
                                      size: 50,
                                      color: Colors.grey[400],
                                    ),
                                  ),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 5,
                          child: IconButton(
                            onPressed: _getImage,
                            icon: const Icon(
                              Icons.add_a_photo_outlined,
                              color: Color.fromARGB(255, 60, 60, 60),
                              size: 20,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.center,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(8.0, 16.0, 8.0, 8.0),
                    child: ElevatedButton.icon(
                      onPressed: _getImage,
                      icon: const Icon(Icons.add_a_photo_sharp,
                          color: Color.fromARGB(255, 255, 253, 253)),
                      label: const Text(
                        'UPLOAD Your Dish Image',
                        style: const TextStyle(
                            color: Color.fromARGB(221, 255, 255, 255),
                            fontWeight: FontWeight.bold,
                            fontSize: 10),
                      ),
                    ),
                  ),
                ),
                UpdateMenuTextField("Dish Name", Icons.food_bank, _DishName),
                const SizedBox(
                  height: 20,
                ),
                UpdateMenuTextField("Enter Name of Vegetable",
                    Icons.dining_sharp, _NameofVegitable),
                const SizedBox(
                  height: 20,
                ),
                UpdateMenuTextField("3 chapaties, bowl of rice, sweet etc",
                    Icons.info, _Details),
                const SizedBox(
                  height: 20,
                ),
                TextField(
                  controller: _Price,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(4),
                  ],
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.money),
                    hintText: 'Enter Price',
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          TimeOfDay? selectedTime = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.now(),
                            initialEntryMode: TimePickerEntryMode.input,
                          );
                          if (selectedTime != null) {
                            if (endTime != null &&
                                selectedTime.hour >= endTime!.hour &&
                                selectedTime.minute >= endTime!.minute) {
                              // Start time is greater than or equal to end time, show message
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                      'Start time should be less than end time'),
                                ),
                              );
                            } else {
                              setState(() {
                                startTime = selectedTime;
                              });
                            }
                          }
                        },
                        icon: const Icon(Icons.lock_open),
                        label: const Text('Start Time'),
                        style: ElevatedButton.styleFrom(
                          primary: Colors.blueGrey[600],
                          elevation: 0,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      startTime != null ? startTime!.format(context) : '',
                      style: TextStyle(fontSize: 24),
                    ),
                    const SizedBox(width: 32),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          TimeOfDay? selectedTime = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.now(),
                            initialEntryMode: TimePickerEntryMode.input,
                          );
                          if (selectedTime != null) {
                            setState(() {
                              endTime = selectedTime;
                            });
                            if (endTime != null &&
                                startTime!.hour >= endTime!.hour &&
                                startTime!.minute >= endTime!.minute) {
                              // Start time is greater than or equal to end time, show message
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                      'End time should be greater than start time'),
                                ),
                              );
                            }
                          }
                        },
                        icon: const Icon(Icons.lock_open),
                        label: const Text('End Time'),
                        style: ElevatedButton.styleFrom(
                          primary: Colors.blueGrey[600],
                          elevation: 0,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      endTime != null ? endTime!.format(context) : '',
                      style: TextStyle(fontSize: 24),
                    ),
                    const SizedBox(width: 32),
                  ],
                ),
                /* Align(
                  alignment: Alignment.bottomLeft,
                  child: GestureDetector(
                    onTap: _getImage,
                    child: Stack(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                                color: Color.fromARGB(255, 0, 0, 0), width: 2),
                          ),
                          child: ClipRRect(
                            child: _image != null
                                ? Image.file(
                                    _image!,
                                    width: 150,
                                    height: 150,
                                    fit: BoxFit.cover,
                                  )
                                : Container(
                                    width: 150,
                                    height: 150,
                                    color: Colors.grey[200],
                                    child: Icon(
                                      Icons.camera_alt,
                                      size: 50,
                                      color: Colors.grey[400],
                                    ),
                                  ),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 5,
                          child: IconButton(
                            onPressed: _getImage,
                            icon: const Icon(
                              Icons.add_a_photo_outlined,
                              color: Color.fromARGB(255, 60, 60, 60),
                              size: 20,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),*/
                /* Align(
                  alignment: Alignment.bottomLeft,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(8.0, 16.0, 8.0, 8.0),
                    child: ElevatedButton.icon(
                      onPressed: _getImage,
                      icon: const Icon(Icons.add_a_photo_sharp,
                          color: Color.fromARGB(255, 255, 253, 253)),
                      label: const Text(
                        'UPLOAD Your Dish Image',
                        style: const TextStyle(
                            color: Color.fromARGB(221, 255, 255, 255),
                            fontWeight: FontWeight.bold,
                            fontSize: 10),
                      ),
                    ),
                  ),
                ),*/
                signInSignUpButton(context, false, () async {
                  File file = File(_image!.path);

                  print(_image!.path);
                  String imageUrl = await uploadImageAndGetUrl(file);
                  print("***************" + imageUrl);

                  try {
                    final firebaseUser = FirebaseAuth.instance.currentUser;
                    final _startTime = DateTime(
                      DateTime.now().year,
                      DateTime.now().month,
                      DateTime.now().day,
                      startTime!.hour,
                      startTime!.minute,
                    );
                    final _endTime = DateTime(
                      DateTime.now().year,
                      DateTime.now().month,
                      DateTime.now().day,
                      endTime!.hour,
                      endTime!.minute,
                    );
                    await FirebaseFirestore.instance
                        .collection('Hotels')
                        .doc(firebaseUser?.uid)
                        .collection('Menu')
                        .doc('menu')
                        .set({
                      'DishName': _DishName.text,
                      'NameOfVegetable': _NameofVegitable.text,
                      'Details': _Details.text,
                      'Price': _Price.text,
                      'Time Start': Timestamp.fromDate(_startTime),
                      'Time End': Timestamp.fromDate(_endTime),
                      'DishImage': imageUrl //save the image URL in Firestore
                    });

                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const HomeScreen()));
                  } catch (e) {
                    print(e);
                    Get.snackbar("Error creating account", e.toString());
                  }

                  ;
                }),
              ],
            ),
          ))),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.edit),
            label: 'Update Menu',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        onTap: (value) {
          setState(() {
            _selectedIndex = 1;
            _selectedIndex = value;
          });

          switch (value) {
            case 0:
              // Navigate to HomeScreen()
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => HomeScreen()),
              );
              break;
            case 1:
              // Navigate to UpdateMenu()
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => UpdateMenu()),
              );
              break;
            case 2:
              // Navigate to UpdateMenu()
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProfileScreen()),
              );
              break;
          }
        },
      ),
    );
  }
}
