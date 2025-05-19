import 'package:ecstasyapp/mainScreens/Upload/Image_Video.dart';
import 'package:ecstasyapp/mainScreens/Upload/blog.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

class FileUploader extends StatefulWidget {
  const FileUploader({super.key});

  @override
  _FileUploaderState createState() => _FileUploaderState();
}

class _FileUploaderState extends State<FileUploader> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Set screen background to black
      body: Container(), // Main screen content placeholder
      bottomSheet: Container(
        color: Colors.black,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(36),
              topRight: Radius.circular(36),
            ),
            child: Container(
              color: const Color.fromRGBO(
                  55, 55, 55, 1), // Match bottom sheet background to UI
              height: 160, // Increased height to match proportions
              child: Column(
                children: [
                  // Icons and Labels Section
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        GestureDetector(
                          onTap: () async {
                            // File Picker for video
                            FilePickerResult? result =
                                await FilePicker.platform.pickFiles(
                              type: FileType.video,
                            );
                            if (result != null) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ImageVideoUploadPage(
                                      filePath: result.files.single.path!),
                                ),
                              );
                            }
                          },
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.video_library,
                                  size: 60, color: Colors.white),
                              SizedBox(
                                  height:
                                      12), // Increased spacing between icon and label
                              Text(
                                'Videos',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () async {
                            // File Picker for image
                            FilePickerResult? result =
                                await FilePicker.platform.pickFiles(
                              type: FileType.image,
                            );
                            if (result != null) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ImageVideoUploadPage(
                                      filePath: result.files.single.path!),
                                ),
                              );
                            }
                          },
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.photo_library,
                                  size: 60, color: Colors.white),
                              SizedBox(
                                  height:
                                      12), // Increased spacing between icon and label
                              Text(
                                'Photos',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => BlogUploadPage()));
                          },
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.article,
                                  size: 60, color: Colors.white),
                              SizedBox(
                                  height:
                                      12), // Increased spacing between icon and label
                              Text(
                                'Blogs',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Bottom Info Text Section
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: const TextSpan(
                        text: "You can also upload from the desktop website ",
                        style: TextStyle(color: Colors.white, fontSize: 11),
                        children: [
                          TextSpan(
                            text: "www.ecstasystage.com",
                            style: TextStyle(color: Colors.blue, fontSize: 11),
                          ),
                        ],
                      ),
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
