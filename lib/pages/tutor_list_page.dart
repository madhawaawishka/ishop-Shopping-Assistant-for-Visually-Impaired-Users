// lib/pages/tutor_list_page.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'chat_screen.dart';

class TutorListPage extends StatelessWidget {
  const TutorListPage({super.key});

  // Logout function
  Future<void> _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacementNamed(context, '/login'); // Navigate to login page
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      // Redirect to login if not authenticated
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, '/login');
      });
      return const Scaffold();
    }
    final studentId = currentUser.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Available Salesmen'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              _logout(context); // Call logout function
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('Users') // Ensure collection name matches your Firestore
            .where('role', isEqualTo: 'Tutor')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Error fetching tutors.'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final tutors = snapshot.data!.docs;

          if (tutors.isEmpty) {
            return const Center(child: Text('No tutors available.'));
          }

          return ListView.builder(
            itemCount: tutors.length,
            itemBuilder: (context, index) {
              final tutor = tutors[index];
              final tutorData = tutor.data() as Map<String, dynamic>;
              final tutorName = tutorData['username'] ?? 'Tutor';
              final tutorEmail = tutorData['email'] ?? '';

              return ListTile(
                leading: const CircleAvatar(
                  child: Icon(Icons.person),
                ),
                title: Text(tutorName),
                subtitle: Text(tutorEmail),
                onTap: () {
                  final tutorId = tutor.id;

                  // Navigate to ChatScreen with tutor details
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatScreen(
                        tutorId: tutorId,
                        tutorName: tutorName,
                        studentId: studentId,
                        studentName: 'Student', // You might want to fetch the student's name
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
