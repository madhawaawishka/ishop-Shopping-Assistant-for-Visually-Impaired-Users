import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class EditContactPage extends StatefulWidget {
  const EditContactPage({
    Key? key,
    required this.avatar,
    required this.name,
    required this.phone,
    required this.email,
    required this.id,
  }) : super(key: key);

  final String avatar;
  final String name;
  final String phone;
  final String email;
  final String id;

  @override
  State<EditContactPage> createState() => _EditContactPageState();
}

class _EditContactPageState extends State<EditContactPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController nameController;
  late final TextEditingController phoneController;
  late final TextEditingController emailController;

  @override
  void initState() {
    nameController = TextEditingController(text: widget.name);
    phoneController = TextEditingController(text: widget.phone);
    emailController = TextEditingController(text: widget.email);
    super.initState();
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    super.dispose();
  }

  void editContact() async {
    if (_formKey.currentState!.validate()) {
      try {
        // Update the contact in Firestore
        await FirebaseFirestore.instance.collection('contacts').doc(widget.id).update({
          'name': nameController.text.trim(),
          'phone': phoneController.text.trim(),
          'email': emailController.text.trim(),
        });
        if (mounted) {
          Navigator.pop(context);
        }
      } on FirebaseException catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to update contact: ${e.message}")),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("An unexpected error occurred")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Edit Contact',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.lightBlue,
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Form(
            key: _formKey,
            child: Column(
              children: [
                Center(
                  child: Hero(
                    tag: widget.id,
                    child: CircleAvatar(
                      backgroundImage: NetworkImage(widget.avatar),
                      radius: 60,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                _buildTextFormField(
                  controller: nameController,
                  label: 'Name',
                  hintText: "Enter Name",
                  icon: Icons.person,
                ),
                const SizedBox(height: 20),
                _buildTextFormField(
                  controller: phoneController,
                  label: 'Phone',
                  hintText: "Enter Phone",
                  icon: Icons.phone,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 20),
                _buildTextFormField(
                  controller: emailController,
                  label: 'Email',
                  hintText: "Enter Email",
                  icon: Icons.email,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: editContact,
                    icon: const Icon(Icons.save, size: 24),
                    label: const Text(
                      "Save Contact",
                      style: TextStyle(fontSize: 18,color: Colors.black,),
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      backgroundColor: Colors.lightBlue,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    required String hintText,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.deepPurple[700],
          ),
        ),
        const SizedBox(height: 10),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          textInputAction: TextInputAction.next,
          validator: (value) {
            if (value!.isEmpty) {
              return "Please enter a valid $label";
            }
             // Add email validation if it's the email field
          if (label == 'Email') {
            String emailPattern = r'^[^@]+@[^@]+\.[^@]+';
            RegExp regExp = RegExp(emailPattern);
            if (!regExp.hasMatch(value)) {
              return "Please enter a valid email";
            }
          }
            return null;
          },
          decoration: InputDecoration(
            hintText: hintText,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            filled: true,
            fillColor: Colors.grey[100],
            prefixIcon: Icon(icon),
          ),
          style: const TextStyle(fontSize: 18),
        ),
      ],
    );
  }
}
