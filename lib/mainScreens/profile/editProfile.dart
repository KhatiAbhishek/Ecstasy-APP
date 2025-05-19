import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ecstasyapp/constants.dart';

class EditProfileScreen extends StatefulWidget {
  final String? profilePhoto; // Add this to accept profile photo

  const EditProfileScreen({Key? key, this.profilePhoto}) : super(key: key);

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  File? _profileImage;
  
  
  final TextEditingController _stageNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final String apiBaseUrl = AppConfig.apiBaseUrl;
  

  // Function to pick an image
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _profileImage = File(image.path);
      });
    }
  }

  // Function to save profile
  Future<void> _saveProfile() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final idToken = prefs.getString('idToken') ?? '';
    final sub = prefs.getString('sub') ?? '';
    final userId = prefs.getString('userId') ?? '';

    if (idToken.isEmpty || sub.isEmpty || userId.isEmpty) {
      debugPrint("Missing authentication data");
      return;
    }

    // Prepare data
    final String email = _emailController.text;
    final String stageName = _stageNameController.text;
    final String description = _descriptionController.text;
    final String apiUrl =
        "$apiBaseUrl/api/v1/user/$userId";

    // Prepare request headers
    final headers = {
      'Authorization': 'Bearer $idToken',
      'sub': sub,
      'Content-Type': 'application/json',
    };

    // Prepare request body
    final Map<String, dynamic> body = {
      "email": email,
      "description": description,
      "stage_name": stageName,
      "profile_photo": _profileImage != null ? _profileImage!.path.split('/').last : ''
    };

    try {
      final response = await http.put(
        Uri.parse(apiUrl),
        headers: headers,
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        debugPrint("Profile updated successfully");
        Navigator.pop(context); // Navigate back after successful update
      } else {
        debugPrint("Failed to update profile: ${response.body}");
      }
    } catch (e) {
      debugPrint("Error updating profile: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          elevation: 0,
          automaticallyImplyLeading: false,
          title: Padding(
            padding: const EdgeInsets.only(top: 40),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text(
                    "Cancel",
                    style: TextStyle(
                      color: Colors.blue,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Text(
                  "Profile",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: _saveProfile,
                  child: const Text(
                    "Save",
                    style: TextStyle(
                      color: Colors.blue,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
            child: Column(
              children: [
                const SizedBox(height: 40),
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        image: DecorationImage(
                          image: _profileImage != null
                              ? FileImage(_profileImage!)
                              : const AssetImage('assets/images/profile_photo.png')
                                  as ImageProvider,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: -10,
                      right: -10,
                      child: GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          width: 32,
                          height: 32,
                          child: Image.asset(
                            "assets/images/imageEdit.png",
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 100),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTextField("Stagename", _stageNameController),
                      const SizedBox(height: 50),
                      _buildTextField("Email", _emailController),
                      const SizedBox(height: 50),
                      _buildTextField("Description", _descriptionController),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper function to build text fields
  Widget _buildTextField(String label, TextEditingController controller) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 16),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(width: 30),
        Expanded(
          child: TextField(
            controller: controller,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              filled: true,
              fillColor: Colors.black,
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Color.fromRGBO(125, 125, 125, 1)),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
