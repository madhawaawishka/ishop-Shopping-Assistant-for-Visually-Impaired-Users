import 'package:flutter/material.dart';
import 'package:spm_project/component/voice.dart';

class ObjectsPage extends StatelessWidget {
  const ObjectsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Objects"),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16.0),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // Two items per row
                crossAxisSpacing: 16.0,
                mainAxisSpacing: 16.0,
                childAspectRatio: 1, // Make cards square
              ),
              itemCount: 3, // Total number of object cards
              itemBuilder: (context, index) {
                // Define the objects and their routes
                final objectItems = [
                  ['Fruits', 'assets/homeicons/fruits.png', 'objects_page/fruits_obj'],
                  ['Vegetables', 'assets/homeicons/vegetables.png', 'objects_page/vegetables_obj'],
                  ['Packages', 'assets/homeicons/packages.png', 'objects_page/packages_obj'],
                ];

                return _buildObjectCard(
                  objectItems[index][0] as String,
                  objectItems[index][1] as String,
                  objectItems[index][2] as String,
                  context,
                );
              },
            ),
          ),
          SpeechButton(
            onCaptureCommand: () {},
          ),
        ],
      ),
    );
  }

  // Helper method to build object cards
  Widget _buildObjectCard(String text, String imagePath, String route, BuildContext context) {
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
              // Replace Icon with Image.asset to display custom images
              Image.asset(
                imagePath,
                height: 80, // Set the desired size for the image
                width: 80,
                fit: BoxFit.cover,
              ),
              const SizedBox(height: 10),
              Text(
                text,
                style: const TextStyle(
                  fontSize: 20,
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
