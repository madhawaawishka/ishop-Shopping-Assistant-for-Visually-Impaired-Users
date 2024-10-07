import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:spm_project/auth/loginOrRegister.dart';
import 'package:spm_project/pages/home.dart'; // Student Home Page
import 'package:spm_project/pages/tutor_home.dart'; // Tutor Home Page

class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  Future<String?> getUserRole() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('Users')
          .doc(user.uid)
          .get();

      if (doc.exists) {
        return doc['role'] as String?;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data != null) {
            return FutureBuilder<String?>(
              future: getUserRole(),
              builder: (context, roleSnapshot) {
                if (roleSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (roleSnapshot.hasError) {
                  return const Center(child: Text('Error fetching role'));
                } else if (roleSnapshot.hasData) {
                  if (roleSnapshot.data == 'Student') {
                    return const HomePage(); // Student Home Page
                  } else if (roleSnapshot.data == 'Tutor') {
                    return const TutorHomePage(); // Tutor Home Page
                  } else {
                    return const Center(child: Text('Unknown role'));
                  }
                } else {
                  return const Center(child: Text('No role found'));
                }
              },
            );
          } else {
            return const LoginOrRegister();
          }
        },
      ),
    );
  }
}
