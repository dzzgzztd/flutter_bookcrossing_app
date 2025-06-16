import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/book_model.dart';

class BookService {
  final _firestore = FirebaseFirestore.instance;

  Future<void> addBook(BookModel book) async {
    await _firestore.collection('books').doc(book.id).set(book.toJson());
  }

  Future<List<BookModel>> fetchBooks() async {
    final snapshot =
        await _firestore
            .collection('books')
            .orderBy('createdAt', descending: true)
            .get();
    return snapshot.docs.map((doc) => BookModel.fromJson(doc.data())).toList();
  }

  Future<void> deleteBook(String bookId) async {
    await FirebaseFirestore.instance.collection('books').doc(bookId).delete();
  }

  Future<void> markAsGiven(String bookId) async {
    await FirebaseFirestore.instance.collection('books').doc(bookId).update({
      'isAvailable': false,
    });
  }

  Future<void> updateBook(BookModel book) async {
    await FirebaseFirestore.instance
        .collection('books')
        .doc(book.id)
        .update(book.toJson());
  }
}
