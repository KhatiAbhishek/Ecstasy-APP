import 'dart:convert';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:ecstasyapp/constants.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

class ChatDisplayScreen extends StatefulWidget {
  final String userName;
  final String personId;

  ChatDisplayScreen({required this.userName, required this.personId});

  @override
  _ChatDisplayScreenState createState() => _ChatDisplayScreenState();
}

class _ChatDisplayScreenState extends State<ChatDisplayScreen> {
  late IO.Socket socket;
  String userId = '';
  String idToken = '';
  String sub = '';
  String roomId = '';
  List<Map<String, dynamic>> messages = [];
  TextEditingController messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool isSelectionMode = false;
  Set<String> selectedMessages = {};
  final String apiBaseUrl = AppConfig.apiBaseUrl;
  Map<String, VideoPlayerController> _videoControllers = {};
  Map<String, ChewieController> _chewieControllers = {};

  @override
  void initState() {
    super.initState();
    _getUserData();
  }

  Future<void> _getUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      idToken = prefs.getString('idToken') ?? '';
      sub = prefs.getString('sub') ?? '';
      userId = prefs.getString('userId') ?? '';
    });
    await _fetchChatHistory();
    _initSocket();
  }

  Future<void> _fetchChatHistory() async {
    final url = Uri.parse('$apiBaseUrl/api/v1/chat/getchat/${widget.personId}');
    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $idToken',
          'sub': sub,
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        if (responseData['success'] == true) {
          List<dynamic> chatData = responseData['data'];

          setState(() {
            messages = chatData.map((msg) {
              bool isUserMessage = msg['userId'] == userId;
              return {
                'sender': isUserMessage ? 'You' : widget.personId,
                'message': msg['message'] ?? '',
                'type': isUserMessage ? 'you' : 'other',
                'id': msg['id'] ?? DateTime.now().toString(),
                'postId': msg['postId'],
                'postData': msg['postData'],
              };
            }).toList();
          });

          _initializeMediaControllers();
          Future.delayed(const Duration(milliseconds: 1), _jumpToBottom);
        }
      }
    } catch (e) {
      print('Error fetching chat history: $e');
    }
  }

  void _initSocket() {
    socket = IO.io(
      '$apiBaseUrl',
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .build(),
    );

    socket.onConnect((_) {
      _createRoom();
    });

    socket.on('privateMessage', (data) {
      if (data['senderId'] != userId) {
        setState(() {
          messages.add({
            'sender': widget.personId,
            'message': data['message'] ?? '',
            'id': data['messageId'] ?? DateTime.now().toString(),
            'type': 'other',
            'postId': data['postId'],
            'postData': data['postData'],
          });
        });

        _initializeMediaControllerForMessage(messages.last);
        _scrollToBottom();
      }
    });

    socket.connect();
  }

  void _createRoom() {
    if (userId.isNotEmpty && widget.personId.isNotEmpty) {
      socket.emitWithAck(
          'createRoom', {'userId1': userId, 'userId2': widget.personId},
          ack: (response) {
        if (response != null && response['roomId'] != null) {
          setState(() {
            roomId = response['roomId'];
          });
          socket.emit('joinRoom', roomId);
        }
      });
    }
  }

  void _sendMessage() {
    final message = messageController.text.trim();
    if (roomId.isNotEmpty && message.isNotEmpty) {
      final messageData = {
        'roomId': roomId,
        'senderId': userId,
        'message': message,
      };

      setState(() {
        messages.add({
          'sender': 'You',
          'message': message,
          'id': DateTime.now().toString(),
          'type': 'you',
          'postId': null,
          'postData': null,
        });
      });

      socket.emitWithAck('sendPrivateMessage', messageData, ack: (ack) {
        if (ack == 'Message sent') {
          messageController.clear();
          _scrollToBottom();
        } else {
          setState(() {
            messages.removeLast();
          });
        }
      });
    }
  }

  void _deleteMessages() async {
    if (selectedMessages.isEmpty) return;

    final url = Uri.parse('$apiBaseUrl/api/v1/chat/delete');
    try {
      final response = await http.delete(
        url,
        headers: {
          'Authorization': 'Bearer $idToken',
          'sub': sub,
          'Content-Type': 'application/json',
        },
        body: jsonEncode({"messageIds": selectedMessages.toList()}),
      );

      if (response.statusCode == 200) {
        setState(() {
          messages.removeWhere((msg) => selectedMessages.contains(msg['id']));
          selectedMessages.clear();
          isSelectionMode = false;
        });
      }
    } catch (e) {
      print('Error deleting messages: $e');
    }
  }

  void _toggleSelection(String messageId) {
    setState(() {
      if (selectedMessages.contains(messageId)) {
        selectedMessages.remove(messageId);
      } else {
        selectedMessages.add(messageId);
      }
      isSelectionMode = selectedMessages.isNotEmpty;
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _jumpToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  void _initializeMediaControllers() {
    for (var message in messages) {
      _initializeMediaControllerForMessage(message);
    }
  }

  void _initializeMediaControllerForMessage(Map<String, dynamic> message) {
    String? content = message['message'];
    String messageId = message['id'] ?? '';
    dynamic postData = message['postData'];

    if (postData != null &&
        postData['success'] == true &&
        postData['data'].isNotEmpty) {
      String? mediaUrl = postData['data'][0]['contentUrl'];
      if (mediaUrl != null && _isVideoUrl(mediaUrl)) {
        _initializeVideoController(mediaUrl, messageId);
      }
    } else if (content != null && _isVideoUrl(content)) {
      _initializeVideoController(content, messageId);
    }
  }

  void _initializeVideoController(String url, String messageId) {
    final controller = VideoPlayerController.network(url);
    _videoControllers[messageId] = controller;
    controller.initialize().then((_) {
      if (mounted) {
        setState(() {
          _chewieControllers[messageId] = ChewieController(
            videoPlayerController: controller,
            autoPlay: false,
            looping: false,
            aspectRatio: controller.value.aspectRatio,
          );
        });
      }
    }).catchError((error) {
      print('Error initializing video: $error');
    });
  }

  bool _isVideoUrl(String text) {
    return text.contains('.mp4');
  }

  @override
  void dispose() {
    socket.dispose();
    messageController.dispose();
    _scrollController.dispose();
    _videoControllers.forEach((_, controller) => controller.dispose());
    _chewieControllers.forEach((_, controller) => controller.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(widget.userName, style: const TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: isSelectionMode
            ? [
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        backgroundColor: Colors.black,
                        title: const Text("Delete Messages",
                            style: TextStyle(color: Colors.white)),
                        content: const Text("Are you sure you want to delete?",
                            style: TextStyle(color: Colors.white)),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text("No",
                                style: TextStyle(color: Colors.white)),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                              _deleteMessages();
                            },
                            child: const Text("Yes",
                                style: TextStyle(color: Colors.white)),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ]
            : null,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: messages.length,
              itemBuilder: (context, index) {
                bool isUserMessage = messages[index]['type'] == 'you';
                String messageId = messages[index]['id'];
                bool isSelected = selectedMessages.contains(messageId);
                final messageContent = messages[index]['message'];
                final postData = messages[index]['postData'];

                return GestureDetector(
                  onLongPress: () => _toggleSelection(messageId),
                  onTap: () {
                    if (isSelectionMode) _toggleSelection(messageId);
                  },
                  child: Align(
                    alignment: isUserMessage
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Container(
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.7,
                      ),
                      padding:
                          const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Colors.redAccent
                            : (isUserMessage
                                ? Colors.blueAccent
                                : Colors.grey[700]),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: _buildMessageContent(
                          messageContent, messageId, postData),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: RawKeyboardListener(
                    focusNode: FocusNode(),
                    onKey: (RawKeyEvent event) {
                      if (event is RawKeyDownEvent &&
                          event.logicalKey == LogicalKeyboardKey.enter) {
                        _sendMessage();
                      }
                    },
                    child: TextField(
                      controller: messageController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Type a message',
                        hintStyle: const TextStyle(color: Colors.grey),
                        filled: true,
                        fillColor: Colors.grey[800],
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20)),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey[700]!),
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.blue),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageContent(
      String content, String messageId, dynamic postData) {
    if (postData != null &&
        postData['success'] == true &&
        postData['data'].isNotEmpty) {
      final post = postData['data'][0];
      final String title = post['title'] ?? 'Shared Post';

      return GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PostDetailScreen(postData: {
                'postData': {
                  'data': [post]
                }
              }),
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey[800],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.video_library, color: Colors.white70, size: 20),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  title,
                  style: const TextStyle(color: Colors.white),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (content.isNotEmpty && _isVideoUrl(content)) {
      return _renderVideo(content, messageId);
    }

    return Text(
      content.isNotEmpty ? content : "No content",
      style: const TextStyle(color: Colors.white),
    );
  }

  Widget _renderVideo(String url, String messageId) {
    final chewieController = _chewieControllers[messageId];
    if (chewieController != null &&
        chewieController.videoPlayerController.value.isInitialized) {
      return Container(
        width: 230,
        height: 150,
        child: Chewie(controller: chewieController),
      );
    }
    return Container(
      width: 230,
      height: 150,
      color: Colors.grey[900],
      child: const Center(child: CircularProgressIndicator()),
    );
  }
}

// New Post Detail Screen

class PostDetailScreen extends StatefulWidget {
  final Map<String, dynamic>? postData; // Expecting a message object

  PostDetailScreen({required this.postData});

  @override
  _PostDetailScreenState createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  late VideoPlayerController _videoController;
  ChewieController? _chewieController;
  late ConfettiController _likeConfettiController;
  bool isLiked = false;
  bool isDisliked = false;
  int likes = 0;
  int dislikes = 0;
  final String apiBaseUrl = AppConfig.apiBaseUrl;
  TextEditingController _commentController = TextEditingController();
  List<dynamic> comments = [];
  int? expandedCommentIndex;

  Map<String, dynamic>?
      _post; // The actual post data extracted from postData['postData']['data'][0]

  @override
  void initState() {
    super.initState();
    _likeConfettiController =
        ConfettiController(duration: const Duration(seconds: 4));
    _videoController =
        VideoPlayerController.network(''); // Dummy initialization
    _initializePostData();
    _initializeMediaController();
    _fetchComments();
  }

  void _initializePostData() {
    if (widget.postData == null) {
      print('Post data is null');
      return;
    }

    Map<String, dynamic>? postObject;

    // Check if this is a direct post object or nested structure
    if (widget.postData!['id'] != null) {
      // Direct post object
      postObject = widget.postData;
    } else if (widget.postData!['postData'] != null &&
        widget.postData!['postData']['data'] != null &&
        (widget.postData!['postData']['data'] as List).isNotEmpty) {
      // Nested structure
      postObject = widget.postData!['postData']['data'][0];
    } else {
      print('Post data is invalid: $widget.postData');
      return;
    }

    _post = postObject;
    setState(() {
      isLiked = _post!['isLiked'] ?? false;
      isDisliked = _post!['isDisliked'] ?? false;
      likes = _post!['likes'] ?? 0;
      dislikes = _post!['dislikes'] ?? 0;
    });
  }

  void _initializeMediaController() {
    if (_post == null) return;
    final String contentUrl = _post!['contentUrl'] ?? '';
    if (contentUrl.isNotEmpty && _isVideoUrl(contentUrl)) {
      _videoController.dispose(); // Dispose old controller
      _videoController = VideoPlayerController.network(contentUrl);
      _videoController.initialize().then((_) {
        if (mounted) {
          setState(() {
            _chewieController = ChewieController(
              videoPlayerController: _videoController,
              autoPlay: false,
              looping: false,
              aspectRatio: _videoController.value.aspectRatio,
            );
          });
        }
      }).catchError((error) {
        print('Error initializing video: $error');
      });
    }
  }

  bool _isVideoUrl(String url) {
    return url.toLowerCase().contains('.mp4') ||
        url.toLowerCase().contains('.mov') ||
        url.toLowerCase().contains('.avi') ||
        url.toLowerCase().contains('.mkv');
  }

  Future<void> toggleLike() async {
    if (_post == null) return;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final idToken = prefs.getString('idToken') ?? '';
    final String sub = prefs.getString('sub') ?? '';
    final String postId = _post!['id'];

    final likeUrl = '$apiBaseUrl/api/v1/feed/like/$postId';
    final dislikeUrl = '$apiBaseUrl/api/v1/feed/dislike/$postId';
    final headers = {
      'Authorization': 'Bearer $idToken',
      'sub': sub,
      'Content-Type': 'application/json',
    };

    try {
      final newLikeState = !isLiked;
      final likeBody = jsonEncode({'isliked': newLikeState});
      final likeResponse =
          await http.put(Uri.parse(likeUrl), headers: headers, body: likeBody);

      if (likeResponse.statusCode == 200) {
        if (newLikeState && isDisliked) {
          final dislikeBody = jsonEncode({'disliked': false});
          final dislikeResponse = await http.put(Uri.parse(dislikeUrl),
              headers: headers, body: dislikeBody);
          if (dislikeResponse.statusCode == 200) {
            setState(() {
              isLiked = newLikeState;
              isDisliked = false;
              likes = isLiked ? likes + 1 : likes - 1;
              dislikes -= 1;
              if (isLiked) _likeConfettiController.play();
            });
          }
        } else {
          setState(() {
            isLiked = newLikeState;
            likes = isLiked ? likes + 1 : likes - 1;
            if (isLiked) _likeConfettiController.play();
          });
        }
      }
    } catch (error) {
      print('Like API error: $error');
    }
  }

  Future<void> toggleDislike() async {
    if (_post == null) return;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final idToken = prefs.getString('idToken') ?? '';
    final String sub = prefs.getString('sub') ?? '';
    final String postId = _post!['id'];

    final likeUrl = '$apiBaseUrl/api/v1/feed/like/$postId';
    final dislikeUrl = '$apiBaseUrl/api/v1/feed/dislike/$postId';
    final headers = {
      'Authorization': 'Bearer $idToken',
      'sub': sub,
      'Content-Type': 'application/json',
    };

    try {
      final newDislikeState = !isDisliked;
      final dislikeBody = jsonEncode({'disliked': newDislikeState});
      final dislikeResponse = await http.put(Uri.parse(dislikeUrl),
          headers: headers, body: dislikeBody);

      if (dislikeResponse.statusCode == 200) {
        if (newDislikeState && isLiked) {
          final likeBody = jsonEncode({'isliked': false});
          final likeResponse = await http.put(Uri.parse(likeUrl),
              headers: headers, body: likeBody);
          if (likeResponse.statusCode == 200) {
            setState(() {
              isDisliked = newDislikeState;
              isLiked = false;
              dislikes = isDisliked ? dislikes + 1 : dislikes - 1;
              likes -= 1;
            });
          }
        } else {
          setState(() {
            isDisliked = newDislikeState;
            dislikes = isDisliked ? dislikes + 1 : dislikes - 1;
          });
        }
      }
    } catch (error) {
      print('Dislike API error: $error');
    }
  }

  Future<void> _fetchComments() async {
    if (_post == null) return;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final idToken = prefs.getString('idToken') ?? '';
    final String sub = prefs.getString('sub') ?? '';
    final String postId = _post!['id'];
    final apiUrl = '$apiBaseUrl/api/v1/feed/comment/$postId';
    final headers = {'Authorization': 'Bearer $idToken', 'sub': sub};

    try {
      final response = await http.get(Uri.parse(apiUrl), headers: headers);
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        if (jsonData['success']) {
          setState(() {
            comments = jsonData['data'];
          });
        }
      }
    } catch (error) {
      print('Comment fetch error: $error');
    }
  }


  Future<void> _postComment() async {
  if (_commentController.text.isEmpty || _post == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Please enter a comment'))
    );
    return;
  }

  SharedPreferences prefs = await SharedPreferences.getInstance();
  final idToken = prefs.getString('idToken') ?? '';
  final String sub = prefs.getString('sub') ?? '';
  final String userId = prefs.getString('userId') ?? '';
  
  final String postId = _post!['id'];
  final String phoneNumber = prefs.getString('phoneNumber') ?? '';

  final apiUrl = '$apiBaseUrl/api/v1/share/'; 
  final headers = {
    'Authorization': 'Bearer $idToken',
    'sub': sub,
    'Content-Type': 'application/json'
  };
 
  final body = jsonEncode({
    "share": {  
      "userId": userId,
      "postId": postId,
      "content": _commentController.text,
      "filename" :"image.jpeg",
      "createdBy": phoneNumber
    }
  });

  try {
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: headers,
      body: body
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      _commentController.clear();
      await _fetchComments();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Comment posted successfully'))
      );
    } else {
      print('Error: ${response.statusCode}, ${response.body}');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to post comment'))
      );
    }
  } catch (error) {
    print('Comment API error: $error');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Error posting comment'))
    );
  }
}

  Future<void> _postReply(String commentId, String replyContent) async {
    if (_post == null) return;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final idToken = prefs.getString('idToken') ?? '';
    final String sub = prefs.getString('sub') ?? '';
    final String userId = prefs.getString('userId') ?? '';
    final String phoneNumber = prefs.getString('phoneNumber') ?? '';
    final apiUrl = '$apiBaseUrl/api/v1/feed/reply/$userId';
    final headers = {
      'Authorization': 'Bearer $idToken',
      'sub': sub,
      'Content-Type': 'application/json'
    };
    final body = jsonEncode({
      "commentId": commentId,
      "content": replyContent,
      "createdBy": phoneNumber
    });

    try {
      final response =
          await http.post(Uri.parse(apiUrl), headers: headers, body: body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        await _fetchComments();
      }
    } catch (error) {
      print('Reply API error: $error');
    }
  }

  @override
  void dispose() {
    _videoController.dispose();
    _chewieController?.dispose();
    _likeConfettiController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_post == null) {
      return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          title: const Text("Post Details", style: TextStyle(color: Colors.white)),
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: const Center(
          child: Text(
            "No post data available",
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }

    final String contentUrl = _post!['contentUrl'] ?? '';
    final String title = _post!['title'] ?? '';
    final String description = _post!['description'] ?? '';
    final Map<String, dynamic>? userData = _post!['user'];
    final String userName = userData?['stage_name'] ?? 'Unknown user';
    final String profilePhoto = userData?['profile_photo'] ?? '';

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text("Post Details", style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Stack(
          children: [
            Column(
              children: [
                // Video/Image Container
                Container(
                  height: MediaQuery.of(context).size.height * 0.6,
                  width: double.infinity,
                  child: _isVideoUrl(contentUrl)
                      ? (_chewieController != null
                          ? Chewie(controller: _chewieController!)
                          : const Center(child: CircularProgressIndicator()))
                      : Image.network(
                          contentUrl,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return const Center(child: CircularProgressIndicator());
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return const Center(
                                child: Text('Image failed to load',
                                    style: TextStyle(color: Colors.white)));
                          },
                        ),
                ),
                // Overlay Caption
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        description,
                        style: const TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                    ],
                  ),
                ),
                // Comments Container
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                      color: Colors.grey[800],
                      borderRadius: BorderRadius.circular(8)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _commentController,
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                hintText: "Add a comment...",
                                hintStyle: const TextStyle(color: Colors.white54),
                                filled: true,
                                fillColor: Colors.grey[700],
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(30),
                                    borderSide: BorderSide.none),
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 12),
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.send, color: Colors.white),
                            onPressed: _postComment,
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      GestureDetector(
                        onTap: () =>
                            _showCommentsBottomSheet(context, _post!['id']),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Row(
                            children: [
                              if (_post!['comment'] != null)
                                CircleAvatar(
                                  backgroundImage: NetworkImage(
                                      _post!['comment']['user']
                                              ['profile_photo'] ??
                                          'file:///assets/images/defaultProfile.png'),
                                  radius: 16,
                                ),
                              const SizedBox(width: 8),
                              if (_post!['comment'] != null)
                                Expanded(
                                  child: RichText(
                                    text: TextSpan(
                                      children: [
                                        TextSpan(
                                            text:
                                                "${_post!['comment']['user']['stage_name'] ?? 'Unknown'}: ",
                                            style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold)),
                                        TextSpan(
                                            text: _post!['comment']
                                                    ['content'] ??
                                                '',
                                            style: const TextStyle(
                                                color: Colors.white70,
                                                fontSize: 14)),
                                      ],
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                )
                              else
                                const Text("No comments yet",
                                    style: TextStyle(
                                        color: Colors.white70, fontSize: 14)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                // Like/Dislike Container
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 7),
                  decoration: BoxDecoration(
                    color: Colors.grey[800],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Row(
                        children: [
                          GestureDetector(
                            onTap: toggleLike,
                            child: Image.asset(
                              isLiked
                                  ? "assets/images/liked.png"
                                  : "assets/images/like.png",
                              width: 40,
                              height: 40,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "$likes",
                            style: const TextStyle(color: Colors.white, fontSize: 14),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          GestureDetector(
                            onTap: toggleDislike,
                            child: Image.asset(
                              isDisliked
                                  ? "assets/images/disLiked.png"
                                  : "assets/images/disLike.png",
                              width: 40,
                              height: 40,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "$dislikes",
                            style: const TextStyle(color: Colors.white, fontSize: 14),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
            Align(
              alignment: Alignment.topCenter,
              child: ConfettiWidget(
                confettiController: _likeConfettiController,
                blastDirectionality: BlastDirectionality.explosive,
                emissionFrequency: 0.05,
                numberOfParticles: 300,
                gravity: 0.3,
                colors: [Colors.green, Colors.blue, Colors.yellow],
              ),
            ),
          ],
        ),
      ),
    );
  }


void _showCommentsBottomSheet(BuildContext context, String postId) {
  // Track reply state outside the showModalBottomSheet to preserve it
  Map<int, bool> showReplyFields = {};
  Map<int, TextEditingController> replyControllers = {};

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.black,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (context) {
      return Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SafeArea(
          child: StatefulBuilder(
            builder: (context, setState) {
              return FractionallySizedBox(
                heightFactor: 0.7,
                child: Column(
                  children: [
                    // Drag indicator
                    Container(
                      height: 4,
                      width: 40,
                      margin: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.grey[600],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    
                    // Comments list
                    Expanded(
                      child: ListView.builder(
                        itemCount: comments.length,
                        itemBuilder: (context, index) {
                          final comment = comments[index];
                          final isCommentExpanded = expandedCommentIndex == index;
                          
                          // Initialize controller if needed
                          if (showReplyFields.containsKey(index) && 
                              showReplyFields[index]! && 
                              !replyControllers.containsKey(index)) {
                            replyControllers[index] = TextEditingController();
                          }
                          
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ListTile(
                                leading: CircleAvatar(
                                  backgroundImage: NetworkImage(
                                    comment['user']['profile_photo'] ?? 
                                        'https://via.placeholder.com/32'
                                  ),
                                ),
                                title: Text(
                                  comment['user']['stage_name'] ?? 'Unknown',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold
                                  )
                                ),
                                subtitle: Text(
                                  comment['content'] ?? '',
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 14
                                  ),
                                  maxLines: isCommentExpanded ? null : 2,
                                  overflow: isCommentExpanded
                                      ? TextOverflow.visible
                                      : TextOverflow.ellipsis
                                ),
                                trailing: TextButton(
                                  onPressed: () {
                                    setState(() {
                                      // Toggle reply field
                                      showReplyFields[index] = !(showReplyFields[index] ?? false);
                                      
                                      // Clean up if closing
                                      if (!(showReplyFields[index] ?? false) && 
                                          replyControllers.containsKey(index)) {
                                        replyControllers[index]!.dispose();
                                        replyControllers.remove(index);
                                      }
                                    });
                                  },
                                  child: const Text(
                                    'Reply',
                                    style: TextStyle(color: Colors.blue)
                                  ),
                                ),
                                onTap: () => setState(() =>
                                    expandedCommentIndex = isCommentExpanded ? null : index),
                              ),
                              
                              // Reply field - only show if set to true
                              if (showReplyFields[index] ?? false)
                                Padding(
                                  padding: const EdgeInsets.only(
                                    left: 56.0,
                                    right: 16.0,
                                    bottom: 8.0
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Focus(
                                          onFocusChange: (hasFocus) {
                                            // This prevents focus issues
                                            if (hasFocus) {
                                              setState(() {});
                                            }
                                          },
                                          child: TextField(
                                            controller: replyControllers[index],
                                            style: const TextStyle(color: Colors.white),
                                            decoration: InputDecoration(
                                              hintText: "Write a reply...",
                                              hintStyle: const TextStyle(color: Colors.white54),
                                              filled: true,
                                              fillColor: Colors.grey[700],
                                              border: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(20),
                                                borderSide: BorderSide.none
                                              ),
                                              contentPadding: const EdgeInsets.symmetric(
                                                horizontal: 16,
                                                vertical: 12
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.send, color: Colors.white),
                                        onPressed: () async {
                                          if (replyControllers.containsKey(index) &&
                                              replyControllers[index]!.text.isNotEmpty) {
                                            await _postReply(
                                              comment['id'],
                                              replyControllers[index]!.text
                                            );
                                            
                                            setState(() {
                                              showReplyFields[index] = false;
                                              replyControllers[index]!.dispose();
                                              replyControllers.remove(index);
                                            });
                                            
                                            await _fetchComments();
                                            setState(() {});
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              
                              // Replies
                              if (isCommentExpanded &&
                                  comment['replies'] != null &&
                                  comment['replies'].isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(left: 32.0, top: 8.0),
                                  child: Column(
                                    children: comment['replies'].map<Widget>((reply) {
                                      return ListTile(
                                        leading: CircleAvatar(
                                          backgroundImage: NetworkImage(
                                            reply['user']['profile_photo'] ??
                                                'https://via.placeholder.com/30'
                                          ),
                                          radius: 15,
                                        ),
                                        title: Text(
                                          reply['user']['stage_name'] ?? 'Unknown',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold
                                          )
                                        ),
                                        subtitle: Text(
                                          reply['content'] ?? '',
                                          style: const TextStyle(
                                            color: Colors.white60,
                                            fontSize: 12
                                          )
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ),
                            ],
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      );
    },
  );
}
}
