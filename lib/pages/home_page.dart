import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:spm_project/pages/add_contact_page.dart';
import 'package:spm_project/pages/contactdetails.dart';
import 'package:spm_project/pages/edit_contact_page.dart';
import 'package:pdf/widgets.dart' as pw; // PDF package
import 'package:path_provider/path_provider.dart'; // To get storage directory
import 'package:open_file/open_file.dart';// To view PDF
import 'package:intl/intl.dart'; // Import to format the date
import 'package:flutter_tts/flutter_tts.dart'; // Import TTS package

class HomePage1 extends StatefulWidget {
  const HomePage1({Key? key}) : super(key: key);

  @override
  State<HomePage1> createState() => _HomePage1State();
}

class _HomePage1State extends State<HomePage1> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  final contactsCollection = FirebaseFirestore.instance.collection("contacts");
   // Add this line to create an instance of FlutterTts
  final FlutterTts _flutterTts = FlutterTts();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });


     // Call the TTS welcome message here
    // _welcomeMessage();
  }


    // Function to read out loud the welcome message
  Future<void> _welcomeMessage() async {
    await _flutterTts.setLanguage("en-US"); // Set the language
    await _flutterTts.setSpeechRate(0.5); // Adjust the speech rate (optional)
    await _flutterTts.speak("Welcome to video call Screen"); // Speak the welcome message
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

    // Function to read out loud the contact name
  Future<void> _speak(String name) async {
    await _flutterTts.setLanguage("en-US"); // Set the language
    await _flutterTts.setSpeechRate(0.5); // Adjust the speech rate (optional)
    await _flutterTts.speak(name); // Speak the contact name
  }
  

  // Function to create and open the PDF
  Future<void> generateAndViewPDF(List<QueryDocumentSnapshot> contacts) async {
    final pdf = pw.Document();

    // Get the current date
    final String formattedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

   pdf.addPage(
  pw.Page(
    build: (pw.Context context) {
      return pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Contact List Report',
            style: pw.TextStyle(fontSize: 36, fontWeight: pw.FontWeight.bold), // Increased font size
          ),
          pw.SizedBox(height: 15), // Adjusted spacing
          pw.Text(
            'Generated on: $formattedDate',
            style: pw.TextStyle(fontSize: 22), // Increased font size
          ),
          pw.SizedBox(height: 10),
          pw.Text(
            'Total Contacts: ${contacts.length}',
            style: pw.TextStyle(fontSize: 22), // Increased font size
          ),
          pw.SizedBox(height: 25), // Adjusted spacing
          pw.Table(
            border: pw.TableBorder.all(width: 1.5), // Thicker table borders for better visibility
            columnWidths: {
              0: pw.FlexColumnWidth(2),
              1: pw.FlexColumnWidth(3),
              2: pw.FlexColumnWidth(3),
            },
            children: [
              // Table Header
              pw.TableRow(
                children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(10.0), // Increased padding
                    child: pw.Text(
                      'Name',
                      style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold), // Larger, bolder text
                    ),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(10.0),
                    child: pw.Text(
                      'Phone',
                      style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold), // Larger, bolder text
                    ),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(10.0),
                    child: pw.Text(
                      'Email',
                      style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold), // Larger, bolder text
                    ),
                  ),
                ],
              ),
              // Table Rows with Contact Data
              ...contacts.map((contact) {
                final contactData = contact.data() as Map<String, dynamic>;
                return pw.TableRow(
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(10.0),
                      child: pw.Text(
                        contactData['name'] ?? 'N/A',
                        style: pw.TextStyle(fontSize: 18), // Increased font size for data rows
                      ),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(10.0),
                      child: pw.Text(
                        contactData['phone'] ?? 'N/A',
                        style: pw.TextStyle(fontSize: 18), // Increased font size for data rows
                      ),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(10.0),
                      child: pw.Text(
                        contactData['email'] ?? 'N/A',
                        style: pw.TextStyle(fontSize: 18), // Increased font size for data rows
                      ),
                    ),
                  ],
                );
              }).toList(),
            ],
          ),
        ],
      );
    },
  ),
);


    // Get the directory to save the PDF file
    final output = await getTemporaryDirectory();
    final file = File("${output.path}/contacts.pdf");

    // Write the PDF to the file
    await file.writeAsBytes(await pdf.save());

    // Open the PDF file in a viewer
    await OpenFile.open(file.path);
  }

  @override
   Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Video Calls', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blue,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: () async {
              final contactsSnapshot = await contactsCollection.get();
              final List<QueryDocumentSnapshot> contacts = contactsSnapshot.docs;
              if (contacts.isNotEmpty) {
                await generateAndViewPDF(contacts);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('No contacts available to generate PDF.')),
                );
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search Contacts',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder(
              stream: _searchQuery.isEmpty
                  ? contactsCollection.snapshots()
                  : contactsCollection
                      .where('name', isGreaterThanOrEqualTo: _searchQuery)
                      .where('name', isLessThanOrEqualTo: '$_searchQuery\uf8ff')
                      .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final List<QueryDocumentSnapshot> documents = snapshot.data!.docs;
                  if (documents.isEmpty) {
                    return const Center(
                      child: Text(
                        "No Contacts yet",
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.w500, color: Colors.black54),
                      ),
                    );
                  }
                  return ListView.builder(
                    itemCount: documents.length,
                    itemBuilder: (context, index) {
                      final contact = documents[index].data() as Map<String, dynamic>;
                      final contactId = documents[index].id;
                      final String name = contact["name"];
                      final String email = contact["email"];
                      final String phone = contact["phone"];
                      final String avatar = 'https://randomuser.me/api/portraits/${index % 2 == 0 ? "men" : "women"}/$index.jpg';

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                        child: Dismissible(
                          key: Key(contactId),
                          background: Container(
                            color: Colors.blue,
                            alignment: Alignment.centerLeft,
                            padding: const EdgeInsets.only(left: 20),
                            child: const Icon(Icons.edit, color: Colors.white),
                          ),
                          secondaryBackground: Container(
                            color: Colors.red,
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            child: const Icon(Icons.delete, color: Colors.white),
                          ),
                          confirmDismiss: (direction) async {
                            if (direction == DismissDirection.startToEnd) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => EditContactPage(
                                    avatar: avatar,
                                    name: name,
                                    phone: phone,
                                    email: email,
                                    id: contactId,
                                  ),
                                ),
                              );
                              return false;
                            } else if (direction == DismissDirection.endToStart) {
                              await contactsCollection.doc(contactId).delete();
                              return true;
                            }
                            return false;
                          },
                          child: ListTile(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ContactDetailsPage(phoneNumber: phone),
                                ),
                              );
                            },
                            title: Text(
                              name,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                "$phone\n$email",
                                style: const TextStyle(fontSize: 16, color: Colors.black54),
                              ),
                            ),
                            leading: Hero(
                              tag: contactId,
                              child: CircleAvatar(
                                backgroundImage: NetworkImage(avatar),
                                radius: 30,
                              ),
                            ),
                            contentPadding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
                            tileColor: const Color.fromARGB(255, 191, 206, 213),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.volume_up),
                              onPressed: () => _speak(name), // Call speak function on button press
                            ),
                          ),
                        ),
                      );
                    },
                  );
                } else if (snapshot.hasError) {
                  return const Center(
                    child: Text(
                      "There was an Error",
                      style: TextStyle(fontSize: 18, color: Colors.red),
                    ),
                  );
                }
                return const Center(
                  child: CircularProgressIndicator.adaptive(
                    backgroundColor: Colors.deepPurple,
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const AddContactPage()));
        },
        label: const Text(
          "Add Contact",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.black),
        ),
        icon: const Icon(Icons.add),
        backgroundColor: Colors.blue,
      ),
    );
  }
}