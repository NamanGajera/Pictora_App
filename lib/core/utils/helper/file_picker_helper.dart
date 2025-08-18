import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import 'theme_helper.dart';

class FilePickerHelper {
  static const Map<String, int> _fileSizeLimits = {
    'image': 2 * 1024 * 1024,
    'document': 4 * 1024 * 1024,
    'video': 50 * 1024 * 1024,
  };
  static final ImagePicker _imagePicker = ImagePicker();
  static final FilePicker _filePicker = FilePicker.platform;

  /* ========== Image Picker Methods ========== */

  /// Shows a bottom sheet dialog to choose image source (camera or gallery)
  static Future<File?> showImageSourceDialog(BuildContext context,
      {String? title}) async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Camera'),
                onTap: () => Navigator.pop(context, ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Gallery'),
                onTap: () => Navigator.pop(context, ImageSource.gallery),
              ),
            ],
          ),
        );
      },
    );

    if (source != null) {
      return await pickImage(source: source);
    }
    return null;
  }

  /// Picks a single image from camera or gallery with size validation
  static Future<File?> pickImage({
    required ImageSource source,
    double? maxWidth,
    double? maxHeight,
    int? imageQuality,
    bool requestPermission = true,
  }) async {
    try {
      if (requestPermission) {
        final permission = await _getRequiredPermission(source);
        if (permission != null) {
          final status = await permission.request();
          if (!status.isGranted) return null;
        }
      }

      final XFile? pickedFile = await _imagePicker.pickImage(
        source: source,
        maxWidth: maxWidth,
        maxHeight: maxHeight,
        imageQuality: imageQuality,
      );

      if (pickedFile != null) {
        final file = File(pickedFile.path);
        final size = await file.length();

        if (size > _fileSizeLimits['image']!) {
          ThemeHelper.showToastMessage(
              'Image exceeds maximum size limit (2MB)');
          return null;
        }
        return file;
      }
      return null;
    } catch (e) {
      debugPrint('Image picker error: $e');
      return null;
    }
  }

  /// Picks multiple images from gallery with size validation
  static Future<List<File>?> pickMultiImage({
    double? maxWidth,
    double? maxHeight,
    int? imageQuality,
    bool requestPermission = true,
  }) async {
    try {
      if (requestPermission) {
        final permission = await _getRequiredPermission(ImageSource.gallery);
        if (permission != null) {
          final status = await permission.request();
          if (!status.isGranted) return null;
        }
      }

      final List<XFile> pickedFiles = await _imagePicker.pickMultiImage(
        maxWidth: maxWidth,
        maxHeight: maxHeight,
        imageQuality: imageQuality,
      );

      final validFiles = <File>[];
      for (final xfile in pickedFiles) {
        final file = File(xfile.path);
        final size = await file.length();

        if (size <= _fileSizeLimits['image']!) {
          validFiles.add(file);
        } else {
          ThemeHelper.showToastMessage('Image exceeds 2MB limit');
        }
      }

      return validFiles.isNotEmpty ? validFiles : null;
    } catch (e) {
      debugPrint('Multi image picker error: $e');
      return null;
    }
  }

  /* ========== File Picker Methods ========== */

  /// Picks a single file with size validation
  static Future<File?> pickFile({
    List<String>? allowedExtensions,
    bool requestPermission = true,
    String? dialogTitle,
    FileType fileType = FileType.custom,
  }) async {
    try {
      if (requestPermission) {
        final permission = await _getRequiredFilePermission();
        if (permission != null) {
          final status = await permission.request();
          if (!status.isGranted) return null;
        }
      }

      final FilePickerResult? result = await _filePicker.pickFiles(
        type: fileType,
        allowedExtensions: allowedExtensions,
        dialogTitle: dialogTitle,
      );

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        final size = await file.length();
        final category = _getFileCategory(result.files.single);

        if (size <= _fileSizeLimits[category]!) {
          return file;
        } else {
          String getFileSizeLimitMessage(String category) {
            final limitInBytes =
                _fileSizeLimits[category] ?? _fileSizeLimits['other']!;
            final limitInMB = limitInBytes ~/ (1024 * 1024);

            return "Max allowed size for $category is ${limitInMB}MB. Please select a smaller file.";
          }

          ThemeHelper.showToastMessage(getFileSizeLimitMessage(category));
          return null;
        }
      }
      return null;
    } catch (e) {
      debugPrint('File picker error: $e');
      return null;
    }
  }

  /// Picks multiple files with size validation
  static Future<List<File>?> pickMultiFile({
    List<String>? allowedExtensions,
    bool requestPermission = true,
    String? dialogTitle,
    FileType fileType = FileType.custom,
  }) async {
    try {
      if (requestPermission) {
        final permission = await _getRequiredFilePermission();
        if (permission != null) {
          final status = await permission.request();
          if (!status.isGranted) return null;
        }
      }

      final FilePickerResult? result = await _filePicker.pickFiles(
        type: fileType,
        allowedExtensions: allowedExtensions,
        allowMultiple: true,
        dialogTitle: dialogTitle,
      );

      if (result != null) {
        final validFiles = <File>[];

        for (final platformFile in result.files) {
          if (platformFile.path != null) {
            final file = File(platformFile.path!);
            final size = await file.length();
            final category = _getFileCategory(platformFile);

            if (size <= _fileSizeLimits[category]!) {
              validFiles.add(file);
            } else {
              String getFileTypeName(String category) {
                switch (category) {
                  case 'image':
                    return 'Image';
                  case 'video':
                    return 'Video';
                  case 'document':
                    return 'Document';
                  case 'audio':
                    return 'Audio';
                  default:
                    return 'File';
                }
              }

              ThemeHelper.showToastMessage(
                  '${getFileTypeName(category)} too large (max ${_fileSizeLimits[category]! ~/ (1024 * 1024)}MB)');
            }
          }
        }

        return validFiles.isNotEmpty ? validFiles : null;
      }
      return null;
    } catch (e) {
      debugPrint('Multi file picker error: $e');
      return null;
    }
  }

  /* ========== Specific File Type Methods ========== */

  /// Picks a single image file with size validation
  static Future<File?> pickSingleImageFile({
    bool requestPermission = true,
    String? dialogTitle,
  }) async {
    return pickFile(
      allowedExtensions: ['jpg', 'jpeg', 'png', 'gif', 'webp'],
      requestPermission: requestPermission,
      dialogTitle: dialogTitle,
      fileType: FileType.image,
    );
  }

  /// Picks multiple image files with size validation
  static Future<List<File>?> pickMultiImageFile({
    bool requestPermission = true,
    String? dialogTitle,
  }) async {
    return pickMultiFile(
      allowedExtensions: ['jpg', 'jpeg', 'png', 'gif', 'webp'],
      requestPermission: requestPermission,
      dialogTitle: dialogTitle,
      fileType: FileType.image,
    );
  }

  /// Picks a single video file with size validation
  static Future<File?> pickSingleVideoFile({
    bool requestPermission = true,
    String? dialogTitle,
  }) async {
    return pickFile(
      allowedExtensions: ['mp4', 'mov', 'avi', 'mkv', 'flv'],
      requestPermission: requestPermission,
      dialogTitle: dialogTitle,
      fileType: FileType.video,
    );
  }

  /// Picks multiple video files with size validation
  static Future<List<File>?> pickMultiVideoFile({
    bool requestPermission = true,
    String? dialogTitle,
  }) async {
    return pickMultiFile(
      allowedExtensions: ['mp4', 'mov', 'avi', 'mkv', 'flv'],
      requestPermission: requestPermission,
      dialogTitle: dialogTitle,
      fileType: FileType.video,
    );
  }

  /// Picks a single PDF file with size validation
  static Future<File?> pickSinglePdfFile({
    bool requestPermission = true,
    String? dialogTitle,
  }) async {
    return pickFile(
      allowedExtensions: ['pdf'],
      requestPermission: requestPermission,
      dialogTitle: dialogTitle,
      fileType: FileType.custom,
    );
  }

  /// Picks multiple PDF files with size validation
  static Future<List<File>?> pickMultiPdfFile({
    bool requestPermission = true,
    String? dialogTitle,
  }) async {
    return pickMultiFile(
      allowedExtensions: ['pdf'],
      requestPermission: requestPermission,
      dialogTitle: dialogTitle,
      fileType: FileType.custom,
    );
  }

  /* ========== Helper Methods ========== */

  /// Determines file category based on extension
  static String _getFileCategory(PlatformFile file) {
    final extension = file.extension?.toLowerCase() ?? '';

    if (['jpg', 'jpeg', 'png', 'gif', 'webp', 'bmp'].contains(extension)) {
      return 'image';
    } else if (['mp4', 'mov', 'avi', 'mkv', 'flv', 'wmv'].contains(extension)) {
      return 'video';
    } else {
      return 'document';
    }
  }

  /// Improved permission handling for Android and iOS
  static Future<Permission?> _getRequiredFilePermission() async {
    if (Platform.isAndroid) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;

      // Android 13+ (API 33+) - no permission needed for file picker
      if (androidInfo.version.sdkInt >= 33) {
        return null;
      }
      // Android 10-12 (API 29-32) - might not need permission
      else if (androidInfo.version.sdkInt >= 29) {
        // Some manufacturers still require it
        return Permission.storage;
      }
      // Android 9 and below (API < 29) - needs storage permission
      else {
        return Permission.storage;
      }
    }
    // iOS - no permission needed for file picker
    return null;
  }

  /// Permission handling for image picking
  static Future<Permission?> _getRequiredPermission(ImageSource source) async {
    if (source == ImageSource.camera) {
      return Permission.camera;
    } else {
      if (Platform.isAndroid) {
        final androidInfo = await DeviceInfoPlugin().androidInfo;
        if (androidInfo.version.sdkInt >= 33) {
          return Permission.photos;
        } else if (androidInfo.version.sdkInt >= 29) {
          return null;
        } else {
          return Permission.storage;
        }
      } else if (Platform.isIOS) {
        return Permission.photos;
      }
    }
    return null;
  }
}
