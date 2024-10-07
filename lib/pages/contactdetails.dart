import 'package:flutter/material.dart';
import 'package:spm_project/pages/call_page.dart';

class ContactDetailsPage extends StatelessWidget {
  final String phoneNumber; // Accept the phone number
  ContactDetailsPage({super.key, required this.phoneNumber});

  final TextEditingController textEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    // Pre-fill the text controller with the phone number
    textEditingController.text = phoneNumber;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.lightBlue, // Same color as HomePage
        title: const Text(
          'Join a Call',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              const Text(
                'Call ID',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: textEditingController, // Use the pre-filled controller
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  labelText: 'Enter Call ID',
                  prefixIcon: const Icon(Icons.call, color: Colors.black),
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                onPressed: () {
                  // Navigates to CallPage with the entered CallID
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          CallPage(CallID: textEditingController.text),
                    ),
                  );
                },
                icon: const Icon(Icons.videocam),
                label: const Text(
                  'Join a Call',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500,color: Colors.black,),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.lightBlue, // Use deep purple for button
                  padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
