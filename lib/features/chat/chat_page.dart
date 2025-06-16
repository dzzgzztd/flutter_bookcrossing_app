import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../core/services/user_service.dart';

class ChatPage extends StatefulWidget {
  final String chatId;
  final String otherUserId;

  const ChatPage({super.key, required this.chatId, required this.otherUserId});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final _controller = TextEditingController();
  final currentUser = FirebaseAuth.instance.currentUser;
  String? otherUserName;

  @override
  void initState() {
    super.initState();
    _loadOtherUserName();
    _createChatIfNeeded();
  }

  Future<void> _loadOtherUserName() async {
    final profile = await UserService().getUserProfile(widget.otherUserId);
    setState(() {
      otherUserName = profile?.name ?? widget.otherUserId;
    });
  }

  Future<void> _createChatIfNeeded() async {
    if (currentUser == null) return;
    final chatRef = FirebaseFirestore.instance
        .collection('chats')
        .doc(widget.chatId);
    final chatDoc = await chatRef.get();

    if (!chatDoc.exists) {
      await chatRef.set({
        'participants': [currentUser!.uid, widget.otherUserId],
        'lastMessage': '',
        'lastMessageTime': Timestamp.now(),
      });
    }
  }

  Future<void> _sendMessage() async {
    if (_controller.text.trim().isEmpty || currentUser == null) return;

    final message = {
      'senderId': currentUser?.uid,
      'text': _controller.text.trim(),
      'timestamp': Timestamp.now(),
    };

    final chatRef = FirebaseFirestore.instance
        .collection('chats')
        .doc(widget.chatId);
    final chatDoc = await chatRef.get();

    if (!chatDoc.exists) {
      await chatRef.set({
        'participants': [currentUser?.uid, widget.otherUserId],
        'lastMessage': _controller.text.trim(),
        'lastMessageTime': Timestamp.now(),
      });
    } else {
      await chatRef.update({
        'lastMessage': _controller.text.trim(),
        'lastMessageTime': Timestamp.now(),
      });
    }

    await chatRef.collection('messages').add(message);

    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    if (currentUser == null) {
      return const Center(child: Text('Not logged in'));
    }

    return Scaffold(
      appBar: AppBar(
        title: GestureDetector(
          onTap: () => Navigator.pushNamed(
            context,
            '/user-profile',
            arguments: widget.otherUserId,
          ),
          child: Text('Диалог с ${otherUserName ?? widget.otherUserId}'),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('chats')
                  .doc(widget.chatId)
                  .collection('messages')
                  .orderBy('timestamp')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return const Center(child: Text('Ошибка загрузки сообщений'));
                }

                final messages = snapshot.data?.docs ?? [];

                if (messages.isEmpty) {
                  return const Center(child: Text('Сообщений пока нет'));
                }

                return ListView(
                  padding: const EdgeInsets.all(8),
                  children: messages.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    final isMe = data['senderId'] == currentUser?.uid;

                    return Align(
                      alignment: isMe
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        decoration: BoxDecoration(
                          color: isMe
                              ? Colors.deepPurple[100]
                              : Colors.grey[300],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(data['text']),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Введите сообщение...',
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
    );
  }
}
