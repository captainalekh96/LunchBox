import 'package:flutter/material.dart';

hexStringTOColor(String hexColor) {
  hexColor = hexColor.toUpperCase().replaceAll("a", "");
  if (hexColor.length == 6) {
    hexColor = "FF" + hexColor;
  }
  return Color(int.parse(hexColor, radix: 16));
}
