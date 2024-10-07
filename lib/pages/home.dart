import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:spm_project/component/drawer.dart';
import 'package:spm_project/component/voice.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // For handling time-based greetings

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  FlutterTts flutterTts = FlutterTts();
  String username = 'User';
  String greetingMessage = 'Hello'; // Default greeting

  @override
  void initState() {
    super.initState();
    getUsernameAndGreet();
    updateGreetingMessage(); // Update greeting based on time of day
  }

  Future<void> getUsernameAndGreet() async {
    try {
      // Get the current user
      User? currentUser = FirebaseAuth.instance.currentUser;

      // Fetch the user's document from Firestore
      if (currentUser != null) {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('Users') // Ensure the collection name is correct
            .doc(currentUser.uid)
            .get();

        if (userDoc.exists) {
          setState(() {
            username = userDoc['username'] ?? 'User';
          });

          // Greet the user using TTS
          await _speak("$greetingMessage, $username. You are on the home page.");
        }
      }
    } catch (e) {
      print("Error fetching user data: $e");
    }
  }

  void updateGreetingMessage() {
    final hour = DateTime.now().hour;

    if (hour < 12) {
      greetingMessage = 'Good Morning';
    } else if (hour < 18) {
      greetingMessage = 'Good Afternoon';
    } else {
      greetingMessage = 'Good Evening';
    }

    setState(() {}); // Update the UI after setting the greeting
  }

  Future<void> _speak(String text) async {
    await flutterTts.setLanguage("en-US");
    await flutterTts.setPitch(1.0);
    await flutterTts.speak(text);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text("HOME"),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        drawer: const CustomDrawer(),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "$greetingMessage, $username!",
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(16.0),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, // Two rectangles per row
                  crossAxisSpacing: 16.0,
                  mainAxisSpacing: 16.0,
                  childAspectRatio: 1, // Square cards
                ),
                itemCount: 6, // Number of navigation cards
                itemBuilder: (context, index) {
                  // Map index to your navigation cards
                  final navigationItems = [
                    ['Profile', 'assets/homeicons/profile.png', '/profile_page'],
                    ['Objects', 'assets/homeicons/objectidentification.png', '/objects_page'],
                    ['Emergency', 'assets/homeicons/emergency.png', '/tutor_list_page'],
                    ['Saved Object', 'assets/homeicons/savedobjects.png', '/display_shape_obj'],
                    ['Video call', 'assets/homeicons/videocall.png', '/home_page1'],
                    ['Community', 'assets/homeicons/community.png', '/community_page'],
                  ];

                  return _buildNavigationCard(
                    navigationItems[index][0], // Text
                    navigationItems[index][1], // Image path
                    navigationItems[index][2], // Route
                  );
                },
              ),
            ),
            SpeechButton(
              onCaptureCommand: () {},
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to build navigation cards with images
  Widget _buildNavigationCard(String text, String imagePath, String route) {
    return Card(
      elevation: 4.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(context, route);
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Display the image in the center
              Expanded(
                child: Center(
                  child: Image.asset(
                    imagePath,
                    fit: BoxFit.contain, // Ensure the image fits properly
                    height: 80, // Set the desired size for the image
                    width: 80,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              // Align the text at the bottom of the card
              Text(
                text,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
