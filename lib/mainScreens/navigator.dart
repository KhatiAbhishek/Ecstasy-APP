
import 'package:ecstasyapp/mainScreens/NotificationScreen.dart';
import 'package:ecstasyapp/mainScreens/chatScreen.dart';
import 'package:ecstasyapp/mainScreens/feedScreen.dart';

import 'package:ecstasyapp/mainScreens/profileScreen.dart';
import 'package:ecstasyapp/mainScreens/upload.dart';
import 'package:flutter/material.dart';

class NavigatorScreen extends StatefulWidget {
  const NavigatorScreen({super.key});

  @override
  _NavigatorScreenState createState() => _NavigatorScreenState();
}

class _NavigatorScreenState extends State<NavigatorScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    //Add screens.
    FeedScreen(),
     NotificationScreen(),
    const FileUploader(),
    ChatScreen(),
    const ProfileScreen()
  ];

   void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: _pages[_currentIndex],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: _onItemTapped,
           backgroundColor: Colors.black,
          selectedItemColor: Colors.grey[700], // Change to the color you want when selected
          unselectedItemColor: Colors.grey[200], // Change to the color you want when unselected
          showUnselectedLabels: false,
          showSelectedLabels: false,
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(
              icon: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image(image: AssetImage("assets/images/home_icon.png"))
                  // Icon(Icons.add_shopping_cart, size: 30), // Increase icon size
                ],
              ),
              label: '', // Remove label
            ),
            BottomNavigationBarItem(
              icon: Column(
                
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image(image: AssetImage("assets/images/notification_Icon.png"))
                
                ],
              ),
              label: '', // Remove label
            ),
            BottomNavigationBarItem(
              icon: Column(
                
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image(image: AssetImage("assets/images/add_icon.png"))
                
                ],
              ),
              label: '', // Remove label
            ),
            
            BottomNavigationBarItem(
              icon: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image(image: AssetImage("assets/images/chat_icon.png"))
                ],
              ),
              label: '', // Remove label
            ),
            BottomNavigationBarItem(
              icon: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image(image: AssetImage("assets/images/profile_icon.png"))
                ],
              ),
              label: 'Profile', // Remove label
              
            ),
            
          ],
        ),
      ),
    );
  }
}
