import 'package:chat_with_ai/models/message_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class AssistantMessageWidget extends StatelessWidget {
  final String messageModel;
  const AssistantMessageWidget({super.key, required this.messageModel});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        padding: const EdgeInsets.all(15),
        constraints:
            BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.9),
        margin: EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(18)),
        child: messageModel.isEmpty
            ? SizedBox(
                width: 50,
                child: SpinKitThreeBounce(
                  color: Colors.blueGrey,
                  size: 20,
                ),
              )
            : MarkdownBody(
                data: messageModel,
                selectable: true,
              ),
      ),
    );
  }
}
