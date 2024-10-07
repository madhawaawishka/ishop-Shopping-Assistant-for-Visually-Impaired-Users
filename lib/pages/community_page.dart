import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_firebase_project/pages/product.dart';
// import 'package:flutter_firebase_project/service/database.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:spm_project/pages/product.dart';

import '../service/database.dart';

class CommunityPage extends StatefulWidget {
  const CommunityPage({super.key});

  @override
  State<CommunityPage> createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage> {
  TextEditingController namecontroller = TextEditingController();
  TextEditingController agecontroller = TextEditingController();
  TextEditingController locationcontroller = TextEditingController();
  Stream<QuerySnapshot>? EmployeeStream;
  final FlutterTts flutterTts = FlutterTts(); // Initialize TTS
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>(); // Form Key

  getontheload() async {
    EmployeeStream = await DatabaseMethods().getEmployeeDetails();
    setState(() {});
  }

  @override
  void initState() {
    getontheload();
    super.initState();
    configureTts(); // Configure TTS on init
    speakWelcomeMessage(); // Speak the welcome message on init
  }

  Future<void> configureTts() async {
    await flutterTts.setLanguage('en-US');
    await flutterTts.setVolume(1.0);
    await flutterTts.setPitch(1.0);
  }

  Future<void> speakText(String text) async {
    await flutterTts.speak(text);
  }

  Future<void> speakWelcomeMessage() async {
    await speakText("This is the community page and we warmly welcome you");
  }

  // PDF generation function with dynamic Firestore data
  Future<void> generatePdf() async {
    final pdf = pw.Document();

    // Correct Firestore collection name: 'Employee'
    final snapshot =
        await FirebaseFirestore.instance.collection('Employee').get();
    final employeeDocs = snapshot.docs;

    // Build the table rows dynamically based on Firestore data
    List<pw.TableRow> tableRows = [
      pw.TableRow(
        children: [
          pw.Padding(
            padding: const pw.EdgeInsets.all(8.0),
            child: pw.Text(
              'Product Name',
              style: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  fontSize: 18), // Increased font size
            ),
          ),
          pw.Padding(
            padding: const pw.EdgeInsets.all(8.0),
            child: pw.Text(
              'Description',
              style: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  fontSize: 18), // Increased font size
            ),
          ),
          pw.Padding(
            padding: const pw.EdgeInsets.all(8.0),
            child: pw.Text(
              'Rating',
              style: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  fontSize: 18), // Increased font size
            ),
          ),
        ],
      ),
    ];

    // Adding each document's data as rows in the table
    for (var doc in employeeDocs) {
      tableRows.add(
        pw.TableRow(
          children: [
            pw.Padding(
              padding: const pw.EdgeInsets.all(8.0),
              child: pw.Text(
                doc['Name'],
                style: pw.TextStyle(
                    fontSize: 16), // Increased font size for content
              ),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(8.0),
              child: pw.Text(
                doc['Age'],
                style: pw.TextStyle(
                    fontSize: 16), // Increased font size for content
              ),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(8.0),
              child: pw.Text(
                doc['Location'],
                style: pw.TextStyle(
                    fontSize: 16), // Increased font size for content
              ),
            ),
          ],
        ),
      );
    }

    // Add a page to the PDF
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'Product Details',
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 20),
              pw.Table(
                border: pw.TableBorder.all(
                  color: PdfColors.grey, // Add table border color
                  width: 2.0, // Border thickness
                ),
                children: tableRows, // Adding rows to the table
              ),
            ],
          );
        },
      ),
    );

    // Save the PDF file
    final output = await getExternalStorageDirectory();
    final file = File("${output!.path}/product.pdf");

    await file.writeAsBytes(await pdf.save());
    OpenFile.open(file.path);
  }

  Widget allEmployeeDetails() {
    return StreamBuilder<QuerySnapshot>(
      stream: EmployeeStream,
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        // Check if data exists and has no errors
        if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        // Check if the snapshot contains any data
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text('No employee data found'),
          );
        }

        return ListView.builder(
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            DocumentSnapshot ds = snapshot.data!.docs[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 20.0),
              child: Card(
                elevation: 10.0,
                shadowColor: Colors.blue.withOpacity(0.2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(18.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              "Product: " + ds["Name"],
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              namecontroller.text = ds["Name"];
                              agecontroller.text = ds["Age"];
                              locationcontroller.text = ds["Location"];
                              EditEmployeeDetail(ds["Id"]);
                            },
                            child: const Icon(
                              Icons.edit,
                              color: Colors.orange,
                              size: 26,
                            ),
                          ),
                          const SizedBox(width: 10),
                          GestureDetector(
                            onTap: () async {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  title: const Text(
                                    "Delete Confirmation",
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  content: const Text(
                                      "Are you sure you want to delete this employee?"),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: const Text("Cancel"),
                                    ),
                                    TextButton(
                                      onPressed: () async {
                                        await DatabaseMethods()
                                            .deleteEmployeeDetail(ds["Id"]);
                                        Fluttertoast.showToast(
                                          msg: "Deleted successfully",
                                          toastLength: Toast.LENGTH_SHORT,
                                          gravity: ToastGravity.CENTER,
                                          timeInSecForIosWeb: 1,
                                          backgroundColor: Colors.red,
                                          textColor: Colors.white,
                                          fontSize: 16.0,
                                        );
                                        Navigator.of(context).pop();
                                      },
                                      child: const Text("Delete"),
                                    ),
                                  ],
                                ),
                              );
                            },
                            child: const Icon(
                              Icons.delete,
                              color: Colors.red,
                              size: 26,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "Description: " + ds["Age"],
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.black54,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          const Text(
                            "Rating: ",
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.black54,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                          buildStarRating(ds["Location"]),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: GestureDetector(
                          onTap: () {
                            String ttsText = "Product: ${ds['Name']}, "
                                "Description: ${ds['Age']}, "
                                "Rating: ${ds['Location']}";
                            speakText(ttsText); // Speak out the details
                          },
                          child: const Icon(
                            Icons.volume_up,
                            color: Colors.blue,
                            size: 30, // Size of the TTS icon
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // Widget to build star rating according to the rating value
  Widget buildStarRating(String rating) {
    int ratingValue = int.tryParse(rating) ?? 0; // Convert rating to integer
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return Icon(
          index < ratingValue ? Icons.star : Icons.star_border,
          color: index < ratingValue ? Colors.amber : Colors.grey,
          size: 24, // Adjusted size of the stars
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => Employee()));
        },
        backgroundColor: Colors.blue,
        shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(15), // More rounded corners for the button
        ),
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 10.0),
          child: Text(
            "Add",
            style: TextStyle(
              fontSize: 18, // Adjusted text size for better readability
              fontWeight: FontWeight.bold,
              color: Colors.white, // White text color
            ),
          ),
        ),
      ),
      appBar: AppBar(
        backgroundColor: Colors.blue,
        elevation: 8, // Gives a subtle shadow effect
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.group,
                size: 28, color: Colors.white), // Community-like icon
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  "Explore",
                  style: TextStyle(
                    fontSize: 22.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontFamily: 'Roboto', // Built-in font
                  ),
                ),
                Text(
                  "Communities",
                  style: TextStyle(
                    fontSize: 18.0,
                    color: Colors.white70,
                    fontFamily: 'Roboto', // Secondary font styling
                  ),
                ),
              ],
            ),
          ],
        ),
        centerTitle: true, // Centers the AppBar title
        actions: [
          IconButton(
            icon: const Icon(Icons.download,
                color: Colors.black), // Dark black icon
            onPressed: () {
              generatePdf(); // Call the PDF generation function
            },
          ),
        ],
      ),
      body: Container(
        margin: const EdgeInsets.only(left: 20.0, right: 20.0, top: 30.0),
        child: Column(
          children: [
            Expanded(child: allEmployeeDetails()),
          ],
        ),
      ),
    );
  }

  Future EditEmployeeDetail(String id) => showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          content: SingleChildScrollView(
            child: Form(
              key: _formKey, // Use form key here
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: const Icon(Icons.cancel, color: Colors.grey),
                      ),
                      const Spacer(),
                      const Text(
                        "Edit Details",
                        style: TextStyle(
                          color: Colors.deepPurple,
                          fontSize: 22.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(), // Centering the title
                    ],
                  ),
                  const SizedBox(height: 20.0),
                  const Text(
                    "Product",
                    style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                  ),
                  const SizedBox(height: 10.0),
                  TextFormField(
                    controller: namecontroller,
                    decoration: InputDecoration(
                      hintText: 'Enter Product Name',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a product name';
                      }
                      if (RegExp(r'[0-9]').hasMatch(value)) {
                        return 'Product name cannot contain numbers';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20.0),
                  const Text(
                    "Description",
                    style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                  ),
                  const SizedBox(height: 10.0),
                  TextFormField(
                    controller: agecontroller,
                    decoration: InputDecoration(
                      hintText: 'Enter Description',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a description';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20.0),
                  const Text(
                    "Rating",
                    style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                  ),
                  const SizedBox(height: 10.0),
                  TextFormField(
                    controller: locationcontroller,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: 'Enter Rating (1-5)',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a rating between 1 and 5';
                      }
                      final number = int.tryParse(value);
                      if (number == null || number < 1 || number > 5) {
                        return 'Rating must be between 1 and 5';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20.0),
                  Center(
                    child: GestureDetector(
                      onTap: () async {
                        if (_formKey.currentState!.validate()) {
                          // Use the form key to validate
                          await DatabaseMethods().updateEmployeeDetail(id, {
                            "Name": namecontroller.text,
                            "Age": agecontroller.text,
                            "Location": locationcontroller.text
                          });
                          Fluttertoast.showToast(
                            msg: "Updated Successfully",
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.CENTER,
                            timeInSecForIosWeb: 1,
                            backgroundColor: Colors.green,
                            textColor: Colors.white,
                            fontSize: 16.0,
                          );
                          Navigator.pop(context);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          "Update",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      );
}
