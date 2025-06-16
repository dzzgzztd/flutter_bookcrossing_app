import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../core/models/book_model.dart';

class UserBooksPage extends StatelessWidget {
  final String userId;
  final bool isAvailable;

  const UserBooksPage({
    super.key,
    required this.userId,
    required this.isAvailable,
  });

  Future<List<BookModel>> _fetchBooks() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('books')
        .where('ownerId', isEqualTo: userId)
        .where('isAvailable', isEqualTo: isAvailable)
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => BookModel.fromJson(doc.data()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final title = isAvailable ? 'Актуальные предложения' : 'Отданные книги';

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: FutureBuilder<List<BookModel>>(
        future: _fetchBooks(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Ошибка: ${snapshot.error}'));
          }

          final books = snapshot.data!;
          if (books.isEmpty) {
            return Center(child: Text(isAvailable
                ? 'Нет актуальных предложений.'
                : 'Нет отданных книг.'));
          }

          return ListView.builder(
            itemCount: books.length,
            itemBuilder: (context, index) {
              final book = books[index];
              return ListTile(
                leading: book.imageUrl != null
                    ? Image.network(book.imageUrl!, width: 40, height: 40, fit: BoxFit.cover)
                    : const Icon(Icons.book),
                title: Text(book.title),
                subtitle: Text(book.author),
                onTap: () => Navigator.pushNamed(context, '/book', arguments: book),
              );
            },
          );
        },
      ),
    );
  }
}
