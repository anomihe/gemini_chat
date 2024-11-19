import 'package:chat_with_ai/localStore/boxes.dart';
import 'package:chat_with_ai/localStore/chat_history.dart';
import 'package:chat_with_ai/providers/chat_provider.dart';
import 'package:chat_with_ai/utili/utility.dart';
import 'package:chat_with_ai/widget/chat_history_widget.dart';
import 'package:chat_with_ai/widget/empty_screen_widget.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

class ChatHistoryScreen extends StatefulWidget {
  const ChatHistoryScreen({super.key});

  @override
  State<ChatHistoryScreen> createState() => _ChatHistoryScreenState();
}

class _ChatHistoryScreenState extends State<ChatHistoryScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        centerTitle: true,
        title: Text('Chat History'),
      ),
      body: ValueListenableBuilder<Box<ChatHistory>>(
          valueListenable: Boxes.getChatHistory().listenable(),
          builder: (context, box, _) {
            final chatHistory =
                box.values.toList().cast<ChatHistory>().reversed.toList();
            return chatHistory.isEmpty
                ? EmptyScreenWidget()
                : Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: ListView.builder(
                        itemCount: chatHistory.length,
                        itemBuilder: (context, index) {
                          final chat = chatHistory[index];
                          return ChatHistoryWidget(chat: chat);
                        }),
                  );
          }),
    );
  }
}
