import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../utils/Constants/api_end_points.dart';
import '../utils/helper/helper_function.dart';
import '../utils/services/custom_logger.dart';
import 'custom_exception.dart';

class ApiClient {
  http.Client httpClient = http.Client();

  Future<dynamic> getApiCall(
      {required String endPoint, String? isAccessToken}) async {
    dynamic getResponseJson;
    String getUrl;

    Map<String, String>? headers;

    getUrl = "$baseUrl$endPoint";

    if (isAccessToken != null) {
      headers = {
        "Content-Type": "application/json",
        "Authorization": 'Bearer $isAccessToken',
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
        "Authorization": 'Bearer $isAccessToken',
      };
    } else {
      headers = {"Content-Type": "application/json"};
    }

    logDebug(
        message: 'URL: $postUrl, headers: $headers, body: $encodedBody',
        tag: "POST API CALL");
    try {
      var response = await httpClient.post(Uri.parse(postUrl),
          headers: headers, body: encodedBody);
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
        "Authorization": 'Bearer $isAccessToken',
      };
    } else {
      headers = {"Content-Type": "application/json"};
    }
    logDebug(message: 'URL: $putUrl, headers: $headers', tag: "PUT API CALL");
    try {
      var response = await httpClient.put(Uri.parse(putUrl),
          headers: headers, body: encodedBody);
      putResponseJson = await parseApiResponse(response);
    } on SocketException {
      throw FetchDataException("No internet connections.");
    }

    return putResponseJson;
  }

  Future<dynamic> deleteAPICalls(
      {required String baseUrl,
      required String endPoint,
      String? isAccessToken}) async {
    dynamic postResponseJson;
    String deleteUrl;

    Map<String, String>? headers;

    deleteUrl = "$baseUrl$endPoint";

    if (isAccessToken != null) {
      headers = {
        "Content-Type": "application/json",
        "Authorization": 'Bearer $isAccessToken',
      };
    } else {
      headers = {"Content-Type": "application/json"};
    }
    logDebug(
        message: 'URL: $deleteUrl, headers: $headers', tag: "DELETE API CALL");

    try {
      var response =
          await httpClient.delete(Uri.parse(deleteUrl), headers: headers);
      postResponseJson = await parseApiResponse(response);
    } on SocketException {
      throw FetchDataException("No internet connections.");
    } on FormatException {
      throw FetchDataException("Invalid format");
    }

    return postResponseJson;
  }

  Future<dynamic> multipartPostApiCall(
    String baseUrl,
    String endPoint, {
    String? isAccessToken,
    String? isFireBaseToken,
    required List<String> fileKey,
    required Map<String, dynamic> fields,
  }) async {
    var getUrl = '$baseUrl$endPoint';
    var request = http.MultipartRequest('POST', Uri.parse(getUrl));

    Map<String, String>? headers;

    if (isAccessToken != null) {
      headers = {
        "Authorization": 'Bearer $isAccessToken',
      };
    } else {
      headers = {};
    }

    request.headers.addAll(headers);

    // Add form fields if provided

    for (var key in fields.keys) {
      var value = fields[key];
      if ((fileKey).contains(key) && value is List<File>) {
        List<File> attachments = value;
        for (var entry in attachments) {
          String fileExtension = entry.path.split('.').last.toLowerCase();
          MediaType contentType;

          if (['jpg', 'jpeg', 'png', 'gif', 'bmp'].contains(fileExtension)) {
            contentType = MediaType('image', fileExtension);
          } else if (['mp4', 'mov', 'avi', 'mkv', 'flv']
              .contains(fileExtension)) {
            contentType = MediaType('video', fileExtension);
          } else if (['aac', 'mp3', 'wav', 'ogg', 'm4a']
              .contains(fileExtension)) {
            contentType = MediaType(
                'audio', fileExtension == 'aac' ? 'aac' : fileExtension);
          } else {
            continue; // Skip unsupported files
          }

          request.files.add(await http.MultipartFile.fromPath(key, entry.path,
              contentType: contentType));
        }
      } else if ((fileKey).contains(key) && value is File) {
        String fileExtension = value.path.split('.').last.toLowerCase();
        MediaType contentType;

        if (['jpg', 'jpeg', 'png', 'gif', 'bmp'].contains(fileExtension)) {
          contentType = MediaType('image', fileExtension);
        } else if (['mp4', 'mov', 'avi', 'mkv', 'flv']
            .contains(fileExtension)) {
          contentType = MediaType('video', fileExtension);
        } else if (['aac', 'mp3', 'wav', 'ogg', 'm4a']
            .contains(fileExtension)) {
          contentType = MediaType(
              'audio', fileExtension == 'aac' ? 'aac' : fileExtension);
        } else {
          continue;
        }
        request.files.add(await http.MultipartFile.fromPath(key, value.path,
            contentType: contentType));
      } else {
        request.fields[key] = value.toString();
      }
    }

    log("Multipart POST URL: $getUrl");
    log("Headers: $headers");
    log("Fields: $fields");
    log("Request: $request");

    try {
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      return parseApiResponse(response); // Use your existing response handler
    } on SocketException {
      throw FetchDataException("No internet connection");
    } on FormatException {
      throw FetchDataException("Invalid format");
    } catch (e) {
      log("Error: $e");
      throw Exception("Error during multipart POST request");
    }
  }

  Future<dynamic> multipartPutApiCall(
    String baseUrl,
    String endPoint, {
    String? isAccessToken,
    String? isFireBaseToken,
    required List<String> fileKey,
    Map<String, dynamic>? fields,
    // Map<String, File>? files,
  }) async {
    var getUrl = '$baseUrl$endPoint';
    var request = http.MultipartRequest('PUT', Uri.parse(getUrl));

    Map<String, String>? headers;

    if (isAccessToken != null) {
      headers = {
        // "Content-Type": "application/json",
        "Authorization": 'Bearer $isAccessToken',
      };
    } else if (isFireBaseToken != null) {
      headers = {
        // "Content-Type": "application/json",
        "firebase": isFireBaseToken,
      };
    } else {
      headers = {};
      // headers = {"Content-Type": "application/json"};
    }

    request.headers.addAll(headers);

    // Add form fields if provided
    if (fields != null) {
      fields.forEach((key, value) async {
        if ((fileKey).contains(key) && value is List<File>) {
          // log(value.runtimeType.toString());
          // log(value.toString());

          List<File> attachments = value;

          for (var entry in attachments) {
            // log(entry);

            // String? mimeType = lookupMimeType(entry.path);
            // var contentType = mimeType != null ? MediaType('image', mimeType) : null;

            String fileExtension = entry.path.split('.').last.toLowerCase();
            MediaType contentType;

            // Check for image type
            if (['jpg', 'jpeg', 'png', 'gif', 'bmp'].contains(fileExtension)) {
              contentType = MediaType('image', fileExtension);
            }
            // Check for video type
            else if (['mp4', 'mov', 'avi', 'mkv', 'flv']
                .contains(fileExtension)) {
              contentType = MediaType('video', fileExtension);
            } else if (['aac', 'mp3', 'wav', 'ogg', 'm4a']
                .contains(fileExtension)) {
              contentType = MediaType(
                  'audio', fileExtension == 'aac' ? 'aac' : fileExtension);
            } else {
              continue; // Skip unsupported files
            }

            request.files.add(await http.MultipartFile.fromPath(key, entry.path,
                contentType: contentType));
          }
        } else if ((fileKey).contains(key) && value is File) {
          String fileExtension = value.path.split('.').last.toLowerCase();
          MediaType contentType;

          // Check for image type
          if (['jpg', 'jpeg', 'png', 'gif', 'bmp'].contains(fileExtension)) {
            contentType = MediaType('image', fileExtension);
            request.files.add(await http.MultipartFile.fromPath(key, value.path,
                contentType: contentType));
          }
          // Check for video type
          else if (['mp4', 'mov', 'avi', 'mkv', 'flv']
              .contains(fileExtension)) {
            contentType = MediaType('video', fileExtension);
            request.files.add(await http.MultipartFile.fromPath(key, value.path,
                contentType: contentType));
          } else if (['aac', 'mp3', 'wav', 'ogg', 'm4a']
              .contains(fileExtension)) {
            contentType = MediaType(
                'audio', fileExtension == 'aac' ? 'aac' : fileExtension);
            request.files.add(await http.MultipartFile.fromPath(key, value.path,
                contentType: contentType));
          } else {}
          // contentType = MediaType('audio', fileExtension == 'aac' ? 'aac' : fileExtension);
        } else {
          request.fields[key] = value.toString();
        }
      });
    }

    log("Multipart POST URL: $getUrl");
    log("Headers: $headers");
    log("Fields: $fields");
    log("Request: $request");

    try {
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      return parseApiResponse(response);
    } on SocketException {
      throw FetchDataException("No internet connection");
    }
  }

  Future<dynamic> parseApiResponse(http.Response response) async {
    dynamic responseJson;
    String? message;
    try {
      responseJson =
          response.body.isNotEmpty ? json.decode(response.body) : null;
      if (responseJson is Map<String, dynamic>) {
        message = (responseJson["message"] ??
                responseJson["data"] ??
                'Something went Wrong')
            .toString();
      } else {
        message = 'Something went Wrong';
      }
    } on FormatException {
      throw FetchDataException(
          "Unable to process the server response. (Invalid format or unexpected content)");
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
        logError(
            message: responseJson.toString(),
            tag: "API ERROR [${response.statusCode.toString()}]");
        throw FetchDataException(
          message,
        );
    }
  }
}
