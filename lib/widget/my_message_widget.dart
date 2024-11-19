import 'package:chat_with_ai/models/message_model.dart';
import 'package:chat_with_ai/widget/preview_images_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class MyMessageWidget extends StatelessWidget {
  final MessageModel messageModel;
  const MyMessageWidget({super.key, required this.messageModel});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        padding: const EdgeInsets.all(15),
        constraints:
            BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
        margin: EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(18)),
        child: Column(
          children: [
            if (messageModel.imageUrl.isNotEmpty)
              PreviewImagesWidget(
                messageModel: messageModel,
              ),
            MarkdownBody(
              data: messageModel.message.toString(),
              selectable: true,
            ),
          ],
        ),
      ),
    );
  }
}
