import 'package:chat_with_ai/models/message_model.dart';
import 'package:chat_with_ai/utili/utility.dart';
import 'package:chat_with_ai/widget/assistant_message_widget.dart';
import 'package:chat_with_ai/widget/bottom_chat_field.dart';
import 'package:chat_with_ai/widget/my_message_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/chat_provider.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ScrollController scrollController = ScrollController();
  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients &&
          scrollController.position.maxScrollExtent > 0.0) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: Duration(microseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ChatProvider>(
      builder: (BuildContext context, chatProvider, Widget? child) {
        if (chatProvider.isChatMessage.isNotEmpty) {
          _scrollToBottom();
        }
        chatProvider.addListener(() {
          if (chatProvider.isChatMessage.isNotEmpty) {
            _scrollToBottom();
          }
        });

        return Scaffold(
          appBar: AppBar(
            backgroundColor: Theme.of(context).colorScheme.surface,
            centerTitle: true,
            title: Text('Chat with Germini'),
            actions: [
              if (chatProvider.isChatMessage.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CircleAvatar(
                    child: IconButton(
                        onPressed: () async {
                          // await chatProvider.deleteChatMessage(
                          //     chatId: chatProvider.currentChatId);
                          showMyAnimatedDialog(
                              context: context,
                              title: 'Start New Chat',
                              content:
                                  'Are you sure you want to start a new chat?',
                              actionText: 'Yes',
                              onActionPressed: (value) async {
                                if (value) {
                                  await chatProvider.prepareChatRoom(
                                      isNewChat: true, chatId: '');
                                }
                              });
                        },
                        icon: Icon(Icons.add)),
                  ),
                )
            ],
          ),
          body: SafeArea(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                children: [
                  Expanded(
                    child: chatProvider.isChatMessage.isEmpty
                        ? const Center(
                            child: Text('no messages'),
                          )
                        : ListView.builder(
                            controller: scrollController,
                            itemCount: chatProvider.isChatMessage.length,
                            itemBuilder: (context, index) {
                              final chat = chatProvider.isChatMessage[index];
                              return chat.role == Role.user
                                  ? MyMessageWidget(messageModel: chat)
                                  : AssistantMessageWidget(
                                      messageModel: chat.message.toString());
                              // ListTile(
                              //   title: Text(chat.message.toString()),
                              //   // subtitle: Text(chat.message.),
                              // );
                            }),
                  ),
                  BottomChatField(
                    chatProvider: chatProvider,
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
