// Dart SDK
import 'dart:io';

// Third-party
import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';

class DeviceInfoService {
  static final DeviceInfoService _instance = DeviceInfoService._internal();
  final DeviceInfoPlugin _deviceInfoPlugin = DeviceInfoPlugin();

  // Cached values
  AndroidDeviceInfo? _androidInfo;
  IosDeviceInfo? _iosInfo;
  PackageInfo? _packageInfo;

  // Factory constructor
  factory DeviceInfoService() {
    return _instance;
  }

  // Private constructor
  DeviceInfoService._internal();

  // Initialize device info - call this in your app initialization
  Future<void> init() async {
    if (Platform.isAndroid) {
      _androidInfo = await _deviceInfoPlugin.androidInfo;
    } else if (Platform.isIOS) {
      _iosInfo = await _deviceInfoPlugin.iosInfo;
    }

    _packageInfo = await PackageInfo.fromPlatform();
  }

  // Get device ID
  String getDeviceId() {
    if (Platform.isAndroid) {
      return _androidInfo?.id ?? '';
    } else if (Platform.isIOS) {
      return _iosInfo?.identifierForVendor ?? '';
    }
    return '';
  }

  // Get device model
  String getDeviceModel() {
    if (Platform.isAndroid) {
      return '${_androidInfo?.manufacturer ?? ''} ${_androidInfo?.model ?? ''}';
    } else if (Platform.isIOS) {
      return _iosInfo?.model ?? '';
    }
    return '';
  }

  // Get OS version
  String getOsVersion() {
    if (Platform.isAndroid) {
      return _androidInfo?.version.release ?? '';
    } else if (Platform.isIOS) {
      return _iosInfo?.systemVersion ?? '';
    }
    return '';
  }

  // Get platform (Android/iOS)
  String getPlatform() {
    if (Platform.isAndroid) {
      return 'Android';
    } else if (Platform.isIOS) {
      return 'iOS';
    }
    return '';
  }

  // Get app version
  String getAppVersion() {
    return '${_packageInfo?.version ?? ''}+${_packageInfo?.buildNumber ?? ''}';
  }

  // Get app bundle ID
  String getAppBundleId() {
    return _packageInfo?.packageName ?? '';
  }

  // Get complete device info as Map
  Map<String, dynamic> getDeviceInfoMap() {
    return {
      'deviceId': getDeviceId(),
      'deviceModel': getDeviceModel(),
      'osVersion': getOsVersion(),
      'platform': getPlatform(),
      'appVersion': getAppVersion(),
      'appBundleId': getAppBundleId(),
    };
  }

  // Access to raw device info objects if needed
  AndroidDeviceInfo? get androidInfo => _androidInfo;
  IosDeviceInfo? get iosInfo => _iosInfo;
  PackageInfo? get packageInfo => _packageInfo;
}
