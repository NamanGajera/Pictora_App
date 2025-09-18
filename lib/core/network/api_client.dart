// Dart SDK
import 'dart:io';

// Third-party
import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';

// Project
import '../utils/constants/constants.dart';
import '../utils/services/service.dart';
import '../utils/helper/helper.dart';

class ApiClient {
  final Dio _dio = Dio();

  ApiClient() {
    _dio.options.baseUrl = baseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 30);
    _dio.options.receiveTimeout = const Duration(seconds: 30);
    _dio.options.headers = {'Content-Type': 'application/json'};

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        logDebug(
          message: 'URL: ${options.uri}, headers: ${options.headers}, body: ${options.data}',
          tag: "${options.method} API CALL",
        );
        return handler.next(options);
      },
      onResponse: (response, handler) {
        logInfo(
          message: response.data.toString(),
          tag: "API RESPONSE [${response.statusCode}]",
        );
        return handler.next(response);
      },
      onError: (DioException error, handler) {
        logError(
          message: error.response?.data?.toString() ?? error.message,
          tag: "API ERROR [${error.response?.statusCode}]",
        );
        return handler.next(error);
      },
    ));
  }

  Future<dynamic> getApiCall({required String endPoint, String? isAccessToken}) async {
    try {
      final response = await _dio.get(
        endPoint,
        options: Options(
          headers: _buildHeaders(isAccessToken),
        ),
      );
      return _parseApiResponse(response);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<dynamic> postApiCall({
    required String endPoint,
    dynamic postBody,
    String? isAccessToken,
  }) async {
    try {
      final response = await _dio.post(
        endPoint,
        data: postBody,
        options: Options(
          headers: _buildHeaders(isAccessToken),
        ),
      );
      return _parseApiResponse(response);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<dynamic> patchApiCall({
    required String endPoint,
    dynamic patchBody,
    String? isAccessToken,
  }) async {
    try {
      final response = await _dio.patch(
        endPoint,
        data: patchBody,
        options: Options(
          headers: _buildHeaders(isAccessToken),
        ),
      );
      return _parseApiResponse(response);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<dynamic> putAPICall({
    required String endPoint,
    dynamic putBody,
    String? isAccessToken,
  }) async {
    try {
      final response = await _dio.put(
        endPoint,
        data: putBody,
        options: Options(
          headers: _buildHeaders(isAccessToken),
        ),
      );
      return _parseApiResponse(response);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<dynamic> deleteAPICalls({
    required String endPoint,
    String? isAccessToken,
  }) async {
    try {
      final response = await _dio.delete(
        endPoint,
        options: Options(
          headers: _buildHeaders(isAccessToken),
        ),
      );
      return _parseApiResponse(response);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<dynamic> multipartPostApiCall({
    required String endPoint,
    String? authorizationToken,
    Map<String, String>? additionalHeaders,
    required Map<String, dynamic> fields,
    required Map<String, dynamic> fileFields,
  }) async {
    try {
      final formData = await _buildFormData(fields, fileFields);
      final response = await _dio.post(
        endPoint,
        data: formData,
        options: Options(
          headers: _buildHeaders(authorizationToken, additionalHeaders),
          contentType: 'multipart/form-data',
        ),
      );
      return _parseApiResponse(response);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<dynamic> multipartPutApiCall({
    required String endPoint,
    String? authorizationToken,
    Map<String, String>? additionalHeaders,
    required Map<String, dynamic> fields,
    required Map<String, dynamic> fileFields,
  }) async {
    try {
      final formData = await _buildFormData(fields, fileFields);
      final response = await _dio.put(
        endPoint,
        data: formData,
        options: Options(
          headers: _buildHeaders(authorizationToken, additionalHeaders),
          contentType: 'multipart/form-data',
        ),
      );
      return _parseApiResponse(response);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // Helper methods
  Map<String, String> _buildHeaders(String? authToken, [Map<String, String>? additionalHeaders]) {
    final headers = <String, String>{};
    if (authToken != null) {
      headers['Authorization'] = authToken;
    }
    if (additionalHeaders != null) {
      headers.addAll(additionalHeaders);
    }
    return headers;
  }

  Future<FormData> _buildFormData(
    Map<String, dynamic> fields,
    Map<String, dynamic> fileFields,
  ) async {
    final formData = FormData();

    for (final entry in fields.entries) {
      final fieldName = entry.key;
      final fieldValue = entry.value;

      if (fieldValue is List) {
        for (final item in fieldValue) {
          formData.fields.add(MapEntry(fieldName, item.toString()));
        }
      } else {
        formData.fields.add(MapEntry(fieldName, fieldValue.toString()));
      }
    }

    for (final entry in fileFields.entries) {
      final fieldName = entry.key;
      final fieldValue = entry.value;

      if (fieldValue is List<File>) {
        for (final file in fieldValue) {
          await _addFileToFormData(formData, fieldName, file);
        }
      } else if (fieldValue is File) {
        await _addFileToFormData(formData, fieldName, fieldValue);
      } else {
        throw ArgumentError('File field "$fieldName" must be either File or List<File>');
      }
    }

    return formData;
  }

  Future<void> _addFileToFormData(
    FormData formData,
    String fieldName,
    File file,
  ) async {
    final fileExtension = file.path.split('.').last.toLowerCase();
    final contentType = _determineContentType(fileExtension);

    if (contentType == null) {
      throw ArgumentError('Unsupported file type: $fileExtension');
    }

    formData.files.add(MapEntry(
      fieldName,
      await MultipartFile.fromFile(
        file.path,
        filename: file.path.split('/').last,
        contentType: contentType,
      ),
    ));
  }

  MediaType? _determineContentType(String fileExtension) {
    const imageTypes = ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp', 'heic', 'heif', 'tiff', 'svg'];
    const videoTypes = ['mp4', 'mov', 'avi', 'mkv', 'flv', 'wmv', 'webm', '3gp', 'm4v', 'ts'];
    const audioTypes = ['aac', 'mp3', 'wav', 'ogg', 'm4a', 'flac', 'wma', 'amr', 'aiff', 'opus', 'mid', 'midi'];

    if (imageTypes.contains(fileExtension)) {
      return MediaType('image', fileExtension);
    } else if (videoTypes.contains(fileExtension)) {
      return MediaType('video', fileExtension);
    } else if (audioTypes.contains(fileExtension)) {
      return MediaType('audio', fileExtension == 'aac' ? 'aac' : fileExtension);
    }
    return null;
  }

  dynamic _parseApiResponse(Response response) {
    dynamic responseJson = response.data;
    String? message;

    if (responseJson is Map<String, dynamic>) {
      message = (responseJson["message"] ?? responseJson["data"] ?? 'Something went Wrong').toString();
    } else {
      message = 'Something went Wrong';
    }

    switch (response.statusCode) {
      case 200:
        return responseJson ?? {};
      case 400:
        throw ServerValidationError(message);
      case 401:
        logoutUser();
        throw UnAuthorizedException(message);
      case 404:
        throw DoesNotExistException(message);
      case 422:
        throw ServerValidationError(message);
      case 500:
        throw FetchDataException(message);
      case 503:
        throw UnderMaintenanceError(message);
      default:
        throw FetchDataException(message);
    }
  }

  Exception _handleDioError(DioException error) {
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.sendTimeout ||
        error.type == DioExceptionType.receiveTimeout) {
      return FetchDataException("Couldn't connect.");
    } else if (error.type == DioExceptionType.connectionError) {
      return FetchDataException("No internet connection");
    } else if (error.type == DioExceptionType.badResponse) {
      if (error.response != null) {
        return _parseApiResponse(error.response!);
      }
      return FetchDataException("Invalid server response");
    } else if (error.type == DioExceptionType.cancel) {
      return FetchDataException("Request cancelled");
    } else {
      return FetchDataException("Something went wrong");
    }
  }
}
