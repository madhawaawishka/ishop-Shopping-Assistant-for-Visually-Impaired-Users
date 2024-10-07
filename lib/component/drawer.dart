import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:spm_project/auth/auth.dart';

class CustomDrawer extends StatefulWidget {
  const CustomDrawer({super.key});

  void logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const AuthPage()),
    );
  }

  @override
  State<CustomDrawer> createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Theme.of(context).colorScheme.surface,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            children: [
              DrawerHeader(
                child: Image.asset(
                  'assets/logo.png',
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(
                height: 25,
              ),
              // Padding(
              //   padding: const EdgeInsets.only(left: 25.0),
              //   child: ListTile(
              //     leading: Icon(
              //       Icons.home,
              //       color: Theme.of(context).colorScheme.inversePrimary,
              //     ),
              //     title: Text("HOME"),
              //     onTap: () {
              // Navigator.pushNamed(context, "/home_page");
              //     },
              //   ),
              // ),
              Padding(
                padding: const EdgeInsets.only(left: 25.0),
                child: ListTile(
                  leading: Icon(
                    Icons.person,
                    color: Theme.of(context).colorScheme.inversePrimary,
                  ),
                  title: const Text("PROFILE"),
                  onTap: () {
                    Navigator.pushNamed(context, '/profile_page');
                  },
                ),
              ),
              // Padding(
              //   padding: const EdgeInsets.only(left: 25.0),
              //   child: ListTile(
              //     leading: Icon(
              //       _speechToText.isListening ? Icons.mic : Icons.mic_none,
              //       color: Theme.of(context).colorScheme.inversePrimary,
              //     ),
              //     title: const Text("VOICE COMMAND"),
              //     onTap: _speechEnabled ? _startListening : _stopListening,
              //   ),
              // ),
              Padding(
                padding: const EdgeInsets.only(left: 25.0),
                child: ListTile(
                  leading: Icon(
                    Icons.apple,
                    color: Theme.of(context).colorScheme.inversePrimary,
                  ),
                  title: const Text("FRUITS"),
                  onTap: () {
                    Navigator.pushNamed(context, '/fruits_obj');
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 25.0),
                child: ListTile(
                  leading: Icon(
                    Icons.food_bank,
                    color: Theme.of(context).colorScheme.inversePrimary,
                  ),
                  title: const Text("VEGETABLES"),
                  onTap: () {
                    Navigator.pushNamed(context, '/vegetables_obj');
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 25.0),
                child: ListTile(
                  leading: Icon(
                    Icons.shop,
                    color: Theme.of(context).colorScheme.inversePrimary,
                  ),
                  title: const Text("PACKAGES"),
                  onTap: () {
                    Navigator.pushNamed(context, '/packages_obj');
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 25.0),
                child: ListTile(
                  leading: Icon(
                    Icons.save_alt,
                    color: Theme.of(context).colorScheme.inversePrimary,
                  ),
                  title: const Text("SAVED OBJECT"),
                  onTap: () {
                    Navigator.pushNamed(context, '/display_shape_obj');
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
