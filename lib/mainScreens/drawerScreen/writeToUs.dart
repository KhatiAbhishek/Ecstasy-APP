import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ecstasyapp/constants.dart';

class WriteToUsScreen extends StatelessWidget {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final String apiBaseUrl = AppConfig.apiBaseUrl;

  Future<void> _onShareButtonPressed(BuildContext context) async {
    final email = _emailController.text;
    final description = _descriptionController.text;

    // Validate email field
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Email field cannot be empty!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      // Retrieve data from SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final idToken = prefs.getString('idToken') ?? '';
      final String sub = prefs.getString('sub') ?? '';
      final String userId = prefs.getString('userId') ?? '';

      // API URL
      final String apiUrl = "$apiBaseUrl/api/v1/report/$userId";

      // API Body
      final Map<String, dynamic> body = {
        "data": {
            "email": email,
            "description": description,
        },
      };

      // API Call
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer $idToken',
          'sub': sub,
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );

      // Handle response
      if (response.statusCode == 200) {
        // Show success dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Dialog(
            backgroundColor: Color.fromRGBO(28, 28, 30, 1),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Thank you for bringing this to our notice',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 20),
                  Icon(
                    Icons.check_circle,
                    color: Color.fromRGBO(5, 255, 0, 1),
                    size: 80,
                  ),
                  SizedBox(height: 20),
                  Text(
                    'For more info visit: http://www.ecstasyapp.com/community-guidelines',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        },
      );

      // Close the dialog and navigate back after 3 seconds
      Future.delayed(Duration(seconds: 3), () {
        Navigator.of(context).pop(); // Close the dialog
        Navigator.of(context).pop(); // Navigate back
      });
    } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to share report. Try again later.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An error occurred: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }


void showSuccessDialog(BuildContext context) {
  showDialog(
  context: context,
  barrierDismissible: false, // Prevent dismissing by tapping outside
  builder: (BuildContext context) {
    return Dialog(
      backgroundColor: Color.fromRGBO(28, 28, 30, 1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Container(
        height: 500, // Increased height
        padding: const EdgeInsets.all(24.0), // Adjusted padding
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly, // Center content vertically
          
          children: [
            Text(
              'Thank you for bringing this to our notice',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14, // Slightly increased font size
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 0), // Increased spacing
            Icon(
              Icons.check_circle,
              color: Color.fromRGBO(5, 255, 0, 1),
              size: 180, // Increased icon size
            ),
            SizedBox(height: 30), // Increased spacing
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                children: [
                  TextSpan(
                    text: 'For more info visit: ',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 10,
                    ),
                  ),
                  TextSpan(
                    text: 'http://www.ecstasyapp.com/community-guidelines',
                    style: TextStyle(
                      color: Colors.blue, // Changed link color to blue
                      fontSize: 10,
                      decoration: TextDecoration.underline, // Added underline for emphasis
                    ),
                    // Optionally handle the link tap
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        // Handle link tap if necessary
                        print('Link tapped');
                      },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  },
);


  // // Close the dialog and pop the screen after a delay
  Future.delayed(Duration(seconds: 3), () {
    Navigator.of(context).pop(); // Close the dialog
    Navigator.of(context).pop(); // Navigate back to the previous screen
  });
}

  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 30.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        color: Colors.blue,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Text(
                    'Report',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => 
                    // _onShareButtonPressed(context),
                    showSuccessDialog(context),
                    child: Text(
                      'Share',
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
            SizedBox(height: 20),
            Column(
              children: [
                Image.asset(
                  'assets/images/profile_photo.png', // Replace with your image path
                  width: 100,
                  height: 100,
                ),
                SizedBox(height: 5.0),
                Text(
                  'Ecstasy',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 50),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  Text(
                    'We deeply appreciate your feedback, as it’s crucial for our evolution and improvement.\n\nThank you for your contribution.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                  SizedBox(height: 40.0),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 120,
                        child: Text(
                          "Email",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20, // Increased font size
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(width: 24),
                      Expanded(
                        child: TextField(
                          controller: _emailController,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18), // Adjusted font size
                          decoration: const InputDecoration(
                            hintStyle: TextStyle(
                                color: Colors.grey,
                                fontSize: 16), // Adjusted hint text size
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: Color.fromRGBO(125, 125, 125, 1),
                              ),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: Color.fromRGBO(125, 125, 125, 1),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 50), // Adjusted spacing
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 120,
                        child: Text(
                          "Description",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20, // Increased font size
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(width: 24),
                      Expanded(
                        child: TextField(
                          controller: _descriptionController,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18), // Adjusted font size
                          decoration: const InputDecoration(
                            hintStyle: TextStyle(
                                color: Colors.grey,
                                fontSize: 16), // Adjusted hint text size
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: Color.fromRGBO(125, 125, 125, 1),
                              ),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: Color.fromRGBO(125, 125, 125, 1),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
