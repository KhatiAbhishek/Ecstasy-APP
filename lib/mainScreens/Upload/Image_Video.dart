import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:ecstasyapp/mainScreens/navigator.dart';
import 'package:ecstasyapp/mainScreens/upload.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ecstasyapp/constants.dart';


class ImageVideoUploadPage extends StatefulWidget {
  final String filePath;

  const ImageVideoUploadPage({Key? key, required this.filePath})
      : super(key: key);

  @override
  _ImageVideoUploadPageState createState() => _ImageVideoUploadPageState();
}

class _ImageVideoUploadPageState extends State<ImageVideoUploadPage> {
  VideoPlayerController? _videoController;
  bool _isPlayPauseVisible = true; // Visibility of the play/pause button
  Timer? _hideControlsTimer; // Timer to hide controls after a delay
  bool _isUploading = false; // Track upload status
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final String apiBaseUrl = AppConfig.apiBaseUrl;

  @override
  void initState() {
    super.initState();

    // Initialize video controller if the file is a video
    if (widget.filePath.endsWith('.mp4') || widget.filePath.endsWith('.mov')) {
      _videoController = VideoPlayerController.file(File(widget.filePath))
        ..initialize().then((_) {
          setState(() {}); // Refresh to show video player once initialized
        });
    }
  }

  void _togglePlayPause() {
    if (_videoController != null) {
      if (_videoController!.value.isPlaying) {
        _videoController!.pause();
        _resetHideControlsTimer();
      } else {
        _videoController!.play();
        _startHideControlsTimer(); // Start hiding controls after a delay
      }
      setState(() {});
    }
  }

  void _startHideControlsTimer() {
    _hideControlsTimer?.cancel(); // Cancel any existing timer
    _hideControlsTimer = Timer(const Duration(seconds: 3), () {
      setState(() {
        _isPlayPauseVisible = false;
      });
    });
  }

  void _resetHideControlsTimer() {
    setState(() {
      _isPlayPauseVisible = true;
    });
    _hideControlsTimer?.cancel(); // Cancel any existing timer
  }

  @override
  void dispose() {
    _videoController?.dispose();
    _hideControlsTimer?.cancel();
    super.dispose();
  }

Future<void> _generateSignedUrlAndCreatePost(File file) async {
  final String filename = file.path.split('/').last;
  if (!filename.contains('.')) {
    throw Exception("File must have a valid extension.");
  }
  final String mimeType = lookupMimeType(file.path) ?? 'application/octet-stream';
  // Use the full mimeType instead of splitting it
  final String contentType = mimeType; // e.g., "video/mp4" or "image/jpeg"

  try {
    setState(() {
      _isUploading = true;
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    final String idToken = prefs.getString('idToken') ?? '';
    final String subValue = prefs.getString('sub') ?? '';
    final String phoneNumber = prefs.getString('phoneNumber') ?? '';
    final String userId = prefs.getString('userId') ?? '';
   
    
    
    if (idToken.isEmpty || subValue.isEmpty || phoneNumber.isEmpty) {
      throw Exception("Required authentication data is missing. Please log in again.");
    }

    // Step 1: Generate Signed URL
    final Uri signedUrlUri = Uri.parse("$apiBaseUrl/api/v2/file/upload");
    final signedUrlResponse = await http.post(
      signedUrlUri,
      headers: {
        'Authorization': 'Bearer $idToken',
        'sub': subValue,
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        "filename": filename,
        "contentType": contentType, // Send full MIME type
      }),
    );

    print("Raw Response Body: ${signedUrlResponse.body}"); // Debugging

    if (signedUrlResponse.statusCode != 200) {
      throw Exception("Failed to generate signed URL: ${signedUrlResponse.statusCode} - ${signedUrlResponse.body}");
    }

    final Map<String, dynamic> signedUrlData = jsonDecode(utf8.decode(signedUrlResponse.bodyBytes));

    // Validate response structure
    if (!signedUrlData.containsKey('success') || signedUrlData['success'] != true || !signedUrlData.containsKey('data') || !signedUrlData['data'].containsKey('getUrl')) {
      throw Exception("Invalid response structure: ${signedUrlResponse.body}");
    }

    final String getUrl = signedUrlData['data']['getUrl'];

    // Step 2: Create Post
    final Uri postUri = Uri.parse("$apiBaseUrl/api/v1/post");
    final postResponse = await http.post(
      postUri,
      headers: {
        'Authorization': 'Bearer $idToken',
        'sub': subValue,
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        "data": {
          "userId": userId,
          "title": _titleController.text,
          "description": _descriptionController.text,
          "filename": filename,
          "contentUrl": getUrl,
          "createdBy": phoneNumber,
          "published": false,

        }
      }),
    );

    if (postResponse.statusCode == 200 || postResponse.statusCode == 201) {
      showSuccessDialog();
    } else {
      throw Exception("Failed to create post: ${postResponse.statusCode} - ${postResponse.body}");
    }
  } catch (e) {
    print("Error: $e"); // Debugging line
    showError("Error: $e");
  } finally {
    setState(() {
      _isUploading = false;
    });
  }
}


  void showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent dismissing by tapping outside
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20), // Rounded edges
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  'Uploaded',
                  style: TextStyle(
                    color: Colors.lightBlue,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Creating Art is a tiring venture. You can now sit back and relax.\nLeave the rest to Ecstasy.',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                // Green Circle with Check Icon
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    color: Colors.black,
                    size: 60,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Video will be live on platform after MRS approval.\nYou’ll receive the notification for approval/disapproval.',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                const Text(
                  'For more info visit - http://www.ecstasystage.com/community/guidelines',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 10,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                        context, MaterialPageRoute(builder: (context) => NavigatorScreen()));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.lightBlue, // Button color
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Close',style: TextStyle(color: Colors.white),),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message, style: TextStyle(color: Colors.red)),
      backgroundColor: Colors.black,
    ));
  }

  void showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message, style: TextStyle(color: Colors.green)),
      backgroundColor: Colors.black,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.black, // Set the background to black
        
        body: SingleChildScrollView(
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Upload Text Section
                  Stack(
                    children: [
                      Align(
                        alignment: Alignment.topLeft,
                        child: GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Icon(Icons.arrow_back,color:Colors.white, size: 28,)),
                      ),
                      Align(
                        alignment: Alignment.center,
                        child: const Text(
                          'Upload',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20, // Slightly larger font
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: _isUploading
                              ? null
                              : () async {
                                  File file = File(widget.filePath);
                                  if (file.existsSync()) {
                                    await _generateSignedUrlAndCreatePost(file);
                                  } else {
                                    showError("File does not exist.");
                                  }
                                },
                          child: const Text(
                            'Share',
                            style: TextStyle(
                              color: Colors.blue,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  
                  // Image/Video Display Container
                  GestureDetector(
                    onTap: () {
                      _resetHideControlsTimer(); // Show controls when tapped
                    },
                    child: Container(
                      width: double.infinity,
                      height: 370, 
                      color: Colors.black, // Black background for the container
                      child: widget.filePath.endsWith('.mp4') ||
                              widget.filePath.endsWith('.mov')
                          ? _videoController != null &&
                                  _videoController!.value.isInitialized
                              ? Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    AspectRatio(
                                      aspectRatio:
                                          _videoController!.value.aspectRatio,
                                      child: VideoPlayer(_videoController!),
                                    ),
                                    if (_isPlayPauseVisible)
                                      Positioned(
                                        child: IconButton(
                                          icon: Icon(
                                            _videoController!.value.isPlaying
                                                ? Icons.pause
                                                : Icons.play_arrow,
                                            size: 60,
                                            color: Colors.white,
                                          ),
                                          onPressed: _togglePlayPause,
                                        ),
                                      ),
                                  ],
                                )
                              : const Center(
                                  child: CircularProgressIndicator(
                                      color: Colors.white))
                          : widget.filePath.endsWith('.jpg') ||
                                  widget.filePath.endsWith('.jpeg') ||
                                  widget.filePath.endsWith('.png')
                              ? Image.file(
                                  File(widget.filePath),
                                  fit: BoxFit.cover,
                                )
                              : const SizedBox
                                  .shrink(), // Empty if file type is unknown
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Title Section
                  const Text(
                    'Title',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _titleController,
                    style: const TextStyle(color: Colors.white),
                    maxLength: 25,
                    decoration: InputDecoration(
                      hintText: 'Your 25 character Title',
                      hintStyle: const TextStyle(color: Colors.white),
                      filled: true,
                      fillColor: const Color.fromRGBO(55, 55, 55, 1),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide.none,
                      ),
                      counterText: '',
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Description Section
                  const Text(
                    'Description',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                     controller: _descriptionController,
                    style: const TextStyle(color: Colors.white),
                    maxLength: 500,
                    maxLines: 5,
                    decoration: InputDecoration(
                      hintText: 'Your 500 character description about the video.',
                      hintStyle: const TextStyle(color: Colors.white),
                      filled: true,
                      fillColor: const Color.fromRGBO(55, 55, 55, 1),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide.none,
                      ),
                      counterText: "",
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
