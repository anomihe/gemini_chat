import 'package:chat_with_ai/localStore/chat_history.dart';
import 'package:chat_with_ai/main.dart';
import 'package:chat_with_ai/providers/chat_provider.dart';
import 'package:chat_with_ai/utili/utility.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ChatHistoryWidget extends StatelessWidget {
  const ChatHistoryWidget({
    super.key,
    required this.chat,
  });

  final ChatHistory chat;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        contentPadding: EdgeInsets.only(left: 10.0, right: 10.0),
        leading: CircleAvatar(
          radius: 30,
          child: Icon(Icons.chat),
        ),
        title: Text(
          chat.prompt,
          maxLines: 1,
        ),
        subtitle: Text(
          chat.response,
          maxLines: 2,
        ),
        trailing: Icon(Icons.arrow_forward_ios),
        onTap: () async {
          final chatProvider = context.read<ChatProvider>();
          await chatProvider.prepareChatRoom(
              isNewChat: false, chatId: chat.chatId);
          chatProvider.setCurrentIndex(newIndex: 1);
          chatProvider.pageController.jumpToPage(1);
        },
        onLongPress: () {
          showMyAnimatedDialog(
            context: context,
            title: 'Delete Chat',
            content: 'Are you sure you want to delete this chat',
            actionText: 'Delete',
            onActionPressed: (bool value) async {
              if (value) {
                await context
                    .read<ChatProvider>()
                    .deleteChatMessage(chatId: chat.chatId);
                await chat.delete();
              }
            },
          );
        },
      ),
    );
  }
}
