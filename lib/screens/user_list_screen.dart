import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'private_chat_screen.dart';
import 'package:provider/provider.dart';

import '../main.dart';
import '../widgets/theme_switch_button.dart';

class UserListScreen extends StatefulWidget {
  const UserListScreen({super.key});

  @override
  State<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    final themeNotifier = Provider.of<ThemeNotifier>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pilih User untuk Chat'),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor ?? Colors.blue,
        foregroundColor: Theme.of(context).appBarTheme.foregroundColor ?? Colors.white,
        actions: const [
          ThemeSwitchButton(),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Cari kontak berdasarkan email',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.trim().toLowerCase();
                });
              },
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .where('email', isNotEqualTo: currentUser?.email)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(
                    child: Text('Terjadi kesalaha'),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                final users = snapshot.data?.docs ?? [];
                final filteredUsers = users.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final email = (data['email'] ?? '').toString().toLowerCase();
                  return _searchQuery.isEmpty || email.contains(_searchQuery);
                }).toList();

                if (filteredUsers.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.person_search,
                          size: 64,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Tidak ada user ditemukan',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: filteredUsers.length,
                  itemBuilder: (context, index) {
                    final userData = filteredUsers[index].data() as Map<String, dynamic>;
                    final email = userData['email'] ?? '';
                    final displayName = userData['displayName'] ?? email.split('@')[0];

                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.blue,
                        child: Text(
                          displayName[0].toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      title: Text(displayName),
                      subtitle: Text(email),
                      trailing: const Icon(Icons.chat),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PrivateChatScreen(
                              targetUserEmail: email,
                              targetUserName: displayName,
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
