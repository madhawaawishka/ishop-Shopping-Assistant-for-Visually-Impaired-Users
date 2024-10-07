import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:spm_project/auth/auth.dart';
import 'package:spm_project/auth/loginOrRegister.dart';
import 'package:spm_project/firebase_options.dart';
import 'package:spm_project/pages/community_page.dart';
import 'package:spm_project/pages/help.dart';
import 'package:spm_project/pages/home.dart';
import 'package:spm_project/pages/login.dart';
import 'package:spm_project/pages/objects_detection/package_obj.dart';
import 'package:spm_project/pages/objects_detection/display_shape.dart';
import 'package:spm_project/pages/objects_detection/fruit_object.dart';
import 'package:spm_project/pages/objects_detection/vegetable_obj.dart';
import 'package:spm_project/pages/objects_page.dart';
import 'package:spm_project/pages/profile.dart';
import 'package:spm_project/pages/home_page.dart';

import 'package:spm_project/theme/colors.dart';
import 'package:spm_project/pages/tutor_list_page.dart'; // Import TutorListPage

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const AuthPage(),
      theme: colorMode,
      routes: {
        '/login_register_page': (context) => const LoginOrRegister(),
        '/home_page': (context) => const HomePage(),
        '/profile_page': (context) => const ProfilePage(),
        '/objects_page': (context) => const ObjectsPage(),
        'objects_page/fruits_obj': (context) => const fruitObj(),
        'objects_page/vegetables_obj': (context) => const vegetableObj(),
        'objects_page/packages_obj': (context) => const packageObj(),
        '/display_shape_obj': (context) => const DisplayShapes(),
        '/help_page': (context) => const HelpScreen(),
        '/tutor_list_page': (context) => const TutorListPage(), // Added route
        '/home_page1': (context) => const HomePage1(), // Added route
        '/community_page': (context) => const CommunityPage(),
        '/login': (context) => const LoginPage(onTap: null),
        
      },
    );
  }
}
