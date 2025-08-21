part of 'user_hive_model.dart';

class UserHiveModelAdapter extends TypeAdapter<UserHiveModel> {
  @override
  final int typeId = 2;

  @override
  UserHiveModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserHiveModel()
      ..id = fields[0] as String?
      ..fullName = fields[1] as String?
      ..userName = fields[2] as String?
      ..email = fields[3] as String?
      ..profile = fields[4] as ProfileHiveModel?;
  }

  @override
  void write(BinaryWriter writer, UserHiveModel obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.fullName)
      ..writeByte(2)
      ..write(obj.userName)
      ..writeByte(3)
      ..write(obj.email)
      ..writeByte(4)
      ..write(obj.profile);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is UserHiveModelAdapter && runtimeType == other.runtimeType && typeId == other.typeId;
}

class ProfileHiveModelAdapter extends TypeAdapter<ProfileHiveModel> {
  @override
  final int typeId = 3;

  @override
  ProfileHiveModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ProfileHiveModel()
      ..profilePicture = fields[0] as String?
      ..isPrivate = fields[1] as bool?;
  }

  @override
  void write(BinaryWriter writer, ProfileHiveModel obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.profilePicture)
      ..writeByte(1)
      ..write(obj.isPrivate);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is ProfileHiveModelAdapter && runtimeType == other.runtimeType && typeId == other.typeId;
}
