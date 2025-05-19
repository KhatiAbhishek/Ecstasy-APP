import 'package:ecstasyapp/welcomeScreen/contact_Screen.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class GalleyScreen extends StatelessWidget {
  const GalleyScreen({super.key});

    Future<void> _showPermissionDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // User must tap button to dismiss
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('This app needs access to your gallery to upload images and videos.'),
                Text('Do you want to grant access?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('No'),
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Close the dialog
              },
            ),
            TextButton(
              child: Text('Yes'),
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Close the dialog
                _requestGalleryPermission(context); // Request permission
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _requestGalleryPermission(BuildContext context) async {
    var status = await Permission.storage.request();


    if (status.isGranted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gallery access granted!')),
      );
      // You can navigate to the next page or perform additional actions here
      Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ContactScreen()),
    );
    } else if (status.isDenied) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Permission denied!')),
      );
       
    } else if (status.isPermanentlyDenied) {
      // The user has denied the permission permanently
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Permission permanently denied. Go to settings to enable it.')),
      );
      openAppSettings(); // This opens the app settings page
    }
  }

    

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                'assets/images/gif1.gif',
                height: 300,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            const Text(
              'Exhibit your Art',
              style: TextStyle(color: Colors.white, fontSize: 22),
            ),
            const SizedBox(
              height: 10,
            ),
            const Text(
              'Creatng Art is a tiring venture. We are here to amplify your artistic journey and shine together',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontSize: 12),
            ),
            const SizedBox(
              height: 50,
            ),
            const Text(
              'A fresh sace that connects artists with their audience. Artists get to display their impressive work and audiences can explore and effortessly spread the art love with their circle.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color.fromRGBO(50, 187, 255, 1),
                fontSize: 12,
              ),
            ),
            const SizedBox(
              height: 8,
            ),
            SizedBox(
              width: double.infinity,
              height: 70,
              child: ElevatedButton(
                  onPressed: () {
                    _showPermissionDialog(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromRGBO(50, 187, 255, 1),
                    padding: const EdgeInsets.symmetric(
                      vertical: 15,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Access Gallery',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.w300),
                  )),
            )
          ],
        ),
      ),
      bottomSheet: Container(
        color: Colors.black,
          child: TextButton(
              onPressed: () {
                 //Skip to next page
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const ContactScreen()));
              },
              child: Text(
                'Skip ',
                style: TextStyle(color: Colors.white,fontSize: 25),
              ))),
    );
  }
}
