// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_mode.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserModeAdapter extends TypeAdapter<UserMode> {
  @override
  final int typeId = 1;

  @override
  UserMode read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserMode(
      uid: fields[0] as String,
      name: fields[1] as String,
      response: fields[2] as String,
    );
  }

  @override
  void write(BinaryWriter writer, UserMode obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.uid)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.response);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserModeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
