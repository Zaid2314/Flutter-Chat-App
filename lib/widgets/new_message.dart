import 'package:chat_app/services/gemini_service.dart'; // Humari service file
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NewMessage extends StatefulWidget {
  const NewMessage({super.key});

  @override
  State<NewMessage> createState() {
    return _NewMessageState();
  }
}

class _NewMessageState extends State<NewMessage> {
  final _messageController = TextEditingController();
  final GeminiService _geminiService = GeminiService(); // Service ka instance

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  // AI se response lene aur save karne ka function
  Future<void> _getAiResponse(String prompt) async {
    final geminiResponse = await _geminiService.generateResponse(prompt);

    // AI ka response Firestore me save karein
    FirebaseFirestore.instance.collection('chat').add({
      'text': geminiResponse,
      'createdAt': Timestamp.now(),
      'userId': 'gemini-bot', // Bot ke liye ek unique ID
      'username': '@ai',      // Bot ka username
      'userImage': 'assets/images/gemini_avatar.png', // Bot ka avatar
    });
  }

  Future<void> _submitMessage() async {
    final enteredMessage = _messageController.text;

    if (enteredMessage.trim().isEmpty) {
      return;
    }

    final user = FirebaseAuth.instance.currentUser!;
    _messageController.clear();
    FocusScope.of(context).unfocus();

    // Pehle user ka message database me save karo
    final userData = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
    FirebaseFirestore.instance.collection('chat').add({
      'text': enteredMessage,
      'createdAt': Timestamp.now(),
      'userId': user.uid,
      'username': userData.data()!['username'],
      'userImage': userData.data()!['userImage'],
    });

    // Ab check karo ki kya yeh AI command hai
    if (enteredMessage.trim().toLowerCase().startsWith('@ai ')) {
      final prompt = enteredMessage.trim().substring(4);
      if (prompt.isNotEmpty) {
        _getAiResponse(prompt);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 15, right: 1, bottom: 14),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              textCapitalization: TextCapitalization.sentences,
              autocorrect: true,
              enableSuggestions: true,
              decoration: const InputDecoration(
                labelText: 'Send a Message... (use @ai for AI)',
              ),
            ),
          ),
          IconButton(
            color: Theme.of(context).colorScheme.primary,
            icon: const Icon(Icons.send),
            onPressed: _submitMessage,
          )
        ],
      ),
    );
  }
}