// Dart SDK
import 'dart:io';

// Flutter
import 'package:flutter/foundation.dart';

// Third-party
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:dio/dio.dart';

// Project
import 'service.dart';

class MediaSharer {
  static Future<void> shareMedia({
    required List<String> urls,
    String? postId,
    Function(String? postId)? onComplete,
    Function(String? postId, dynamic error)? onError,
  }) async {
    logDebug(message: 'Share Urls $urls');
    try {
      if (urls.isEmpty) {
        throw Exception('No URLs provided for sharing');
      }

      // Create a temporary directory for sharing
      final shareDir = await _getShareDirectory();
      final tempFiles = <File>[];

      try {
        // Download all files first
        for (final url in urls) {
          final file = await _downloadFile(url, shareDir.path);
          tempFiles.add(file);
        }

        // Convert to XFiles and share
        final xFiles = tempFiles.map((file) => XFile(file.path)).toList();

        await SharePlus.instance.share(ShareParams(
          files: xFiles,
        ));

        onComplete?.call(postId);
      } finally {
        // Clean up temporary files
        await _cleanupFiles(tempFiles);
      }
    } catch (e) {
      onError?.call(postId, e);
      rethrow;
    }
  }

  static Future<Directory> _getShareDirectory() async {
    if (Platform.isAndroid) {
      // On Android, use external storage directory
      final dir = await getExternalStorageDirectory();
      final shareDir = Directory('${dir?.path}/share_plus');
      if (!await shareDir.exists()) {
        await shareDir.create(recursive: true);
      }
      return shareDir;
    } else {
      // On iOS, use temporary directory
      final dir = await getTemporaryDirectory();
      final shareDir = Directory('${dir.path}/share_plus');
      if (!await shareDir.exists()) {
        await shareDir.create(recursive: true);
      }
      return shareDir;
    }
  }

  static Future<File> _downloadFile(String url, String savePath) async {
    try {
      final fileName = _generateFileName(url);
      final filePath = '$savePath/$fileName';

      // Download the file
      await Dio().download(url, filePath);

      // Verify the file exists
      final file = File(filePath);
      if (!await file.exists()) {
        throw Exception('Downloaded file not found at $filePath');
      }

      return file;
    } catch (e) {
      throw Exception('Failed to download file: $e');
    }
  }

  static String _generateFileName(String url) {
    final uri = Uri.parse(url);
    final pathSegments = uri.pathSegments.where((s) => s.isNotEmpty).toList();

    if (pathSegments.isEmpty) {
      return 'file_${DateTime.now().millisecondsSinceEpoch}';
    }

    String fileName = pathSegments.last;

    if (!fileName.contains('.')) {
      final ext = _guessFileExtension(url) ?? 'dat';
      fileName = '$fileName.$ext';
    }

    return fileName;
  }

  static String? _guessFileExtension(String url) {
    final uri = Uri.parse(url);
    final path = uri.path.toLowerCase();

    if (path.endsWith('.jpg') || path.endsWith('.jpeg')) return 'jpg';
    if (path.endsWith('.png')) return 'png';
    if (path.endsWith('.gif')) return 'gif';
    if (path.endsWith('.mp4')) return 'mp4';
    if (path.endsWith('.mov')) return 'mov';
    if (path.endsWith('.avi')) return 'avi';

    return null;
  }

  static Future<void> _cleanupFiles(List<File> files) async {
    for (final file in files) {
      try {
        if (await file.exists()) {
          await file.delete();
        }
      } catch (e) {
        debugPrint('Failed to delete file ${file.path}: $e');
      }
    }
  }
}
