import 'dart:developer';

import 'package:chat_with_ai/providers/chat_provider.dart';
import 'package:chat_with_ai/utili/utility.dart';
import 'package:chat_with_ai/widget/preview_images_widget.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class BottomChatField extends StatefulWidget {
  const BottomChatField({super.key, required this.chatProvider});
  final ChatProvider chatProvider;
  @override
  State<BottomChatField> createState() => _BottomChatFieldState();
}

class _BottomChatFieldState extends State<BottomChatField> {
  final TextEditingController _messageController = TextEditingController();
  final FocusNode _textFieldFocus = FocusNode();
  final ImagePicker _picker = ImagePicker();
  @override
  void dispose() {
    _messageController.dispose();
    _textFieldFocus.dispose();
    super.dispose();
  }

  void pickImage() async {
    try {
      final List<XFile> image = await _picker.pickMultiImage(
        maxHeight: 800,
        maxWidth: 800,
        imageQuality: 95,
      );
      widget.chatProvider.setImageFileList(images: image);
    } catch (e) {
      log('error: $e');
    }
  }

  Future<void> sendChatMessage(
      {required String message,
      required ChatProvider chatProvider,
      required bool isTextOnly}) async {
    try {
      await chatProvider.sendMessage(message: message, isTextOnly: isTextOnly);
    } catch (e) {
      log('error: $e');
    } finally {
      _messageController.clear();
      widget.chatProvider.setImageFileList(images: []);
      _textFieldFocus.unfocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    bool hasImages = widget.chatProvider.imageFileList != null &&
        widget.chatProvider.imageFileList!.isNotEmpty;
    return Container(
      decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Theme.of(context).textTheme.titleLarge!.color!,
          )
          //        boxShadow: [
          // BoxShadow(
          //   color: Colors.grey.withOpacity(0.5),
          //   spreadRadius: 5,
          //   blurRadius: 7,
          //   offset: const Offset(0, 3),
          // )
          //]
          ),
      child: Column(
        children: [
          if (hasImages) PreviewImagesWidget(),
          Row(
            children: [
              IconButton(
                  onPressed: () {
                    //pick image
                    if (hasImages) {
                      showMyAnimatedDialog(
                        title: 'Delete Image',
                        context: context,
                        content: 'Are you sure you want to delete the image?',
                        actionText: 'Delete',
                        onActionPressed: (bool value) {
                          if (value) {
                            widget.chatProvider.setImageFileList(images: []);
                          }
                        },
                      );
                    } else {
                      pickImage();
                    }
                  },
                  icon: Icon(hasImages ? Icons.delete : Icons.image)),
              const SizedBox(
                width: 5,
              ),
              Expanded(
                  child: TextField(
                controller: _messageController,
                focusNode: _textFieldFocus,
                textInputAction: TextInputAction.send,
                onSubmitted: widget.chatProvider.isLoading
                    ? null
                    : (String value) {
                        if (value.isNotEmpty) {
                          sendChatMessage(
                              message: value,
                              chatProvider: widget.chatProvider,
                              isTextOnly: hasImages ? false : true);
                        }
                      },
                decoration: InputDecoration.collapsed(
                  hintText: 'Enter a prompt',
                  border: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.circular(30)),
                ),
              )),
              GestureDetector(
                onTap: widget.chatProvider.isLoading
                    ? null
                    : () {
                        //send message
                        if (_messageController.text.isNotEmpty) {
                          sendChatMessage(
                              message: _messageController.text,
                              chatProvider: widget.chatProvider,
                              isTextOnly: hasImages ? false : true);
                        }
                      },
                child: Container(
                    decoration: BoxDecoration(
                        color: Colors.deepPurple,
                        borderRadius: BorderRadius.circular(20)),
                    margin: EdgeInsets.all(5.0),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Icon(
                        Icons.arrow_upward,
                        color: Colors.white,
                      ),
                    )),
              )
              // IconButton(onPressed: () {}, icon: Icon(Icons.add))
            ],
          ),
        ],
      ),
    );
  }
}
