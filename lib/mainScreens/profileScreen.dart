import 'dart:io';
import 'package:blur/blur.dart';
import 'package:ecstasyapp/mainScreens/drawerScreen/friendRequest.dart';
import 'package:ecstasyapp/mainScreens/drawerScreen/writeToUs.dart';
import 'package:flutter/material.dart';
import 'package:ecstasyapp/mainScreens/profile/editProfile.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ecstasyapp/constants.dart';


class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? userDetails;
  List<Map<String, dynamic>> posts = []; // Changed to empty list
  bool isLoading = true;
  String? errorMessage;
  final String apiBaseUrl = AppConfig.apiBaseUrl;


  @override
  void initState() {
    super.initState();
    fetchUserDetails();
  }

  // Updated fetch user details with new API
  Future<void> fetchUserDetails() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final idToken = prefs.getString('idToken') ?? '';
      final sub = prefs.getString('sub') ?? '';
      final userId = prefs.getString('userId') ?? '';

      final url =
          '$apiBaseUrl/api/v1/post/$userId?limit=10&offset=0';

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $idToken',
          'sub': sub,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = json.decode(response.body);
        if (responseData['success'] == true) {
          setState(() {
            userDetails = responseData['data']['user'];
            posts = List<Map<String, dynamic>>.from(responseData['data']['posts']);
            isLoading = false;
          });
        } else {
          throw Exception('API returned success: false');
        }
      } else {
        throw Exception('Failed to load user details: ${response.statusCode}');
      }
    } catch (error) {
      setState(() {
        errorMessage = error.toString();
        isLoading = false;
      });
    }
  }

  bool _isDrawerOpen = false;

  void _toggleDrawer() {
    setState(() {
      _isDrawerOpen = !_isDrawerOpen;
    });
  }

  Widget buildBottomDrawer() {
    final drawerItems = getDrawerItems();

    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        height: _isDrawerOpen ? drawerItems.length * 57.0 : 0,
        decoration: BoxDecoration(
          color: const Color.fromRGBO(197, 198, 199, 1),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: ListView.separated(
          padding: EdgeInsets.zero,
          separatorBuilder: (context, index) => const Divider(
            color: Colors.grey,
            height: 1.5,
          ),
          itemCount: drawerItems.length,
          itemBuilder: (context, index) {
            final item = drawerItems[index];
            return buildDrawerItem(
              item['title'] as String,
              item['onTap'] as VoidCallback,
              isRed: item['isRed'] as bool,
              isBlue: item['isBlue'] as bool,
              isCancel: item['isCancel'] as bool,
            );
          },
        ),
      ),
    );
  }

  Widget buildDrawerItem(String title, VoidCallback? onTap,
      {bool isRed = false, bool isBlue = false, bool isCancel = false}) {
    return Container(
      color: isCancel ? Colors.white : Colors.transparent,
      child: ListTile(
        title: Text(
          title,
          style: TextStyle(
            color: isRed
                ? Colors.red
                : isBlue || isCancel
                    ? Color.fromRGBO(0, 122, 255, 1)
                    : Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 19,
          ),
          textAlign: TextAlign.center,
        ),
        onTap: onTap,
      ),
    );
  }

// Define the drawer items globally
  List<Map<String, dynamic>> getDrawerItems() {
    return [
      {
        'title': "Friend Request",
        'onTap': () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AdmiringRequestsPage()),
          );
        },
        'isBlue': true,
        'isRed': false,
        'isCancel': false
      },
      {
        'title': "About",
        'onTap': () => openUrl('https://www.ecstasystage.com'),
        'isBlue': true,
        'isRed': false,
        'isCancel': false
      },
      {
        'title': "Terms and Conditions",
        'onTap': () => openUrl('https://www.ecstasystage.com/PrivacyPolicy'),
        'isBlue': true,
        'isRed': false,
        'isCancel': false
      },
      {
        'title': "Privacy Policy",
        'onTap': () => openUrl('https://www.ecstasystage.com/PrivacyPolicy'),
        'isBlue': true,
        'isRed': false,
        'isCancel': false
      },
      {
        'title': "Write to Us",
        'onTap': () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => WriteToUsScreen()),
          );
        },
        'isBlue': true,
        'isRed': false,
        'isCancel': false
      },
      {
        'title': "Logout",
        'onTap': () {},
        'isBlue': false,
        'isRed': true,
        'isCancel': false
      },
      {
        'title': "Cancel",
        'onTap': _toggleDrawer,
        'isBlue': false,
        'isRed': false,
        'isCancel': true
      },
    ];
  }

// Function to open URLs in the browser
  Future<void> openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: CircularProgressIndicator(
            color: Colors.grey,
          ),
        ),
      );
    }

    if (errorMessage != null) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Text(
            'Error: $errorMessage',
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }

    final profilePhoto = userDetails?['profile_photo'];
    final stageName = userDetails?['stage_name'] ?? 'Stage Name';
    final description = userDetails?['description'] ?? 'Add Description';

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Column(
            children: [
              AppBar(
                backgroundColor: Colors.black,
                automaticallyImplyLeading: false,
                actions: [
                  Padding(
                    padding: const EdgeInsets.only(right: 20),
                    child: GestureDetector(
                      onTap: _toggleDrawer,
                      child: Image.asset(
                        'assets/images/drawer.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 30, horizontal: 16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Column(
                          children: const [
                            Text("Admirers",
                                style: TextStyle(color: Colors.white)),
                            Text("0", // Updated to use API data if available
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                )),
                          ],
                        ),
                        Stack(
                          children: [
                            Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                image: DecorationImage(
                                  image: FileImage(File(profilePhoto)),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => EditProfileScreen(
                                        profilePhoto: profilePhoto,
                                      ),
                                    ),
                                  ).then((_) {
                                    fetchUserDetails();
                                  });
                                },
                                child: Container(
                                  width: 22,
                                  height: 22,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                  ),
                                  child: Image.asset(
                                    'assets/images/editProfile.png',
                                    color: Colors.white,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Column(
                          children: const [
                            Text("Shares",
                                style: TextStyle(color: Colors.white)),
                            Text("0", // Updated to use API data if available
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                )),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),
                    Text(
                      stageName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      description,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: GridView.builder(
                    itemCount: posts.length,
                    gridDelegate:
                        const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 150,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                    ),
                    itemBuilder: (context, index) {
                      final post = posts[index];
                      // Using 1.5 as default aspect ratio; could be made dynamic if API provides it
                      const aspectRatio = 1.5;

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PostDetailScreen(
                                initialIndex: index,
                                posts: posts,
                              ),
                            ),
                          );
                        },
                        child: AspectRatio(
                          aspectRatio: aspectRatio,
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              image: DecorationImage(
                                image: NetworkImage(post['contentUrl']),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
          if (_isDrawerOpen) ...[
            GestureDetector(
              onTap: _toggleDrawer,
              child: Blur(
                blur: 5,
                colorOpacity: 0.3,
                child: Container(
                  color: Colors.black.withOpacity(0.5),
                  width: double.infinity,
                  height: double.infinity,
                ),
              ),
            ),
            buildBottomDrawer(),
          ],
        ],
      ),
    );
  }
}

class PostDetailScreen extends StatelessWidget {
  final int initialIndex;
  final List<Map<String, dynamic>> posts;

  const PostDetailScreen({
    Key? key,
    required this.initialIndex,
    required this.posts,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: ListView.builder(
        controller: ScrollController(initialScrollOffset: initialIndex * 400),
        itemCount: posts.length,
        itemBuilder: (context, index) {
          final post = posts[index];
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.network(
                  post['contentUrl'],
                  height: 300,
                  fit: BoxFit.cover,
                ),
                const SizedBox(height: 20),
                Text(
                  post['title'],
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    post['description'],
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(height: 100),
              ],
            ),
          );
        },
      ),
    );
  }
}