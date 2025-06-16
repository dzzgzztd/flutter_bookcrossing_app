import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:string_similarity/string_similarity.dart';
import '../../core/models/book_model.dart';

class BookListPage extends StatefulWidget {
  const BookListPage({super.key});

  @override
  State<BookListPage> createState() => _BookListPageState();
}

class _BookListPageState extends State<BookListPage> {
  late Future<List<BookModel>> _booksFuture;
  String _selectedCity = 'Москва';
  final List<String> _cities = [
    'Москва',
    'Санкт-Петербург',
    'Новосибирск',
    'Екатеринбург',
    'Россия',
  ];
  String _searchQuery = '';
  final int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _booksFuture = _fetchBooks();
  }

  Future<List<BookModel>> _fetchBooks() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('books')
        .where('isAvailable', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .get();
    return snapshot.docs.map((doc) => BookModel.fromJson(doc.data())).toList();
  }

  void _onTabTapped(int index) {
    if (index == _selectedIndex) return;

    switch (index) {
      case 0:
        break;
      case 1:
        Navigator.pushReplacementNamed(context, '/chats');
        break;
      case 2:
        Navigator.pushReplacementNamed(context, '/profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Books'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(104),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8),
                child: TextField(
                  decoration: const InputDecoration(
                    hintText: 'Search by title or author...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value.toLowerCase();
                    });
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4),
                child: DropdownButtonFormField<String>(
                  value: _selectedCity,
                  items: _cities
                      .map((city) => DropdownMenuItem(
                            value: city,
                            child: Text(city),
                          ))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedCity = value;
                      });
                    }
                  },
                  decoration: const InputDecoration(
                    labelText: 'Город',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/add-book'),
        child: const Icon(Icons.add),
      ),
      body: FutureBuilder<List<BookModel>>(
        future: _booksFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          var books = snapshot.data ?? [];

          books = books.where((book) {
            final matchesCity = book.city == 'Россия' || book.city == _selectedCity;

            final query = _searchQuery.trim();
            if (query.isEmpty) return matchesCity;

            final titleScore = book.title.similarityTo(query);
            final authorScore = book.author.similarityTo(query);

            return matchesCity && (titleScore > 0.3 || authorScore > 0.3);
          }).toList();

          if (books.isEmpty) {
            return const Center(child: Text('No books found'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: books.length,
            itemBuilder: (context, index) {
              final book = books[index];
              return Card(
                child: ListTile(
                  leading: book.imageUrl != null
                      ? Image.network(
                          book.imageUrl!,
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                        )
                      : const Icon(Icons.book),
                  title: Text(book.title),
                  subtitle: Text('${book.author} — ${book.city}'),
                  onTap: () => Navigator.pushNamed(
                    context,
                    '/book',
                    arguments: book,
                  ),
                ),
              );
            },
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onTabTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.menu_book), label: 'Books'),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Chats'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
