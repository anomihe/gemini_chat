import 'package:chat_with_ai/constants.dart';
import 'package:chat_with_ai/localStore/chat_history.dart';
import 'package:chat_with_ai/localStore/setting.dart';
import 'package:chat_with_ai/localStore/user_mode.dart';
import 'package:chat_with_ai/screens/chat_history_screen.dart';
import 'package:hive/hive.dart';

class Boxes {
  static Box<ChatHistory> getChatHistory() =>
      Hive.box<ChatHistory>(Constants.chatHistory);

  static Box<UserMode> getUser() => Hive.box<UserMode>(Constants.userBox);

  static Box<Settings> getSetting() => Hive.box<Settings>(Constants.settingBox);
}
