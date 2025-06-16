import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String senderId;
  final String text;
  final DateTime timestamp;

  Message({required this.senderId, required this.text, required this.timestamp});

  factory Message.fromJson(Map<String, dynamic> json) => Message(
        senderId: json['senderId'],
        text: json['text'],
        timestamp: (json['timestamp'] as Timestamp).toDate(),
      );

  Map<String, dynamic> toJson() => {
        'senderId': senderId,
        'text': text,
        'timestamp': timestamp,
      };
}
