import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'chat_screen.dart';

class TutorHomePage extends StatelessWidget {
  const TutorHomePage({super.key});

  void _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    final User? tutor = FirebaseAuth.instance.currentUser;
    if (tutor == null) {
      // If not logged in, navigate to login page
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, '/login');
      });
      return const Scaffold();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('Users')
            .where('role', isEqualTo: 'Student')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Error loading students'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final students = snapshot.data!.docs;

          if (students.isEmpty) {
            return const Center(child: Text('No students available'));
          }

          return ListView.builder(
            itemCount: students.length,
            itemBuilder: (context, index) {
              final studentDoc = students[index];
              final studentData = studentDoc.data() as Map<String, dynamic>;
              final studentName = studentData['username'] ?? 'Student';
              final studentId = studentDoc.id;

              return ListTile(
                leading: CircleAvatar(
                  child: Text(
                    studentName.isNotEmpty ? studentName[0] : 'S',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                title: Text(studentName),
                onTap: () {
                  // Navigate to ChatScreen with student details
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatScreen(
                        tutorId: tutor.uid,
                        tutorName: 'Tutor',
                        studentId: studentId,
                        studentName: studentName,
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
