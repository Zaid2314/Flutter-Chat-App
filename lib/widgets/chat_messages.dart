// Path: lib/widgets/chat_messages.dart

import 'package:chat_app/widgets/message_bubble.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:chat_app/services/gemini_service.dart';

class ChatMessages extends StatelessWidget {
  const ChatMessages({super.key});

  @override
  Widget build(BuildContext context) {
    final authenticatedUser = FirebaseAuth.instance.currentUser!;

    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('chat')
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (ctx, chatSnapshot) {
        if (chatSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!chatSnapshot.hasData || chatSnapshot.data!.docs.isEmpty) {
          return const SizedBox.shrink();
        }

        final loadedMessages = chatSnapshot.data!.docs;

        return ListView.builder(
          padding: const EdgeInsets.only(bottom: 40, left: 13, right: 13),
          reverse: true,
          itemCount: loadedMessages.length,
          itemBuilder: (ctx, index) {
            final chatMessage = loadedMessages[index].data();

            // Extract isAIResponse and use fallback check (using AI ID)
            final isAIResponse = chatMessage.containsKey('isAIResponse')
                ? chatMessage['isAIResponse'] as bool
                : chatMessage['userId'] == GeminiService.aiUserId;

            final nextChatMessage = index + 1 < loadedMessages.length
                ? loadedMessages[index + 1].data()
                : null;

            final currentMessageUserId = chatMessage['userId'];
            final nextMessageUserId =
            nextChatMessage != null ? nextChatMessage['userId'] : null;

            final isNextUserSame = nextMessageUserId == currentMessageUserId;

            final timestamp = chatMessage['createdAt'] as Timestamp;

            if (isNextUserSame) {
              return MessageBubble.next(
                message: chatMessage['text'],
                isMe: authenticatedUser.uid == currentMessageUserId,
                createdAt: timestamp,
                isAIResponse: isAIResponse, // ✅ PASS NEW PROPERTY
              );
            } else {
              return MessageBubble.first(
                userImage: chatMessage['userImage'],
                username: chatMessage['username'],
                message: chatMessage['text'],
                isMe: authenticatedUser.uid == currentMessageUserId,
                createdAt: timestamp,
                isAIResponse: isAIResponse, // ✅ PASS NEW PROPERTY
              );
            }
          },
        );
      },
    );
  }
}