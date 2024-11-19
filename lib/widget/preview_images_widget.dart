import 'dart:io';

import 'package:chat_with_ai/models/message_model.dart';
import 'package:chat_with_ai/providers/chat_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PreviewImagesWidget extends StatelessWidget {
  final MessageModel? messageModel;
  const PreviewImagesWidget({super.key, this.messageModel});

  @override
  Widget build(BuildContext context) {
    return Consumer<ChatProvider>(builder: (context, chatProvider, child) {
      final messageToShow = messageModel != null
          ? messageModel!.imageUrl
          : chatProvider.imageFileList;
      final padding = messageModel != null
          ? EdgeInsets.zero
          : EdgeInsets.only(left: 8.0, right: 8.0);
      return Padding(
        padding: padding,
        child: SizedBox(
          height: 80,
          child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: messageToShow!.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.fromLTRB(4.0, 8.0, 4.0, 8.0),
                  child: ClipRRect(
                      borderRadius: BorderRadius.circular(20.0),
                      child: Image.file(
                        File(
                          messageModel != null
                              ? messageModel!.imageUrl[index]
                              : chatProvider.imageFileList![index]
                                  .path /*messageToShow[index].path*/,
                        ),
                        fit: BoxFit.cover,
                        height: 80,
                        width: 80,
                      )),
                );
              }),
        ),
      );
    });
  }
}
