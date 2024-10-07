import 'package:flutter/material.dart';
import 'package:spm_project/pages/login.dart';  // Import LoginPage
import 'package:spm_project/pages/register.dart';  // Import RegisterPage

class LoginOrRegister extends StatefulWidget {
  const LoginOrRegister({super.key});

  @override
  State<LoginOrRegister> createState() => _LoginOrRegisterState();
}

class _LoginOrRegisterState extends State<LoginOrRegister> {
  bool showLoginPage = true; // Initially show the login page

  // Function to toggle between login and register pages
  void togglePages() {
    setState(() {
      showLoginPage = !showLoginPage; // Toggle the state
    });
  }

  @override
  Widget build(BuildContext context) {
    // Conditional rendering of Login or Register page based on `showLoginPage` flag
    if (showLoginPage) {
      return LoginPage(
        onTap: togglePages, // Pass togglePages function to switch to RegisterPage
      );
    } else {
      return RegisterPage(
        ontap: togglePages, // Pass togglePages function to switch back to LoginPage
      );
    }
  }
}
