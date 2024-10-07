import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:spm_project/component/button.dart';
import 'package:spm_project/helper/helper_function.dart';
import 'package:spm_project/pages/home.dart'; // Student Home Page
import 'package:spm_project/pages/tutor_home.dart'; // Tutor Home Page
import '../component/textfield.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';

class LoginPage extends StatefulWidget {
  final void Function()? onTap;
  const LoginPage({
    super.key,
    required this.onTap,
  });

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final storage = const FlutterSecureStorage();
  final LocalAuthentication auth = LocalAuthentication();
  bool isPasswordVisible = false;

  Future<void> authenticateWithBiometrics() async {
    bool authenticated = false;

    try {
      authenticated = await auth.authenticate(
        localizedReason: 'Use fingerprint to login',
        options: const AuthenticationOptions(
          biometricOnly: true,
        ),
      );
    } catch (e) {
      displayMessageToUser('Biometric authentication failed', context);
    }

    if (authenticated) {
      // Retrieve stored credentials
      String? email = await storage.read(key: 'email');
      String? password = await storage.read(key: 'password');

      if (email != null && password != null) {
        await login(email, password);
      } else {
        displayMessageToUser('No credentials found', context);
      }
    }
  }

  Future<void> login(String email, String password) async {
    showDialog(
      context: context,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      // Log the user in using Firebase Authentication
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      // Fetch the role from Firestore based on the user's UID
      String? role = await getUserRole(userCredential.user?.uid);

      Navigator.pop(context); // Close the loading dialog

      if (role != null) {
        if (role == 'Student') {
          // Navigate to the Student HomePage
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const HomePage()),
          );
        } else if (role == 'Tutor') {
          // Navigate to the Tutor HomePage
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const TutorHomePage()),
          );
        } else {
          displayMessageToUser("Invalid role", context);
        }
      } else {
        displayMessageToUser("No role found", context);
      }
    } on FirebaseAuthException catch (e) {
      Navigator.pop(context); // Close the loading dialog
      displayMessageToUser(e.code, context);
    }
  }

  Future<String?> getUserRole(String? uid) async {
    if (uid == null) return null;

    try {
      // Get the user document from Firestore
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('Users')
          .doc(uid)
          .get();

      if (userDoc.exists) {
        // Retrieve the role field from the document
        return userDoc['role'] as String?;
      }
    } catch (e) {
      displayMessageToUser('Error fetching role: $e', context);
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(25.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(
                  height: 25,
                ),
                const Text(
                  "Login",
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                ),
                const SizedBox(
                  height: 50,
                ),
                CustomTextField(
                  hintText: "Email",
                  obscureText: false,
                  controller: emailController,
                ),
                const SizedBox(
                  height: 10,
                ),
                CustomTextField(
                  hintText: "Password",
                  obscureText: !isPasswordVisible, // Toggle visibility
                  controller: passwordController,
                  suffixIcon: IconButton(
                    icon: Icon(
                      isPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        isPasswordVisible = !isPasswordVisible;
                      });
                    },
                  ),
                ),
                const SizedBox(
                  height: 25,
                ),
                CustomButton(
                  text: "Login",
                  ontap: () async {
                    await login(emailController.text, passwordController.text);
                  },
                ),
                const SizedBox(
                  height: 15,
                ),
                Text(
                  "Or",
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
                const SizedBox(height: 15),
                CustomButton(
                  text: "Login with Fingerprint",
                  ontap: () async {
                    await authenticateWithBiometrics();
                  },
                ),
                const SizedBox(
                  height: 25,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account?",
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.inversePrimary,
                      ),
                    ),
                    GestureDetector(
                      onTap: widget.onTap,
                      child: const Text(
                        " Register Here",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
