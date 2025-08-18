class CustomException implements Exception {
  final dynamic _message;
  final dynamic _prefix;

  CustomException(this._message, this._prefix);

  @override
  String toString() {
    return "$_prefix:$_message";
  }
}

class FetchDataException extends CustomException {
  FetchDataException([String? message]) : super(message, "");
}

class UnAuthorizedException extends CustomException {
  UnAuthorizedException([String? message]) : super(message, "");
}

class DoesNotExistException extends CustomException {
  DoesNotExistException([String? message]) : super(message, "");
}

class ServerValidationError extends CustomException {
  ServerValidationError([String? message]) : super(message, "");
}

class UnderMaintenanceError extends CustomException {
  UnderMaintenanceError([String? message]) : super(message, "");
}

class HiveStorageException implements Exception {
  final String message;
  HiveStorageException(this.message);

  @override
  String toString() => 'HiveStorageException: $message';
}
