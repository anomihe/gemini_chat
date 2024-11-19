import 'package:hive/hive.dart';
part 'user_mode.g.dart';

@HiveType(typeId: 1)
class UserMode extends HiveObject {
  @HiveField(0)
  final String uid;
  @HiveField(1)
  final String name;
  @HiveField(2)
  final String response;

  UserMode({
    required this.uid,
    required this.name,
    required this.response,
  });
}
