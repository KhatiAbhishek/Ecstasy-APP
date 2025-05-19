
import 'package:flutter/material.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:ecstasyapp/welcomeScreen/defaultProfile.dart';

class ContactScreen extends StatelessWidget {
  const ContactScreen({super.key});

  Future<void> _showPermissionDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // User must tap button to dismiss
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text('Request Contacts Access'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('This app needs access to your contacts.'),
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
                _requestContactsPermission(context); // Request permission
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _requestContactsPermission(BuildContext context) async {
    var status = await Permission.contacts.request();

    if (status.isGranted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Contacts access granted!')),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) =>
                ProfilePage(),),
      );
      _fetchContacts(); // Call the function to fetch contacts
    } else if (status.isDenied) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Permission denied!')),
      );
    } else if (status.isPermanentlyDenied) {
      // The user has denied the permission permanently
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                'Permission permanently denied. Go to settings to enable it.')),
      );
      openAppSettings(); // This opens the app settings page
    }
  }

  Future<void> _fetchContacts() async {
    Iterable<Contact> contacts = await ContactsService.getContacts();
    // You can process the contacts list here
    print(contacts);
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
                'assets/images/gif2.gif',
                width: double.infinity,
                height: 300,
                fit: BoxFit.cover,
              ),
            ),

            const SizedBox(
              height: 10,
            ),
            const Text(
              'Connect with your friends',
              style: TextStyle(color: Colors.white, fontSize: 22),
            ),
            const SizedBox(
              height: 10,
            ),
            const Text(
              'Hop on this artistic adventure where creativit is limitless and entertainment sparks new connection. Dive into a world of stunning art and enjoy a vibrant space that\'s all about making meaningful connections and exploring fresh experiences',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontSize: 12),
            ),
            const SizedBox(
              height: 50,
            ),
            const Text(
              'Ecstasy syncs your contacts so you can add friends and easily share the excitment with you loved ones',
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
                  onPressed: () => _showPermissionDialog(context),
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
                    'Access Contact',
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
                        builder: (context) =>  ProfilePage()));
              },
              child: Text(
                'Skip ',
                style: TextStyle(color: Colors.white, fontSize: 25),
              ))),
    );
  }
}
