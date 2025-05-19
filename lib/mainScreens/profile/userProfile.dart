import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ecstasyapp/constants.dart';

class UserProfileView extends StatefulWidget {
  final String targetId;
  final dynamic admireCondition;

  const UserProfileView({
    Key? key, 
    required this.targetId, 
    this.admireCondition,
  }) : super(key: key);

  @override
  State<UserProfileView> createState() => _UserProfileViewState();
}

class _UserProfileViewState extends State<UserProfileView> {
  bool isAdmired = false;
  bool isLoading = true;
  Map<String, dynamic>? profileData;
  List<dynamic> posts = [];
  final String apiBaseUrl = AppConfig.apiBaseUrl;

  @override
  void initState() {
    super.initState();
    // Initialize isAdmired based on admireCondition
    // admireCondition can be true or null (null means false)
    isAdmired = widget.admireCondition == true;
    fetchProfileData();
  }

  Future<void> fetchProfileData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final idToken = prefs.getString('idToken') ?? '';
    final String sub = prefs.getString('sub') ?? '';

    final apiUrl = '$apiBaseUrl/api/v1/post/${widget.targetId}?limit=10&offset=0';
    final headers = {
      'Authorization': 'Bearer $idToken',
      'sub': sub,
    };

    try {
      final response = await http.get(Uri.parse(apiUrl), headers: headers);
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        if (jsonData['success']) {
          setState(() {
            profileData = jsonData['data'];
            posts = profileData!['posts'] ?? [];
            isLoading = false;
          });
        }
      } else {
        print('Error: ${response.statusCode}, ${response.body}');
        setState(() => isLoading = false);
      }
    } catch (error) {
      print('API call error: $error');
      setState(() => isLoading = false);
    }
  }

  Future<void> toggleAdmire() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final idToken = prefs.getString('idToken') ?? '';
    final String sub = prefs.getString('sub') ?? '';

    final apiUrl = '$apiBaseUrl/api/v1/request/${widget.targetId}';
    final headers = {
      'Authorization': 'Bearer $idToken',
      'sub': sub,
      'Content-Type': 'application/json',
    };

    final newAdmireState = !isAdmired;
    final body = jsonEncode({"isrequest": newAdmireState.toString()});

    try {
      final response = await http.post(Uri.parse(apiUrl), headers: headers, body: body);
      if (response.statusCode == 200) {
        setState(() {
          isAdmired = newAdmireState;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Admire ${newAdmireState ? 'sent' : 'removed'} successfully')),
        );
      } else {
        print('Admire API error: ${response.statusCode}, ${response.body}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update admire status')),
        );
      }
    } catch (error) {
      print('Admire API call error: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating admire status')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: SafeArea(
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    if (profileData == null) {
      return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: SafeArea(
          child: Center(child: Text('Failed to load profile', style: TextStyle(color: Colors.white))),
        ),
      );
    }

    final user = profileData!['user'];
    final totalFriends = profileData!['totalFriends'] ?? 0;
    final totalUniqueShares = profileData!['totalUniqueShares'] ?? 0;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Top Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  // Admirers, Profile Photo, and Shares Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Admirers
                      Column(
                        children: [
                          Text("Admirers", style: TextStyle(color: Colors.white)),
                          Text(
                            "$totalFriends",
                            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
        
                      // Profile Photo with Admire Toggle
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Column(
                          children: [
                            Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                image: DecorationImage(
                                  image: NetworkImage(user['profile_photo'] ?? 'https://via.placeholder.com/100'),
                                  fit: BoxFit.cover,
                                ),
                              ),
                              child: user['profile_photo'] == null
                                  ? Image.asset('assets/images/profile_photo.png', fit: BoxFit.cover)
                                  : null,
                            ),
                            SizedBox(height: 20),
                            GestureDetector(
                              onTap: toggleAdmire,
                              child: Container(
                                height: 30,
                                width: 50,
                                decoration: BoxDecoration(
                                  color: isAdmired ? Colors.blue : Color.fromRGBO(128, 128, 128, 1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisAlignment: isAdmired ? MainAxisAlignment.end : MainAxisAlignment.start,
                                  children: [
                                    Container(
                                      margin: const EdgeInsets.all(3),
                                      width: 24,
                                      height: 24,
                                      decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                                      child: Center(
                                        child: Text(
                                          isAdmired ? 'Admired' : 'Admire',
                                          style: const TextStyle(fontSize: 5, color: Colors.blue, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
        
                      // Shares
                      Column(
                        children: [
                          Text("Shares", style: TextStyle(color: Colors.white)),
                          Text(
                            "$totalUniqueShares",
                            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
        
                  // Description Section
                  Text(
                    user['stage_name'] ?? 'Unknown',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    user['description'] ?? 'No description available',
                    style: TextStyle(color: Colors.white, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
        
            // Dynamic Grid Section
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: GridView.builder(
                  itemCount: posts.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemBuilder: (context, index) {
                    final post = posts[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => UserPostDetailScreen(
                              initialIndex: index,
                              posts: posts,
                            ),
                          ),
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          image: DecorationImage(
                            image: NetworkImage(post['contentUrl'] ?? 'https://via.placeholder.com/150'),
                            fit: BoxFit.cover,
                          ),
                        ),
                        child: post['contentUrl'] == null
                            ? Image.asset('assets/images/profile_photo.png', fit: BoxFit.cover)
                            : null,
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class UserPostDetailScreen extends StatelessWidget {
  final int initialIndex;
  final List<dynamic> posts;

  const UserPostDetailScreen({
    Key? key,
    required this.initialIndex,
    required this.posts,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: ListView.builder(
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
                  // Post Image/Video
                  Container(
                    height: 300,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: NetworkImage(post['contentUrl'] ?? 'https://via.placeholder.com/300'),
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: post['contentUrl'] == null
                        ? Image.asset('assets/images/profile_photo.png', fit: BoxFit.cover)
                        : null,
                  ),
                  const SizedBox(height: 20),

                  // Post Title
                  Text(
                    post['title'] ?? 'No Title',
                    style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),

                  // Post Description
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      post['description'] ?? 'No Description',
                      style: const TextStyle(color: Colors.white70, fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(height: 100),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}