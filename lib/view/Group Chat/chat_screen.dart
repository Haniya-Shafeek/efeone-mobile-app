import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:efeone_mobile/utilities/constants.dart';
import 'package:efeone_mobile/controllers/chat.dart';

class GroupChatScreen extends StatefulWidget {
  const GroupChatScreen({super.key});

  @override
  _GroupChatScreenState createState() => _GroupChatScreenState();
}

class _GroupChatScreenState extends State<GroupChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  late String _senderFullName;
  late String _senderImageUrl;

  @override
  void initState() {
    super.initState();
    _updateLastSeenTimestamp(); // Mark messages as seen on init
    _fetchSenderDetailsAndFCMToken();
  }

  Future<void> _updateLastSeenTimestamp() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now().millisecondsSinceEpoch;
    await prefs.setInt('lastSeenTimestamp', now);
  }

  @override
  void dispose() {
    _updateLastSeenTimestamp(); // Update when leaving the screen
    super.dispose();
  }

  Future<void> _fetchSenderDetailsAndFCMToken() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _senderFullName = prefs.getString('fullName') ?? 'Unknown';
      _senderImageUrl = prefs.getString('img_url') ?? '';
    });

    // Fetch the FCM token
    final fcmToken = await FirebaseMessaging.instance.getToken();

    // Save details to Firestore
    if (_senderFullName.isNotEmpty && fcmToken != null) {
      final userDoc = FirebaseFirestore.instance
          .collection('employees')
          .doc(_senderFullName);

      await userDoc.set({
        'fullName': _senderFullName,
        'imgUrl': _senderImageUrl,
        'fcmToken': fcmToken,
        'lastActive': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true)); // Merge to avoid overwriting existing data
    }
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.isNotEmpty && _senderFullName.isNotEmpty) {
      final chatRef = FirebaseFirestore.instance
          .collection('chats')
          .doc('groupChat1')
          .collection('messages');

      await chatRef.add({
        'senderId': _senderFullName,
        'senderName': _senderFullName,
        'message': _messageController.text,
        'senderImageUrl': _senderImageUrl,
        'timestamp': FieldValue.serverTimestamp(),
      });

      _messageController.clear();
    }
  }

  Future<void> _deleteMessage(String messageId) async {
    final messageRef = FirebaseFirestore.instance
        .collection('chats')
        .doc('groupChat1')
        .collection('messages')
        .doc(messageId);

    await messageRef.delete();
  }

  String _formatDate(Timestamp timestamp) {
    final DateTime date = timestamp.toDate();
    final DateTime now = DateTime.now();
    final DateTime today = DateTime(now.year, now.month, now.day);
    final DateTime yesterday = today.subtract(const Duration(days: 1));

    if (date.isAfter(today)) {
      return 'Today';
    } else if (date.isAfter(yesterday)) {
      return 'Yesterday';
    } else {
      return DateFormat('dd-MM-yyyy').format(date);
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        final prefs = await SharedPreferences.getInstance();
        final now = DateTime.now().millisecondsSinceEpoch;
        await prefs.setInt('lastSeenTimestamp', now);

        final chatRef = FirebaseFirestore.instance
            .collection('chats')
            .doc('groupChat1')
            .collection('messages');

        final unreadMessages = await chatRef
            .where('timestamp',
                isGreaterThan: Timestamp.fromMillisecondsSinceEpoch(
                    prefs.getInt('lastSeenTimestamp') ?? 0))
            .get();

        final unreadCount = unreadMessages.docs.length;
        Provider.of<ChatProvider>(context, listen: false)
            .updateUnreadCount(unreadCount);

        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            "efeone conversations 🌐✨",
            style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
                color: primaryColor),
          ),
          centerTitle: true,
        ),
        body: Column(
          children: [
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('chats')
                    .doc('groupChat1')
                    .collection('messages')
                    .orderBy('timestamp', descending: false)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final messages = snapshot.data!.docs;

                  String lastDate = '';
                  return ListView.builder(
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final messageData =
                          messages[index].data() as Map<String, dynamic>;
                      final senderName = messageData['senderName'];
                      final message = messageData['message'];
                      final senderImageUrl =
                          messageData['senderImageUrl'] ?? '';
                      final timestamp = messageData['timestamp'];
                      final messageId = messages[index].id;

                      if (timestamp == null) {
                        return const SizedBox(); // Skip messages without a timestamp
                      }

                      bool isCurrentUser =
                          messageData['senderId'] == _senderFullName;

                      final messageDate = _formatDate(timestamp as Timestamp);
                      final showDateHeader = messageDate != lastDate;
                      lastDate = messageDate;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (showDateHeader)
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 8.0, horizontal: 16.0),
                              child: Text(
                                messageDate,
                                style: const TextStyle(
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Row(
                              mainAxisAlignment: isCurrentUser
                                  ? MainAxisAlignment.end
                                  : MainAxisAlignment.start,
                              children: [
                                if (!isCurrentUser)
                                  CircleAvatar(
                                    backgroundImage: senderImageUrl.isNotEmpty
                                        ? NetworkImage(senderImageUrl)
                                        : const AssetImage(
                                                'assets/images/avatar.png')
                                            as ImageProvider,
                                    radius: 20,
                                    backgroundColor: Colors.grey.shade200,
                                  ),
                                const SizedBox(width: 8.0),
                                Flexible(
                                  child: Container(
                                    padding: const EdgeInsets.all(10.0),
                                    decoration: BoxDecoration(
                                      color: isCurrentUser
                                          ? Colors.blue.shade100
                                          : Colors.grey.shade300,
                                      borderRadius: BorderRadius.only(
                                        topLeft: const Radius.circular(12.0),
                                        topRight: const Radius.circular(12.0),
                                        bottomLeft: isCurrentUser
                                            ? const Radius.circular(12.0)
                                            : const Radius.circular(0.0),
                                        bottomRight: isCurrentUser
                                            ? const Radius.circular(0.0)
                                            : const Radius.circular(12.0),
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        customText(
                                          text: senderName,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                        const SizedBox(height: 5.0),
                                        customText(
                                          text: message,
                                          color: Colors.black,
                                        ),
                                        const SizedBox(height: 5.0),
                                        Text(
                                          DateFormat('hh:mm a').format(
                                            timestamp.toDate(),
                                          ),
                                          style: const TextStyle(
                                            fontSize: 12.0,
                                            fontWeight: FontWeight.w400,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                if (isCurrentUser) const SizedBox(width: 8.0),
                                if (isCurrentUser)
                                  Row(
                                    children: [
                                      CircleAvatar(
                                        backgroundImage: senderImageUrl
                                                .isNotEmpty
                                            ? NetworkImage(senderImageUrl)
                                            : const AssetImage(
                                                    'assets/images/avatar.png')
                                                as ImageProvider,
                                        radius: 20,
                                        backgroundColor: Colors.grey.shade200,
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete),
                                        onPressed: () {
                                          _deleteMessage(messageId);
                                        },
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.all(10),
                        hintText: 'Type a message...',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(color: Colors.blue)),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: _sendMessage,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget customText(
    {required String text,
    FontWeight fontWeight = FontWeight.normal,
    Color color = Colors.black}) {
  return Text(
    text,
    style: TextStyle(fontWeight: fontWeight, color: color, fontSize: 12),
  );
}
