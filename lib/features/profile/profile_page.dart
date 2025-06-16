import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../core/models/user_model.dart';
import '../../core/services/user_service.dart';

class ProfilePage extends StatelessWidget {
  final String? userId;

  const ProfilePage({super.key, this.userId});

  Future<UserModel?> _loadUserData() async {
    final id = userId ?? FirebaseAuth.instance.currentUser?.uid;
    if (id == null) return null;
    return await UserService().getUserProfile(id);
  }

  void _onTabTapped(BuildContext context, int index) {
    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/');
        break;
      case 1:
        Navigator.pushReplacementNamed(context, '/chats');
        break;
      case 2:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    return FutureBuilder<UserModel?>(
      future: _loadUserData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        final user = snapshot.data;
        if (user == null) {
          return const Scaffold(body: Center(child: Text('Пользователь не найден')));
        }

        final isOwner = currentUser != null && currentUser.uid == user.id;

        return Scaffold(
          appBar: AppBar(title: Text(isOwner ? 'My Profile' : user.name)),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (user.avatarUrl != null)
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: NetworkImage(user.avatarUrl!),
                  )
                else
                  const CircleAvatar(
                    radius: 50,
                    child: Icon(Icons.person, size: 40),
                  ),
                const SizedBox(height: 12),
                Text(
                  user.name,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 16),
                if (isOwner) ...[
                  ElevatedButton(
                    onPressed: () => Navigator.pushNamed(context, '/edit-profile'),
                    child: const Text('Edit Profile'),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () async {
                      await FirebaseAuth.instance.signOut();
                      if (context.mounted) {
                        Navigator.pushReplacementNamed(context, '/login');
                      }
                    },
                    child: const Text('Logout'),
                  ),
                ],
                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  icon: const Icon(Icons.menu_book),
                  label: const Text('Актуальные предложения'),
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      '/user-books',
                      arguments: {'userId': user.id, 'isAvailable': true},
                    );
                  },
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  icon: const Icon(Icons.done),
                  label: const Text('Отданные книги'),
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      '/user-books',
                      arguments: {'userId': user.id, 'isAvailable': false},
                    );
                  },
                ),
              ],
            ),
          ),
          bottomNavigationBar: isOwner
              ? BottomNavigationBar(
                  currentIndex: 2,
                  onTap: (index) => _onTabTapped(context, index),
                  items: const [
                    BottomNavigationBarItem(icon: Icon(Icons.book), label: 'Books'),
                    BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Chats'),
                    BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
                  ],
                )
              : null,
        );
      },
    );
  }
}
