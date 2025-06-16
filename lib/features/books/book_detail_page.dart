import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../core/models/book_model.dart';
import '../../core/services/book_service.dart';

class BookDetailPage extends StatelessWidget {
  final BookModel book;

  const BookDetailPage({super.key, required this.book});

  bool get isOwner => FirebaseAuth.instance.currentUser?.uid == book.ownerId;

  void _editBook(BuildContext context) {
    Navigator.pushNamed(
      context,
      '/edit-book',
      arguments: {
        'book': book,
        'userId': FirebaseAuth.instance.currentUser!.uid,
      },
    );
  }

  void _markAsGiven(BuildContext context) async {
    await BookService().markAsGiven(book.id);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Книга помечена как отданная')),
      );
      Navigator.pop(context);
    }
  }

  Future<void> _messageOwner(BuildContext context) async {
    final currentUserId = FirebaseAuth.instance.currentUser!.uid;
    final otherUserId = book.ownerId;

    final query = await FirebaseFirestore.instance
        .collection('chats')
        .where('participants', arrayContains: currentUserId)
        .get();

    final matchingChats = query.docs.where((doc) {
      final participants = List<String>.from(doc['participants']);
      return participants.contains(otherUserId);
    }).toList();

    String chatId;

    if (matchingChats.isNotEmpty) {
      chatId = matchingChats.first.id;
    } else {
      final newChat = await FirebaseFirestore.instance.collection('chats').add({
        'participants': [currentUserId, otherUserId],
        'lastMessage': '',
        'lastMessageTime': FieldValue.serverTimestamp(),
      });
      chatId = newChat.id;
    }

    if (context.mounted) {
      Navigator.pushNamed(
        context,
        '/chat',
        arguments: {'chatId': chatId, 'otherUserId': otherUserId},
      );
    }
  }

  void _openImageFull(BuildContext context, String imageUrl) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(backgroundColor: Colors.black),
          body: Center(
            child: InteractiveViewer(
              child: Image.network(imageUrl),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isGivenAway = !book.isAvailable;

    return Scaffold(
      appBar: AppBar(
        title: Text(book.title),
        actions: isOwner
            ? [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => _editBook(context),
                ),
              ]
            : null,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (book.imageUrl != null)
              GestureDetector(
                onTap: () => _openImageFull(context, book.imageUrl!),
                child: Hero(
                  tag: book.imageUrl!,
                  child: Image.network(
                    book.imageUrl!,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            const SizedBox(height: 16),
            Text(book.title, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 4),
            Text(
              'by ${book.author}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            Text('Genre: ${book.genre}'),
            Text('Condition: ${book.condition}'),
            Text('City: ${book.city}'),
            const SizedBox(height: 16),
            Text(book.description),
          ],
        ),
      ),
      bottomNavigationBar: (!isGivenAway)
          ? Padding(
              padding: const EdgeInsets.all(16),
              child: isOwner
                  ? ElevatedButton.icon(
                      onPressed: () => _markAsGiven(context),
                      icon: const Icon(Icons.check),
                      label: const Text('Я отдал(а) книгу'),
                    )
                  : ElevatedButton.icon(
                      onPressed: () => _messageOwner(context),
                      icon: const Icon(Icons.message),
                      label: const Text('Написать владельцу'),
                    ),
            )
          : null,
    );
  }
}
