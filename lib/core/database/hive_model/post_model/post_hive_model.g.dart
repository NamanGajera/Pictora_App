part of 'post_hive_model.dart';

class PostHiveModelAdapter extends TypeAdapter<PostHiveModel> {
  @override
  final int typeId = 0;

  @override
  PostHiveModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PostHiveModel()
      ..id = fields[0] as String?
      ..userId = fields[1] as String?
      ..caption = fields[2] as String?
      ..likeCount = fields[3] as int?
      ..commentCount = fields[4] as int?
      ..shareCount = fields[5] as int?
      ..saveCount = fields[6] as int?
      ..viewCount = fields[7] as int?
      ..createdAt = fields[8] as String?
      ..updatedAt = fields[9] as String?
      ..isLiked = fields[10] as bool?
      ..isSaved = fields[11] as bool?
      ..mediaData = (fields[12] as List?)?.cast<MediaHiveModel>()
      ..userData = fields[13] as UserHiveModel?;
  }

  @override
  void write(BinaryWriter writer, PostHiveModel obj) {
    writer
      ..writeByte(14)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.userId)
      ..writeByte(2)
      ..write(obj.caption)
      ..writeByte(3)
      ..write(obj.likeCount)
      ..writeByte(4)
      ..write(obj.commentCount)
      ..writeByte(5)
      ..write(obj.shareCount)
      ..writeByte(6)
      ..write(obj.saveCount)
      ..writeByte(7)
      ..write(obj.viewCount)
      ..writeByte(8)
      ..write(obj.createdAt)
      ..writeByte(9)
      ..write(obj.updatedAt)
      ..writeByte(10)
      ..write(obj.isLiked)
      ..writeByte(11)
      ..write(obj.isSaved)
      ..writeByte(12)
      ..write(obj.mediaData)
      ..writeByte(13)
      ..write(obj.userData);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is PostHiveModelAdapter && runtimeType == other.runtimeType && typeId == other.typeId;
}

class MediaHiveModelAdapter extends TypeAdapter<MediaHiveModel> {
  @override
  final int typeId = 1;

  @override
  MediaHiveModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MediaHiveModel()
      ..id = fields[0] as String?
      ..postId = fields[1] as String?
      ..mediaUrl = fields[2] as String?
      ..mediaType = fields[3] as String?
      ..createdAt = fields[4] as String?
      ..updatedAt = fields[5] as String?;
  }

  @override
  void write(BinaryWriter writer, MediaHiveModel obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.postId)
      ..writeByte(2)
      ..write(obj.mediaUrl)
      ..writeByte(3)
      ..write(obj.mediaType)
      ..writeByte(4)
      ..write(obj.createdAt)
      ..writeByte(5)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is MediaHiveModelAdapter && runtimeType == other.runtimeType && typeId == other.typeId;
}
