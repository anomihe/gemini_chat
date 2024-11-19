import 'package:hive/hive.dart';
part 'setting.g.dart';

@HiveType(typeId: 2)
class Settings extends HiveObject {
  @HiveField(0)
  bool darkTheme = false;
  @HiveField(1)
  bool shouldSpeak;

  Settings({
    required this.darkTheme,
    required this.shouldSpeak,
  });
}
