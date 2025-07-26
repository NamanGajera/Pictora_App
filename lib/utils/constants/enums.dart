enum PostCommentApiStatus {
  posting,
  success,
  failure,
  deleting,
  failedToDelete,
}

enum ApiStatus {
  initial,
  loading,
  success,
  failure,
}

enum RelationType {
  father(1, 'Father'),
  mother(2, 'Mother'),
  husband(3, 'Husband'),
  wife(4, 'Wife'),
  child(5, 'Child');

  final int id;
  final String name;

  const RelationType(this.id, this.name);

  static RelationType fromId(int id) {
    return RelationType.values.firstWhere(
      (e) => e.id == id,
      orElse: () => throw ArgumentError('Invalid Relation id: $id'),
    );
  }
}

enum GenderType {
  male(0, 'Male'),
  female(1, 'Female'),
  other(2, 'Other');

  final int id;
  final String name;

  const GenderType(this.id, this.name);

  static GenderType fromId(int id) {
    return GenderType.values.firstWhere(
      (e) => e.id == id,
      orElse: () => throw ArgumentError('Invalid Gender id: $id'),
    );
  }
}

enum AppEnv {
  local,
}

enum MaritalStatus {
  single(0, 'Single'),
  married(1, 'Married'),
  widowed(2, 'Widowed'),
  divorced(2, 'Divorced');

  final int id;
  final String name;

  const MaritalStatus(this.id, this.name);

  static MaritalStatus fromId(int id) {
    return MaritalStatus.values.firstWhere(
      (e) => e.id == id,
      orElse: () => throw ArgumentError('Invalid Gender id: $id'),
    );
  }
}

enum LogLevel {
  verbose,
  debug,
  info,
  warning,
  error,
  wtf,
}