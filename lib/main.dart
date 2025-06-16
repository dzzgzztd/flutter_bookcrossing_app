import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bookcrossing_app/features/profile/user_books_page.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'core/models/book_model.dart';
import 'features/profile/edit_profile_page.dart';
import 'features/profile/profile_page.dart';
import 'firebase_options.dart';
import 'features/books/book_list_page.dart';
import 'features/books/book_detail_page.dart';
import 'features/books/book_form_page.dart';
import 'features/auth/login_page.dart';
import 'features/auth/register_page.dart';
import 'core/services/book_service.dart';
import 'core/services/auth_service.dart';
import 'features/chat/chat_list_page.dart';
import 'features/chat/chat_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await dotenv.load(fileName: 'assets/env/.env');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        final user = snapshot.data;

        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Bookcrossing App',
          theme: ThemeData(
            useMaterial3: true,
            colorSchemeSeed: Colors.deepPurple,
          ),
          initialRoute: '/',
          onGenerateRoute: (settings) {
            switch (settings.name) {
              case '/':
                return MaterialPageRoute(
                  builder:
                      (_) =>
                          user != null
                              ? const BookListPage()
                              : LoginPage(authService: AuthService()),
                );

              case '/book':
                final book = settings.arguments as BookModel;
                return MaterialPageRoute(
                  builder: (_) => BookDetailPage(book: book),
                );

              case '/login':
                return MaterialPageRoute(
                  builder: (_) => LoginPage(authService: AuthService()),
                );

              case '/register':
                return MaterialPageRoute(
                  builder: (_) => RegisterPage(authService: AuthService()),
                );

              case '/profile':
                return MaterialPageRoute(builder: (_) => const ProfilePage());
              case '/edit-profile':
                return MaterialPageRoute(
                  builder: (_) => const EditProfilePage(),
                );

              case '/user-profile':
                final userId = settings.arguments as String;
                return MaterialPageRoute(
                  builder: (_) => ProfilePage(userId: userId),
                );

              case '/add-book':
                if (user == null) {
                  return MaterialPageRoute(
                    builder: (_) => LoginPage(authService: AuthService()),
                  );
                }
                return MaterialPageRoute(
                  builder:
                      (_) => BookFormPage(
                        currentUserId: user.uid,
                        bookService: BookService(),
                      ),
                );

              case '/edit-book':
                final args = settings.arguments as Map<String, dynamic>;
                final book = args['book'] as BookModel;
                final userId = args['userId'] as String;

                return MaterialPageRoute(
                  builder:
                      (_) => BookFormPage(
                        currentUserId: userId,
                        bookService: BookService(),
                        bookToEdit: book,
                      ),
                );

              case '/chats':
                return MaterialPageRoute(builder: (_) => ChatListPage());

              case '/chat':
                final args = settings.arguments as Map<String, dynamic>;
                final chatId = args['chatId'] as String;
                final otherUserId = args['otherUserId'] as String;
                return MaterialPageRoute(
                  builder:
                      (_) => ChatPage(chatId: chatId, otherUserId: otherUserId),
                );

              case '/user-books':
                final args = settings.arguments as Map<String, dynamic>;
                return MaterialPageRoute(
                  builder:
                      (_) => UserBooksPage(
                        userId: args['userId'],
                        isAvailable: args['isAvailable'],
                      ),
                );

              default:
                return MaterialPageRoute(
                  builder:
                      (_) => const Scaffold(
                        body: Center(child: Text('404 — Page Not Found')),
                      ),
                );
            }
          },
        );
      },
    );
  }
}
