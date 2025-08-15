import 'package:chatting_app/widgets/message_bubble.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatMessages extends StatelessWidget {
  const ChatMessages({super.key});

  @override
  Widget build(BuildContext context) {
    final authenticatedUser = FirebaseAuth.instance.currentUser;

    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('chat')
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (ctx, chatSnapshots) {
        if (chatSnapshots.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (!chatSnapshots.hasData || chatSnapshots.data!.docs.isEmpty) {
          return Center(child: Text('No messages found!'));
        }
        if (chatSnapshots.hasError) {
          return Center(child: Text('Something went wrong!'));
        }

        final loadedMessages = chatSnapshots.data!.docs;

        return ListView.builder(
          padding: EdgeInsets.only(left: 13, right: 13, bottom: 40),
          itemCount: loadedMessages.length,
          reverse: true,
          itemBuilder: (ctx, index) {
            final chatMessage = loadedMessages[index].data();
            final nextChatMessage = (index + 1) < loadedMessages.length
                ? loadedMessages[index + 1].data()
                : null;
            final currentMessageUserId = chatMessage['userId'];
            final nextMessageUserId = nextChatMessage != null
                ? nextChatMessage['userId']
                : null;

            final isNextUserSame = currentMessageUserId == nextMessageUserId;

            if (isNextUserSame) {
              return MessageBubble.next(
                message: chatMessage['text'],
                isMe: currentMessageUserId == authenticatedUser!.uid,
              );
            } else {
              return MessageBubble.first(
                userImage: null,
                username: chatMessage['username'],
                message: chatMessage['text'],
                isMe: currentMessageUserId == authenticatedUser!.uid,
              );
            }

            //  Text('${loadedMessages[index].data()['text']}');
          },
        );
      },
    );
  }
}
