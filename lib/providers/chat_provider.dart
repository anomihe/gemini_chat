import 'dart:developer';
import 'dart:typed_data';

import 'package:chat_with_ai/api/api_service.dart';
import 'package:chat_with_ai/constants.dart';
import 'package:chat_with_ai/localStore/boxes.dart';
import 'dart:io';
import 'package:chat_with_ai/localStore/chat_history.dart';
import 'package:chat_with_ai/localStore/setting.dart';
import 'package:chat_with_ai/localStore/user_mode.dart';
import 'package:chat_with_ai/models/message_model.dart';
import 'package:chat_with_ai/screens/chat_history_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:path_provider/path_provider.dart' as path;
import 'package:uuid/uuid.dart';

class ChatProvider extends ChangeNotifier {
  final List<MessageModel> _message = [];

  final PageController _pageController = PageController();

  List<XFile> _imageFileList = [];
  GenerativeModel? _model;
  GenerativeModel? _textModel;
  GenerativeModel? _visionModel;
  int _currentIndex = 0;
  String _currentChatId = '';

  String _modelType = 'gemini-pro';

  bool _isLoading = false;

  List<MessageModel> get isChatMessage => _message;

  PageController get pageController => _pageController;
  List<XFile>? get imageFileList => _imageFileList;
  int get currentIndex => _currentIndex;
  String get currentChatId => _currentChatId;
  GenerativeModel? get model => _model;
  GenerativeModel? get textModel => _textModel;
  GenerativeModel? get visionModel => _visionModel;
  String get modelType => _modelType;
  bool get isLoading => _isLoading;

//setter
  // set isChatMessage(List<MessageModel> value) {
  //   isChatMessage = value;
  //   notifyListeners();
  // }

//delete chat message
  Future<void> deleteChatMessage({required String chatId}) async {
    if (!Hive.isBoxOpen('${Constants.chatMessagesBox}$chatId')) {
      await Hive.openBox('${Constants.chatMessagesBox}$chatId');

      //delete all the messages in the box
      await Hive.box('${Constants.chatMessagesBox}$chatId').clear();
      //close the box
      await Hive.box('${Constants.chatMessagesBox}$chatId').close();
    } else {
      await Hive.box('${Constants.chatMessagesBox}$chatId').clear();
      //close the box
      await Hive.box('${Constants.chatMessagesBox}$chatId').close();
    }
    // get the current chatId history if it is not empty
    // we check if its the same as the chatId
    if (currentChatId.isNotEmpty) {
      if (currentChatId == chatId) {
        setCurrentId(newChatId: '');
        isChatMessage.clear();
        notifyListeners();
      }
    }
  }

  //prepare jumpto
  Future<void> prepareChatRoom(
      {required bool isNewChat, required String chatId}) async {
    if (!isNewChat) {
      //load chat from db
      final chatHist = await loadMessageFromDb(chatId: chatId);
      //clear the in chat message
      isChatMessage.clear();
      for (var message in chatHist) {
        isChatMessage.add(message);
      }
      setCurrentId(newChatId: chatId);
    } else {
      isChatMessage.clear();
      setCurrentId(newChatId: chatId);
    }
  }

  Future<void> setInChatMessage({required chatId}) async {
    final messageFromDb = await loadMessageFromDb(chatId: chatId);
    for (var message in messageFromDb) {
      if (isChatMessage.contains(message)) {
        log('message already exists');
        continue;
      }
      isChatMessage.add(message);
    }
    notifyListeners();
  }

  //load messages from db
  Future<List<MessageModel>> loadMessageFromDb({required String chatId}) async {
    //open Db
    await Hive.openBox('${Constants.chatMessagesBox}$chatId');
    final messageBox = Hive.box('${Constants.chatMessagesBox}$chatId');

    final newData = messageBox.keys.map((e) {
      final message = messageBox.get(e);
      final messageData = MessageModel.from(Map<String, dynamic>.from(message));
      return messageData;
    }).toList();
    notifyListeners();
    return newData;
  }

  //set file list
  void setImageFileList({required List<XFile> images}) {
    _imageFileList = images;
    notifyListeners();
  }

  String setCurrentModel({required String newModel}) {
    _modelType = newModel;
    notifyListeners();
    return newModel;
  }

  //function to set the model based on bool - isTextOnly

  Future<void> setModel({required bool isTextOnly}) async {
    if (isTextOnly) {
      _model = _textModel ??
          GenerativeModel(
            model: setCurrentModel(newModel: 'gemini-1.5-pro'),
            // apiKey: ApiServices.apiKey,
            apiKey: getApiKey(),
            generationConfig: GenerationConfig(
                temperature: 0.4, topK: 32, topP: 1, maxOutputTokens: 4096),
            safetySettings: [
              SafetySetting(HarmCategory.harassment, HarmBlockThreshold.high),
              SafetySetting(HarmCategory.hateSpeech, HarmBlockThreshold.high),
            ],
          );
    } else {
      _model = _visionModel ??
          GenerativeModel(
            model: setCurrentModel(newModel: 'gemini-1.5-flash'),
            // apiKey: ApiServices.apiKey,
            apiKey: getApiKey(),
            generationConfig: GenerationConfig(
                temperature: 0.4, topK: 32, topP: 1, maxOutputTokens: 4096),
            safetySettings: [
              SafetySetting(HarmCategory.harassment, HarmBlockThreshold.high),
              SafetySetting(HarmCategory.hateSpeech, HarmBlockThreshold.high),
            ],
          );
    }
  }

  String getApiKey() {
    return dotenv.env['Gemini_API_KEY'].toString();
  }

//set current page index
  void setCurrentIndex({required int newIndex}) {
    _currentIndex = newIndex;
    notifyListeners();
  }

  void setCurrentId({required String newChatId}) {
    _currentChatId = newChatId;
    notifyListeners();
  }

  void setLoading({required bool newLoading}) {
    _isLoading = newLoading;
    notifyListeners();
  }

  Future<void> sendMessage(
      {required String message, required bool isTextOnly}) async {
    await setModel(isTextOnly: isTextOnly);
    setLoading(newLoading: true);
    //get chat id
    String chatId = chatid();

    //list of history
    List<Content> history = [];

    history = await getHistory(chatid: chatId);
    //

    //get the images url\
    List<String> imageUrls = getImageUrl(isTextOnly: isTextOnly);

    //user message id
    // final userMessageId = const Uuid().v4();
    final messageBox =
        await Hive.openBox('${Constants.chatMessagesBox}$chatId');
    final userMessageId = messageBox.keys.length;

    //model messageid
    final assistantMessageId = messageBox.keys.length + 1;
    final userMessage = MessageModel(
        messageId: userMessageId.toString(),
        chatId: chatId,
        role: Role.user,
        message: StringBuffer(message),
        imageUrl: imageUrls,
        timeStamp: DateTime.now());

    //add message
    isChatMessage.add(userMessage);
    notifyListeners();
    if (currentChatId.isEmpty) {
      setCurrentId(newChatId: chatId);
    }
    //send message to model and await for response
    await sendMessageAndWaitForResponse(
        message: message,
        chatId: chatId,
        isTextOnly: isTextOnly,
        history: history,
        userMessage: userMessage,
        modelMessageId: assistantMessageId.toString(),
        messageBox: messageBox);
  }

  //send
  Future<void> sendMessageAndWaitForResponse({
    required String message,
    required String chatId,
    required bool isTextOnly,
    required List<Content> history,
    required MessageModel userMessage,
    required String modelMessageId,
    required Box messageBox,
  }) async {
//start the chat session
    final chatSession = _model!.startChat(
      history: history.isEmpty || !isTextOnly ? null : history,
    );
    final content = await getContent(
      message: message,
      isTextOnly: isTextOnly,
    );
    final assistantMessageId = const Uuid().v4();
    //assistant message
    final assistant = userMessage.copyWith(
        // messageId: assistantMessageId,
        messageId: modelMessageId,
        role: Role.assistant,
        message: StringBuffer(),
        timeStamp: DateTime.now());
    isChatMessage.add(assistant);
    notifyListeners();

    //wait for stream response
    chatSession.sendMessageStream(content).asyncMap((event) {
      return event;
    }).listen((event) {
      isChatMessage
          .firstWhere((element) =>
              element.messageId == assistant.messageId &&
              element.role.name == Role.assistant.name)
          .message
          .write(event.text);
      notifyListeners();
    }, onDone: () async {
      //save message to hive DB
      await saveMessagesToDb(
        chatId: chatId,
        userMessage: userMessage,
        assistantMessage: assistant,
        messageBox: messageBox,
      );
      //set loading to false
      setLoading(newLoading: false);
    }).onError((error) {
      setLoading(newLoading: false);
    });
  }

  //to save messages to hive db
  Future<void> saveMessagesToDb({
    required String chatId,
    required MessageModel userMessage,
    required MessageModel assistantMessage,
    required Box messageBox,
  }) async {
    //open the messages box
    // final messageBox =
    //     await Hive.openBox('${Constants.chatMessagesBox}$chatId');
    // await messageBox.put(userMessage.messageId, userMessage.toMap());
    // await messageBox.put(assistantMessage.messageId, assistantMessage.toMap());
    await messageBox.add(userMessage.toMap());
    await messageBox.add(assistantMessage.toMap());
    //save to chat history
    final chatHistoryBox = Boxes.getChatHistory();
    final chatsHistories = ChatHistory(
        chatId: chatId,
        prompt: userMessage.message.toString(),
        response: assistantMessage.message.toString(),
        imagesUrl: userMessage.imageUrl,
        timeStamp: DateTime.now());
    //error may occur because of the cast
    await chatHistoryBox.put(chatId, chatsHistories);
    messageBox.close();
  }

  Future<Content> getContent(
      {required String message, required bool isTextOnly}) async {
    if (isTextOnly) {
      return Content.text(message);
    } else {
      final imageFutures = _imageFileList
          ?.map((imagefile) => imagefile.readAsBytes())
          .toList(growable: false);
      final imageBytes = await Future.wait(imageFutures!);
      final prompt = TextPart(message);
      final imagePart = imageBytes
          .map((bytes) => DataPart('image/jpeg', Uint8List.fromList(bytes)))
          .toList();
      return Content.multi([prompt, ...imagePart]);
    }
  }
  //get the images url

  List<String> getImageUrl({required bool isTextOnly}) {
    List<String> imageUrl = [];
    if (!isTextOnly && imageFileList != null) {
      for (var image in imageFileList!) {
        imageUrl.add(image.path);
      }
    }
    return imageUrl;
  }

  Future<List<Content>> getHistory({required String chatid}) async {
    List<Content> history = [];
    if (currentChatId.isEmpty) {
      await setInChatMessage(chatId: chatid);
      for (var message in isChatMessage) {
        if (message.role == Role.user) {
          history.add(Content.text(message.message.toString()));
        } else {
          history.add(Content.model([TextPart(message.message.toString())]));
        }
      }
    }
    return history;
  }

  String chatid() {
    if (currentChatId.isEmpty) {
      return Uuid().v4();
    }
    return currentChatId;
  }

  static initHive() async {
    final dir = await path.getApplicationDocumentsDirectory();
    Hive.init(dir.path);
    await Hive.initFlutter(Constants.geminiDb);
    //register adapters
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(ChatHistoryAdapter());
      await Hive.openBox<ChatHistory>(Constants.chatHistory);
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(UserModeAdapter());
      await Hive.openBox<UserMode>(Constants.userBox);
    }
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(SettingsAdapter());
      await Hive.openBox<Settings>(Constants.settingBox);
    }
  }
  // static Future<void> initHive() async {
  //   final dir = await path.getApplicationDocumentsDirectory();
  //   Hive.init(dir.path);
  //   await Hive.initFlutter(Constants.geminiDb);

  //   // Registering adapters
  //   if (!Hive.isAdapterRegistered(0))Hive.registerAdapter(ChatHistoryAdapter());
  //   if (!Hive.isAdapterRegistered(1)) Hive.registerAdapter(UserModeAdapter());
  //   if (!Hive.isAdapterRegistered(2)) Hive.registerAdapter(SettingsAdapter());

  //   // Open boxes after registering adapters
  //   await Hive.openBox<ChatHistory>(Constants.chatHistory);
  //   await Hive.openBox<UserMode>(Constants.userBox);
  //   await Hive.openBox<Settings>(Constants.settingBox);
  // }
}
