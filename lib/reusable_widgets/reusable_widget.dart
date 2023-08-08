import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:get/get.dart';

Widget logoWidget(String imageName, double size) {
  return Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: Color.fromARGB(255, 255, 255, 255),
      border: Border.all(color: Color.fromARGB(255, 255, 252, 252), width: 3),
    ),
    child: ClipOval(
      child: Image.asset(
        imageName,
        fit: BoxFit.cover,
      ),
    ),
  );
}

TextField reusableTextField(String text, IconData icon, bool isPasswordType,
    TextEditingController controller) {
  return TextField(
    controller: controller,
    obscureText: isPasswordType,
    enableSuggestions: !isPasswordType,
    autocorrect: !isPasswordType,
    cursorColor: Colors.orange,
    style: TextStyle(color: Color.fromARGB(255, 0, 0, 0).withOpacity(0.9)),
    decoration: InputDecoration(
      prefixIcon: Icon(
        icon,
        color: Color.fromARGB(179, 21, 20, 20),
      ),
      labelText: text,
      labelStyle:
          TextStyle(color: Color.fromARGB(255, 40, 39, 39).withOpacity(0.9)),
      filled: true,
      floatingLabelBehavior: FloatingLabelBehavior.never,
      fillColor: Color.fromARGB(255, 148, 148, 148).withOpacity(0.3),
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.0),
          borderSide: const BorderSide(width: 0, style: BorderStyle.none)),
    ),
    keyboardType: isPasswordType
        ? TextInputType.visiblePassword
        : TextInputType.emailAddress,
  );
}

TextField UpdateMenuTextField(
    String text, IconData icon, TextEditingController controller) {
  return TextField(
    controller: controller,
    decoration: InputDecoration(
      border: OutlineInputBorder(),
      prefixIcon: Icon(icon),
      hintText: text,
    ),
  );
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

Container signInSignUpButton(
    BuildContext context, bool isLogin, Function onTap) {
  return Container(
    width: MediaQuery.of(context).size.width,
    height: 50,
    margin: const EdgeInsets.fromLTRB(0, 10, 0, 20),
    decoration: BoxDecoration(borderRadius: BorderRadius.circular(90)),
    child: ElevatedButton(
      onPressed: () {
        onTap();
      },
      child: Text(
        isLogin ? 'LOG IN' : 'Save Details',
        style: const TextStyle(
            color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 16),
      ),
      style: ButtonStyle(
          backgroundColor: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.pressed)) {
              return Colors.black26;
            }
            return Colors.white;
          }),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)))),
    ),
  );
}
