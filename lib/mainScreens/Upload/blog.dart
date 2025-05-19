import 'package:flutter/material.dart';

class BlogUploadPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Set the background to black
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 30,horizontal: 27),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Stack(
                children: [
                  Align(
                    alignment: Alignment.center,
                    child: Text(
                      'Upload',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20, // Slightly larger font
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        // Add your Share functionality here
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
              const SizedBox(height: 50),
        
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
        
              // Link Section
              const Text(
                'Link',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'The URL of your blog',
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
    );
  }
}
