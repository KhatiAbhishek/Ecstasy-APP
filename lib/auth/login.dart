import 'dart:convert';
import 'package:ecstasyapp/mainScreens/navigator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:ecstasyapp/welcomeScreen/galley_Screen.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ecstasyapp/constants.dart';

// flutter run -d chrome --web-browser-flag "--disable-web-security"

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  String deviceId = ''; // Initialize with an empty string
  String countryCode = '91'; // Default country code
  final String apiUrl = AppConfig.apiBaseUrl;

  @override
  void initState() {
    super.initState();
    _getDeviceId();
  }

  Future<void> _getDeviceId() async {
    try {
      DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      print('Android Device Info: ${androidInfo.toMap()}');

      setState(() {
        deviceId = androidInfo.id ?? 'Unavailable';
      });

      print('Device ID: $deviceId');
    } catch (e) {
      print('Error fetching device info: $e');
      setState(() {
        deviceId = 'Error';
      });
    }
  }

  Future<void> sendOtp() async {
    String phoneNumber = _phoneController.text.trim();

    if (phoneNumber.isEmpty || phoneNumber.length != 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please enter a valid 10-digit phone number')),
      );
      return;
    }

    String url = '$apiUrl/api/v1/otp/send';
    final Map<String, String> headers = {"Content-Type": "application/json"};
    final Map<String, dynamic> body = {
      "phone_number": "$countryCode$phoneNumber",
      "deviceId": deviceId,
      "type": "ANDROID",
    };

    try {
      print('Sending OTP request...');
      print('Request URL: $url');
      print('Request Headers: $headers');
      print('Request Body: ${json.encode(body)}');

      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: json.encode(body),
      );

      print('Response Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['success'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('OTP sent successfully')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Failed to send OTP. Please try again.')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Failed to send OTP. Please try again.')),
        );
      }
    } catch (e) {
      print('Error occurred: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> verifyOtp() async {
    String phoneNumber = _phoneController.text.trim();
    String otp = _otpController.text.trim();

    if (otp.isEmpty || otp.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid 6-digit OTP')),
      );
      return;
    }

    String url = '$apiUrl/api/v1/otp/verify';
    final Map<String, String> headers = {"Content-Type": "application/json"};
    final Map<String, dynamic> body = {
      "phone_number": "$countryCode$phoneNumber",
      "otp": otp,
      "deviceId": deviceId,
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: json.encode(body),
      );

      print('Response Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['success'] == true) {
          final data = responseData['data'];
          final idToken = data['idToken'];
          final sub = data['sub'];
          final String? userId = data['userId'];

          // Save values to SharedPreferences
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('deviceId', deviceId);
          await prefs.setString('phoneNumber', phoneNumber);
          await prefs.setString('countryCode', countryCode);
          await prefs.setString('idToken', idToken);
          await prefs.setString('sub', sub);
          // Save only if userId is not null
          if (userId != null) {
            await prefs.setString('userId', userId);
          }
          
          // Check if userId is null and navigate accordingly
          if (userId == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('OTP verified successfully')),
            );
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => GalleyScreen()),
            );
          } else {
            await prefs.setString('userId', userId);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('OTP verified successfully')),
            );
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => NavigatorScreen()),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Wrong OTP. Please try again.')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Wrong OTP. Please try again.')),
        );
      }
    } catch (e) {
      print('error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(50, 187, 255, 1),
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(50, 187, 255, 1),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white, size: 32),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text('Sign Up',
            style: TextStyle(color: Colors.white, fontSize: 20)),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 80),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Stack(
                children: [
                  Align(
                      alignment: Alignment.center,
                      child: Image.asset(
                        'assets/images/Logo.png',
                      )),
                  Align(
                      alignment: const Alignment(
                        0.03, // Adjust this to move toward the right.
                        0.0, //  0.0 to center vertically.
                      ),
                      child: Image.asset(
                        'assets/images/Polygon.png',
                        height: 125,
                      ))
                ],
              ),
              const SizedBox(height: 80),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 250,
                    height: 72,
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 0, 0),
                      child: IntlPhoneField(
                        controller: _phoneController,
                        keyboardType: TextInputType.number,
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        initialCountryCode: 'IN',
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.black,
                          hintText: 'Phone number',
                          hintStyle: const TextStyle(color: Colors.white),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        dropdownIcon: const Icon(
                          Icons.arrow_drop_down,
                          color: Colors.white, // Icon color to match the theme
                        ),
                        dropdownTextStyle: const TextStyle(
                          color: Colors
                              .white, // Set country code text color to white
                          fontSize:
                              17, // Adjust the font size of the country code selector
                        ),
                        style:
                            const TextStyle(color: Colors.white, fontSize: 17),
                        showCountryFlag:
                            false, // Currently Remove the country flag if not needed
                        disableLengthCheck:
                            true, // For removing the "invalid mobile number" message
                        onCountryChanged: (country) {
                          setState(() {
                            countryCode = country.dialCode;
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: sendOtp,
                    child: Image.asset(
                      'assets/images/codeOtp.png',
                      height: 83,
                      width: 40,
                      fit: BoxFit.fill,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(0, 0, 20, 0),
                  child: TextButton(
                    onPressed: sendOtp,
                    child: const Text('Re-request OTP',
                        style: TextStyle(color: Colors.white)),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Container(
                width: 296,
                height: 72,
                alignment: Alignment.center,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 0, 0),
                  child: TextField(
                    controller: _otpController,
                    keyboardType: TextInputType.number,
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.black,
                      hintText: 'CODE',
                      hintStyle: const TextStyle(color: Colors.white),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: 120,
                height: 54,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: verifyOtp,
                  //  onPressed:   () {
                  //   Navigator.push(
                  //       context,
                  //       MaterialPageRoute(
                  //           builder: (context) => NavigatorScreen()));
                  // },
                  child: const Text('Submit',
                      style: TextStyle(color: Colors.white, fontSize: 18)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
