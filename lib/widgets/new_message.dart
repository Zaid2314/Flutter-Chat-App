// Path: lib/widgets/new_message.dart

import 'package:chat_app/services/gemini_service.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NewMessage extends StatefulWidget {
  const NewMessage({super.key});

  @override
  State<NewMessage> createState() => _NewMessageState();
}

class _NewMessageState extends State<NewMessage> {
  final _messageController = TextEditingController();
  final GeminiService _geminiService = GeminiService();

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  // Function to get response from AI and save it to Firestore
  Future<void> _getAiResponse(String prompt) async {
    try {
      final geminiResponse = await _geminiService.generateResponse(prompt);

      await FirebaseFirestore.instance.collection('chat').add({
        'text': geminiResponse,
        'createdAt': Timestamp.now(),
        'userId': GeminiService.aiUserId, // Special ID for AI
        'username': '@ai',
        'userImage': null, // AI does not have an image
        'isAIResponse': true, // ✅ CRITICAL: Flag for UI styling
      });
    } catch (e) {
      print('Firestore save error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to send AI response.')),
        );
      }
    }
  }

  Future<void> _submitMessage() async {
    final enteredMessage = _messageController.text;

    if (enteredMessage.trim().isEmpty) return;

    final user = FirebaseAuth.instance.currentUser!;
    _messageController.clear();
    FocusScope.of(context).unfocus();

    // Fetch user data
    final userData = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();

    // 1. Save the user's message first
    await FirebaseFirestore.instance.collection('chat').add({
      'text': enteredMessage,
      'createdAt': Timestamp.now(),
      'userId': user.uid,
      'username': userData.data()!['username'],
      'userImage': userData.data()!['userImage'],
      'isAIResponse': false, // User message is always false
    });

    // 2. Check for the AI command and trigger AI response
    if (enteredMessage.trim().toLowerCase().startsWith('@ai ')) {
      final prompt = enteredMessage.trim().substring(4);
      if (prompt.isNotEmpty) {
        // Run AI generation and saving without awaiting to keep UI responsive
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
          ),
        ],
      ),
    );
  }
}