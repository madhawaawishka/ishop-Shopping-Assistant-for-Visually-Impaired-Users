import 'package:flutter/material.dart';

ThemeData colorMode = ThemeData(
  brightness: Brightness.light,
  colorScheme: ColorScheme.light(
      surface: const Color(0xFFF5F8FF),
      primary: const Color.fromARGB(255, 37, 79, 176),
      secondary: const Color.fromARGB(255, 189, 189, 189),
      inversePrimary: Colors.grey.shade600),
  textTheme: ThemeData.light().textTheme.apply(
        bodyColor: Colors.grey[800],
        displayColor: Colors.black,
      ),
);
