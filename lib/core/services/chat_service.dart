import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bookcrossing_app/core/models/message_model.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<String> getChatId(String uid1, String uid2) {
    return [uid1, uid2]..sort(); 
  }

  Stream<List<Message>> getMessages(String chatId) {
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => Message.fromJson(doc.data())).toList());
  }

  Future<void> sendMessage(String chatId, Message message) async {
    await _firestore.collection('chats').doc(chatId).collection('messages').add(message.toJson());

    await _firestore.collection('chats').doc(chatId).set({
      'lastMessage': message.text,
      'lastTimestamp': message.timestamp,
      'participants': [message.senderId], 
    }, SetOptions(merge: true));
  }
}
