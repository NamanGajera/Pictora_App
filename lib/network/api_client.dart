import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../utils/constants/api_end_points.dart';
import '../utils/helper/helper_function.dart';
import '../utils/services/custom_logger.dart';
import 'custom_exception.dart';

class ApiClient {
  http.Client httpClient = http.Client();

  Future<dynamic> getApiCall({required String endPoint, String? isAccessToken}) async {
    dynamic getResponseJson;
    String getUrl;

    Map<String, String>? headers;

    getUrl = "$baseUrl$endPoint";

    if (isAccessToken != null) {
      headers = {
        "Content-Type": "application/json",
        "Authorization": isAccessToken,
      };
    } else {
      headers = {"Content-Type": "application/json"};
    }
    logDebug(message: 'URL: $getUrl, headers: $headers', tag: "GET API CALL");
    try {
      var response = await httpClient.get(Uri.parse(getUrl), headers: headers);
      getResponseJson = await parseApiResponse(response);
    } on SocketException {
      throw FetchDataException("No internet connection");
    } on FormatException {
      throw FetchDataException("Invalid format");
    }

    return getResponseJson;
  }

  Future<dynamic> postApiCall({
    required String endPoint,
    dynamic postBody,
    String? isAccessToken,
  }) async {
    Map<String, dynamic>? postResponseJson;
    String postUrl;

    Map<String, String>? headers;

    postUrl = '$baseUrl$endPoint';

    var encodedBody = json.encode(postBody);

    if (isAccessToken != null) {
      headers = {
        "Content-Type": "application/json",
        "Authorization": isAccessToken,
      };
    } else {
      headers = {"Content-Type": "application/json"};
    }

    logDebug(message: 'URL: $postUrl, headers: $headers, body: $encodedBody', tag: "POST API CALL");
    try {
      var response = await httpClient.post(Uri.parse(postUrl), headers: headers, body: encodedBody);
      postResponseJson = await parseApiResponse(response);
    } on SocketException {
      throw FetchDataException("No internet connection");
    } on FormatException {
      throw FetchDataException("Invalid format");
    }

    return postResponseJson;
  }

  Future<dynamic> patchApiCall({
    required String endPoint,
    dynamic patchBody,
    String? isAccessToken,
  }) async {
    Map<String, dynamic>? postResponseJson;
    String patchUrl;

    Map<String, String>? headers;

    patchUrl = '$baseUrl$endPoint';

    var encodedBody = json.encode(patchBody);

    if (isAccessToken != null) {
      headers = {
        "Content-Type": "application/json",
        "Authorization": isAccessToken,
      };
    } else {
      headers = {"Content-Type": "application/json"};
    }

    logDebug(message: 'URL: $patchUrl, headers: $headers, body: $encodedBody', tag: "PATCH API CALL");
    try {
      var response = await httpClient.patch(Uri.parse(patchUrl), headers: headers, body: encodedBody);
      postResponseJson = await parseApiResponse(response);
    } on SocketException {
      throw FetchDataException("No internet connection");
    } on FormatException {
      throw FetchDataException("Invalid format");
    }

    return postResponseJson;
  }

  Future<dynamic> putAPICallsWithBody({
    required String endPoint,
    dynamic putBody,
    String? isAccessToken,
  }) async {
    dynamic putResponseJson;
    String putUrl;

    Map<String, String>? headers;

    putUrl = "$baseUrl$endPoint";

    var encodedBody = json.encode(putBody);

    if (isAccessToken != null) {
      headers = {
        "Content-Type": "application/json",
        "Authorization": isAccessToken,
      };
    } else {
      headers = {"Content-Type": "application/json"};
    }
    logDebug(message: 'URL: $putUrl, headers: $headers', tag: "PUT API CALL");
    try {
      var response = await httpClient.put(Uri.parse(putUrl), headers: headers, body: encodedBody);
      putResponseJson = await parseApiResponse(response);
    } on SocketException {
      throw FetchDataException("No internet connections.");
    }

    return putResponseJson;
  }

  Future<dynamic> deleteAPICalls({required String baseUrl, required String endPoint, String? isAccessToken}) async {
    dynamic postResponseJson;
    String deleteUrl;

    Map<String, String>? headers;

    deleteUrl = "$baseUrl$endPoint";

    if (isAccessToken != null) {
      headers = {
        "Content-Type": "application/json",
        "Authorization": isAccessToken,
      };
    } else {
      headers = {"Content-Type": "application/json"};
    }
    logDebug(message: 'URL: $deleteUrl, headers: $headers', tag: "DELETE API CALL");

    try {
      var response = await httpClient.delete(Uri.parse(deleteUrl), headers: headers);
      postResponseJson = await parseApiResponse(response);
    } on SocketException {
      throw FetchDataException("No internet connections.");
    } on FormatException {
      throw FetchDataException("Invalid format");
    }

    return postResponseJson;
  }

  Future<dynamic> multipartPostApiCall({
    required String baseUrl,
    required String endPoint,
    String? authorizationToken,
    Map<String, String>? additionalHeaders,
    required Map<String, dynamic> fields,
    required Map<String, dynamic> fileFields,
  }) async {
    final url = Uri.parse('$baseUrl$endPoint');
    final request = http.MultipartRequest('POST', url);

    // Set headers
    final headers = <String, String>{
      if (authorizationToken != null) 'Authorization': authorizationToken,
      ...?additionalHeaders,
    };
    request.headers.addAll(headers);

    // Add regular form fields
    for (final entry in fields.entries) {
      request.fields[entry.key] = entry.value.toString();
    }

    // Process file fields
    try {
      await _addFileFields(request, fileFields);
    } catch (e) {
      throw Exception('Error processing files: $e');
    }

    _logRequestDetails(url, headers, fields, fileFields);

    try {
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      return parseApiResponse(response); // Your existing response handler
    } on SocketException {
      throw FetchDataException('No internet connection');
    } on FormatException {
      throw FetchDataException('Invalid format');
    } catch (e) {
      log('Error: $e');
      throw Exception('Error during multipart POST request: $e');
    }
  }

  Future<dynamic> multipartPutApiCall(
    String baseUrl,
    String endPoint, {
    String? authorizationToken,
    Map<String, String>? additionalHeaders,
    required Map<String, dynamic> fields,
    required Map<String, dynamic> fileFields,
  }) async {
    final url = Uri.parse('$baseUrl$endPoint');
    final request = http.MultipartRequest('PUT', url);

    // Set headers
    final headers = <String, String>{
      if (authorizationToken != null) 'Authorization': authorizationToken,
      ...?additionalHeaders,
    };
    request.headers.addAll(headers);

    // Add regular form fields
    for (final entry in fields.entries) {
      request.fields[entry.key] = entry.value.toString();
    }

    // Process file fields
    try {
      await _addFileFields(request, fileFields);
    } catch (e) {
      throw Exception('Error processing files: $e');
    }

    _logRequestDetails(url, headers, fields, fileFields);

    try {
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      return parseApiResponse(response); // Your existing response handler
    } on SocketException {
      throw FetchDataException('No internet connection');
    } on FormatException {
      throw FetchDataException('Invalid format');
    } catch (e) {
      log('Error: $e');
      throw Exception('Error during multipart POST request: $e');
    }
  }

  Future<void> _addFileFields(
    http.MultipartRequest request,
    Map<String, dynamic> fileFields,
  ) async {
    for (final entry in fileFields.entries) {
      final fieldName = entry.key;
      final fieldValue = entry.value;

      if (fieldValue is List<File>) {
        for (final file in fieldValue) {
          await _addFileToRequest(request, fieldName, file);
        }
      } else if (fieldValue is File) {
        await _addFileToRequest(request, fieldName, fieldValue);
      } else {
        throw ArgumentError('File field "$fieldName" must be either File or List<File>');
      }
    }
  }

  Future<void> _addFileToRequest(
    http.MultipartRequest request,
    String fieldName,
    File file,
  ) async {
    final fileExtension = file.path.split('.').last.toLowerCase();
    final contentType = _determineContentType(fileExtension);

    if (contentType == null) {
      throw ArgumentError('Unsupported file type: $fileExtension');
    }

    request.files.add(await http.MultipartFile.fromPath(
      fieldName,
      file.path,
      contentType: contentType,
    ));
  }

  MediaType? _determineContentType(String fileExtension) {
    const imageTypes = ['jpg', 'jpeg', 'png', 'gif', 'bmp'];
    const videoTypes = ['mp4', 'mov', 'avi', 'mkv', 'flv'];
    const audioTypes = ['aac', 'mp3', 'wav', 'ogg', 'm4a'];

    if (imageTypes.contains(fileExtension)) {
      return MediaType('image', fileExtension);
    } else if (videoTypes.contains(fileExtension)) {
      return MediaType('video', fileExtension);
    } else if (audioTypes.contains(fileExtension)) {
      return MediaType('audio', fileExtension == 'aac' ? 'aac' : fileExtension);
    }
    return null;
  }

  void _logRequestDetails(
    Uri url,
    Map<String, String> headers,
    Map<String, dynamic> fields,
    Map<String, dynamic> fileFields,
  ) {
    log('Multipart POST URL: $url');
    log('Headers: $headers');
    log('Fields: $fields');
    log('File Fields: ${fileFields.keys.toList()}');
    log('File Counts: ${fileFields.map((k, v) => MapEntry(k, v is List ? v.length : 1))}');
  }

  Future<dynamic> parseApiResponse(http.Response response) async {
    dynamic responseJson;
    String? message;
    try {
      responseJson = response.body.isNotEmpty ? json.decode(response.body) : null;
      if (responseJson is Map<String, dynamic>) {
        message = (responseJson["message"] ?? responseJson["data"] ?? 'Something went Wrong').toString();
      } else {
        message = 'Something went Wrong';
      }
    } on FormatException {
      throw FetchDataException("Unable to process the server response. (Invalid format or unexpected content)");
    } catch (e) {
      throw FetchDataException(e.toString());
    }

    switch (response.statusCode) {
      case 200:
        logInfo(message: responseJson.toString(), tag: "API RESPONSE [200]");

        return responseJson ?? {};

      case 400:
        logError(message: responseJson.toString(), tag: "API ERROR [400]");
        throw ServerValidationError(message);

      case 401:
        logError(message: responseJson.toString(), tag: "API ERROR [401]");
        logoutUser();
        throw UnAuthorizedException(message);

      case 404:
        logError(message: responseJson.toString(), tag: "API ERROR [404]");
        throw DoesNotExistException(message);

      case 422:
        logError(message: responseJson.toString(), tag: "API ERROR [422]");
        throw ServerValidationError(message);

      case 500:
        logError(message: responseJson.toString(), tag: "API ERROR [500]");
        throw FetchDataException(message);

      case 503:
        logError(message: responseJson.toString(), tag: "API ERROR [503]");
        throw UnderMaintenanceError(message);

      default:
        logError(message: responseJson.toString(), tag: "API ERROR [${response.statusCode.toString()}]");
        throw FetchDataException(
          message,
        );
    }
  }
}
