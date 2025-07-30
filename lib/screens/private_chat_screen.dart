import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/theme_switch_button.dart';

class PrivateChatScreen extends StatefulWidget {
  final String targetUserEmail;
  final String targetUserName;

  const PrivateChatScreen({
    super.key,
    required this.targetUserEmail,
    required this.targetUserName,
  });

  @override
  State<PrivateChatScreen> createState() => _PrivateChatScreenState();
}

class _PrivateChatScreenState extends State<PrivateChatScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();

  String get _chatId {
    final currentUserEmail = FirebaseAuth.instance.currentUser?.email ?? '';
    final emails = [currentUserEmail, widget.targetUserEmail];
    emails.sort();
    return emails.join('_');
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      await FirebaseFirestore.instance
          .collection('private_chats')
          .doc(_chatId)
          .collection('messages')
          .add({
        'text': _messageController.text.trim(),
        'senderEmail': user.email,
        'senderName': user.email?.split('@')[0] ?? 'Unknown',
        'timestamp': FieldValue.serverTimestamp(),
        'isDeleted': false,
        'isEdited': false,
      });

      _messageController.clear();
      
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal mengirim pesan')),
        );
      }
    }
  }

  Future<void> _deleteMessage(String messageId) async {
    try {
      await FirebaseFirestore.instance
          .collection('private_chats')
          .doc(_chatId)
          .collection('messages')
          .doc(messageId)
          .update({
        'isDeleted': true,
        'deletedAt': FieldValue.serverTimestamp(),
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pesan berhasil dihapus')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal menghapus pesan')),
        );
      }
    }
  }

  void _showDeleteConfirmation(String messageId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Pesan'),
        content: const Text('Apakah Anda yakin ingin menghapus pesan ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteMessage(messageId);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  Future<void> _editMessage(String messageId, String currentText) async {
    final TextEditingController editController = TextEditingController(text: currentText);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Pesan'),
        content: TextField(
          controller: editController,
          decoration: const InputDecoration(
            hintText: 'Edit pesan Anda...',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () {
              editController.dispose();
              Navigator.pop(context);
            },
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              final newText = editController.text.trim();
              if (newText.isNotEmpty && newText != currentText) {
                try {
                  await FirebaseFirestore.instance
                      .collection('private_chats')
                      .doc(_chatId)
                      .collection('messages')
                      .doc(messageId)
                      .update({
                    'text': newText,
                    'isEdited': true,
                    'editedAt': FieldValue.serverTimestamp(),
                  });
                  
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Pesan berhasil diedit')),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Gagal mengedit pesan')),
                    );
                  }
                }
              }
              editController.dispose();
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.blue,
            ),
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  void _showMessageOptions(String messageId, String messageText, bool isDeleted) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!isDeleted) ...[
              ListTile(
                leading: const Icon(Icons.edit, color: Colors.blue),
                title: const Text('Edit Pesan'),
                onTap: () {
                  Navigator.pop(context);
                  _editMessage(messageId, messageText);
                },
              ),
              const Divider(),
            ],
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Hapus Pesan', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                _showDeleteConfirmation(messageId);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat dengan ${widget.targetUserName}'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: const [ThemeSwitchButton()],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('private_chats')
                  .doc(_chatId)
                  .collection('messages')
                  .orderBy('timestamp', descending: false)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(
                    child: Text('Terjadi kesalahan'),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                final messages = snapshot.data?.docs ?? [];

                if (messages.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.chat_bubble_outline,
                          size: 64,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Mulai percakapan dengan ${widget.targetUserName}',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (_scrollController.hasClients) {
                    _scrollController.animateTo(
                      _scrollController.position.maxScrollExtent,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOut,
                    );
                  }
                });

                return ListView.builder(
                  controller: _scrollController,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final doc = messages[index];
                    final messageData = doc.data() as Map<String, dynamic>;
                    final text = messageData['text'] ?? '';
                    final senderEmail = messageData['senderEmail'] ?? '';
                    final senderName = messageData['senderName'] ?? '';
                    final timestamp = messageData['timestamp'] as Timestamp?;
                    final isCurrentUser = senderEmail == currentUser?.email;
                    final isDeleted = messageData['isDeleted'] == true;
                    final isEdited = messageData['isEdited'] == true;

                    return Align(
                      alignment: isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
                      child: GestureDetector(
                        onLongPress: isCurrentUser
                            ? () => _showMessageOptions(doc.id, text, isDeleted)
                            : null,
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                          decoration: BoxDecoration(
                            color: isDeleted
                                ? Colors.grey[200]
                                : isCurrentUser 
                                    ? Colors.blue[100] 
                                    : Colors.grey[200],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (!isCurrentUser)
                                Text(
                                  senderName,
                                  style: const TextStyle(
                                    fontSize: 12, 
                                    color: Colors.black54, 
                                    fontWeight: FontWeight.bold
                                  ),
                                ),
                              isDeleted
                                  ? const Text(
                                      'Pesan telah dihapus',
                                      style: TextStyle(
                                        fontStyle: FontStyle.italic, 
                                        color: Colors.grey
                                      ),
                                    )
                                  : Text(
                                      text,
                                      style: const TextStyle(
                                        fontSize: 16, 
                                        color: Colors.black
                                      ),
                                    ),
                              const SizedBox(height: 4),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    timestamp != null
                                        ? _formatTime(timestamp.toDate())
                                        : '',
                                    style: const TextStyle(
                                      fontSize: 10, 
                                      color: Colors.black45
                                    ),
                                  ),
                                  if (isEdited && !isDeleted) ...[
                                    const SizedBox(width: 4),
                                    const Text(
                                      '(diedit)',
                                      style: TextStyle(
                                        fontSize: 9,
                                        color: Colors.black45,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withValues(alpha: 0.3),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: const Offset(0, -1),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: 'Ketik pesan...',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _sendMessage,
                  icon: const Icon(Icons.send),
                  color: Colors.blue,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}j';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m';
    } else {
      return 'Baru saja';
    }
  }
}
