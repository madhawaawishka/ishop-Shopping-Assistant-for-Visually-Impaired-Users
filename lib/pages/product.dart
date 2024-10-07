import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:random_string/random_string.dart';
import '../service/database.dart';

class Employee extends StatefulWidget {
  const Employee({super.key});

  @override
  State<Employee> createState() => _EmployeeState();
}

class _EmployeeState extends State<Employee> {
  TextEditingController namecontroller = TextEditingController();
  TextEditingController agecontroller = TextEditingController();
  TextEditingController locationcontroller = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text(
          "     Add Product Details",
          style: TextStyle(
            color: Colors.white,
            fontSize: 22.0,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Product",
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 20.0,
                      fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 10.0),
                TextFormField(
                  controller: namecontroller,
                  decoration: InputDecoration(
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 10.0),
                    hintText: "Enter product name",
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                        color: Colors.grey, // Default border color
                        width: 2.0, // Same border width as focused state
                      ),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                        color: Colors.blue, // Purple border on focus
                        width: 2.0, // Consistent width
                      ),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a product name';
                    }
                    // Check if the input contains numbers
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
                      color: Colors.black,
                      fontSize: 20.0,
                      fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 10.0),
                TextFormField(
                  controller: agecontroller,
                  decoration: InputDecoration(
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 10.0),
                    hintText: "Enter product description",
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                        color: Colors.grey, // Default border color
                        width: 2.0, // Same border width as focused state
                      ),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                        color: Colors.blue, // Purple border on focus
                        width: 2.0, // Consistent width
                      ),
                      borderRadius: BorderRadius.circular(10.0),
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
                  "Rating (1-5)",
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 20.0,
                      fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 10.0),
                TextFormField(
                  controller: locationcontroller,
                  keyboardType:
                      TextInputType.number, // Correct placement of keyboardType
                  decoration: InputDecoration(
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 10.0),
                    hintText: "Enter rating (1-5)",
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                        color: Colors.grey, // Default border color
                        width: 2.0, // Same border width as focused state
                      ),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                        color: Colors.blue, // Purple border on focus
                        width: 2.0, // Consistent width
                      ),
                      borderRadius: BorderRadius.circular(10.0),
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
                const SizedBox(height: 30.0),
                Center(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 50.0, vertical: 15.0),
                      backgroundColor: Colors.blue, // Use backgroundColor
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        String Id = randomAlphaNumeric(10);
                        Map<String, dynamic> employeeInfoMap = {
                          "Name": namecontroller.text,
                          "Age": agecontroller.text,
                          "Id": Id,
                          "Location": locationcontroller.text,
                        };
                        await DatabaseMethods()
                            .addEmployeeDetails(employeeInfoMap, Id)
                            .then((value) {
                          Fluttertoast.showToast(
                            msg: "Product has been added successfully",
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.CENTER,
                            timeInSecForIosWeb: 1,
                            backgroundColor: Colors.green,
                            textColor: Colors.white,
                            fontSize: 16.0,
                          );
                          Future.delayed(const Duration(seconds: 1), () {
                            Navigator.pop(context);
                          });
                        });
                      }
                    },
                    child: const Text(
                      "Add Product",
                      style: TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
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
}
