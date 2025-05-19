import 'package:ecstasyapp/mainScreens/navigator.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ecstasyapp/constants.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  File? _profileImage; // To hold the selected profile image
  final TextEditingController _stageNameController = TextEditingController(); // Controller for "Stage name" TextField
  final String apiBaseUrl = AppConfig.apiBaseUrl;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _saveProfileData() async {
  final apiUrl = '$apiBaseUrl/api/v1/user';

  // Retrieve stored values from SharedPreferences
  SharedPreferences prefs = await SharedPreferences.getInstance();
  final String? idToken = prefs.getString('idToken');
  final String? sub = prefs.getString('sub');
  final String? phoneNumber = prefs.getString('phoneNumber');
  final String? countryCode = prefs.getString('countryCode');
  final String? deviceId = prefs.getString('deviceId');

  // Debugging: Print retrieved values
  print("idToken: $idToken");
  print("sub: $sub");
  print("phoneNumber: $phoneNumber");
  print("countryCode: $countryCode");
  print("deviceId: $deviceId");

  // Ensure all required values are available
  if (idToken == null || idToken.isEmpty || 
      sub == null || sub.isEmpty || 
      phoneNumber == null || phoneNumber.isEmpty || 
      deviceId == null || deviceId.isEmpty || 
      countryCode == null || countryCode.isEmpty) {
    
    print("Error: Missing essential data. Please log in again.");
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Missing essential data. Please log in again.")),
    );
    return;
  }

  // Construct the full phone number with the country code
  final fullPhoneNumber = "$countryCode$phoneNumber";

  // Use the selected profile image or default to a placeholder
  final profilePhoto = _profileImage?.path ?? "assets/images/defaultProfile.png";

  final stageName = _stageNameController.text;

  // Debugging: Print request payload before sending
  final body = jsonEncode({
    "email": "",
    "sub": sub,
    "name": "",
    "type": "ANDROID",
    "role": "AUDIENCE",
    "phone_number": fullPhoneNumber,
    "stage_name": stageName,
    "profile_photo": profilePhoto,
    "createdBy": phoneNumber,
    "Devices": {
      "create": [
        {"deviceId": deviceId}
      ]
    }
  });

  print("Request Body: $body");

  // Prepare headers
  final headers = {
    "Content-Type": "application/json",
    "Authorization": "Bearer $idToken",
    "sub": sub,
  };

 try {
  final response = await http.post(
    Uri.parse(apiUrl),
    headers: headers,
    body: body,
  );

  print("Response Status Code: ${response.statusCode}");
  print("Response Body: ${response.body}");

  if (response.statusCode == 200 || response.statusCode == 201) {
    final Map<String, dynamic> data = json.decode(response.body);
    
    // Debugging print statements
    print("Decoded Response Data: $data");

    if (data.containsKey("data") && data["data"].containsKey("userId")) {
      final String userId = data["data"]["userId"];
      
      // Debugging print statement
      print("Extracted userId: $userId");
      
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('userId', userId);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profile saved successfully!")),
      );

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const NavigatorScreen()),
      );
    } else {
      print("Error: userId is null in response!");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error: userId is null in response!")),
      );
    }
  } else {
    print("HTTP Error: ${response.statusCode}");
    print("Error Response: ${response.body}");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Error: ${response.body}")),
    );
  }
} catch (e) {
  print("Exception occurred: $e");
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text("Failed to save profile: $e")),
  );
}

}



  @override
  void dispose() {
    _stageNameController.dispose(); // Dispose of the controller when not needed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('Profile', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: TextButton(
              onPressed: () {
                
                // Validate that the "Stage name" field is not empty
                if (_stageNameController.text.isNotEmpty) {
                  _saveProfileData();
                } else {
                  // Show an alert if "Stage name" is empty
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Stage name cannot be empty")),
                  );
                }
              },
              child: const Text(
                'Save',
                style: TextStyle(color: Colors.blue, fontSize: 20),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Profile Image Section with GestureDetector for image picking
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10),
              height: 500, // Desired height for the profile image area
              width: double.infinity,
              child: GestureDetector(
                onTap: _pickImage, // Method to open image picker
                child: ClipRRect(
                  borderRadius: BorderRadius.zero, // Sharp corners
                  child: _profileImage != null
                      ? Image.file(
                          _profileImage!,
                          width: double.infinity,
                          height: 500, // Set height as per the container
                          fit: BoxFit.cover,
                        )
                      : Image.asset(
                          'assets/images/defaultProfile.png',
                          width: double.infinity,
                          height: 500,
                        ),
                ),
              ),
            ),

            const SizedBox(height: 30),

            // "Stage name" Text Field
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    'Stage name',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    '*',
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Image.asset(
                    'assets/images/suggestIcon.png',
                    width: 14,
                    fit: BoxFit.cover,
                  ),
                  Expanded(
                    child: TextField(
                      controller: _stageNameController,
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.black,
                        hintStyle: TextStyle(color: Colors.white),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
