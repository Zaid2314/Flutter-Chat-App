// Path: lib/widgets/message_bubble.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class MessageBubble extends StatelessWidget {
  const MessageBubble.first({
    super.key,
    required this.userImage,
    required this.username,
    required this.message,
    required this.isMe,
    required this.createdAt,
    required this.isAIResponse, // 🎯 NEW: Must be passed
  }) : isFirstInSequence = true;

  const MessageBubble.next({
    super.key,
    required this.message,
    required this.isMe,
    required this.createdAt,
    required this.isAIResponse, // 🎯 NEW: Must be passed
  })  : isFirstInSequence = false,
        userImage = null,
        username = null;

  final bool isFirstInSequence;
  final String? userImage;
  final String? username;
  final String message;
  final bool isMe;
  final Timestamp createdAt;
  final bool isAIResponse; // 🎯 NEW PROPERTY

  // Helper function to handle both network and asset images
  ImageProvider _getImageProvider(String? path) {
    if (path != null && path.startsWith('http')) {
      return NetworkImage(path);
    } else {
      return const AssetImage('assets/images/avatar.png');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final formattedTime = DateFormat.jm().format(createdAt.toDate());

    // 🎯 AI-specific alignment and styling logic
    final mainAxisAlignment = isAIResponse
        ? MainAxisAlignment.start // AI messages are always left-aligned
        : isMe
        ? MainAxisAlignment.end
        : MainAxisAlignment.start;

    final bubbleColor = isAIResponse
        ? Colors.indigo.shade50 // Distinct, light color for AI
        : isMe
        ? theme.colorScheme.primary.withOpacity(0.8)
        : theme.colorScheme.secondary.withOpacity(0.8);

    final textColor = isAIResponse
        ? Colors.black87
        : isMe
        ? theme.colorScheme.onPrimary
        : theme.colorScheme.onSecondary;

    return Stack(
      children: [
        if (isFirstInSequence)
          Positioned(
            top: 15,
            right: isMe && !isAIResponse ? 0 : null,
            left: !isMe && !isAIResponse ? 0 : null,
            child: isAIResponse
                ? const Padding(
              padding: EdgeInsets.only(left: 0),
              child: CircleAvatar(
                // 🎯 AI Icon
                child: Icon(Icons.psychology_outlined, size: 24, color: Colors.indigo),
                backgroundColor: Colors.white,
                radius: 23,
              ),
            )
                : CircleAvatar(
              backgroundImage: _getImageProvider(userImage),
              backgroundColor: theme.colorScheme.primary.withAlpha(180),
              radius: 23,
            ),
          ),
        Container(
          // 🎯 Adjust margin for AI's left-aligned icon
          margin: EdgeInsets.symmetric(horizontal: isAIResponse ? 50 : 46),
          child: Row(
            mainAxisAlignment: mainAxisAlignment,
            children: [
              Column(
                crossAxisAlignment: isAIResponse || !isMe
                    ? CrossAxisAlignment.start
                    : CrossAxisAlignment.end,
                children: [
                  if (isFirstInSequence) const SizedBox(height: 18),
                  if (username != null)
                    Padding(
                      padding: const EdgeInsets.only(left: 13, right: 13),
                      child: Text(
                        username!,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isAIResponse
                              ? Colors.indigo.shade700 // AI username color
                              : theme.colorScheme.onSurface,
                        ),
                      ),
                    ),
                  Container(
                    decoration: BoxDecoration(
                      color: bubbleColor,
                      borderRadius: BorderRadius.only(
                        // Remove avatar cutout for AI bubbles
                        topLeft: isAIResponse || (!isMe && isFirstInSequence)
                            ? Radius.zero
                            : const Radius.circular(12),
                        topRight: isAIResponse || (isMe && isFirstInSequence)
                            ? Radius.zero
                            : const Radius.circular(12),
                        bottomLeft: const Radius.circular(12),
                        bottomRight: const Radius.circular(12),
                      ),
                    ),
                    constraints: const BoxConstraints(maxWidth: 220),
                    padding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 14,
                    ),
                    margin: const EdgeInsets.symmetric(
                      vertical: 4,
                      horizontal: 12,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          message,
                          style: TextStyle(
                            height: 1.3,
                            color: textColor,
                          ),
                          softWrap: true,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          formattedTime,
                          style: TextStyle(
                            fontSize: 12,
                            color: textColor.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}