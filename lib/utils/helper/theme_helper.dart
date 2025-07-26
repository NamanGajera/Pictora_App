import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ThemeHelper {
  static void showToastMessage(String message) {
    String cleanedMessage = message
        .replaceAll("Exception:", "")
        .trimLeft()
        .replaceFirst(RegExp(r"^:\s*"), "");
    Fluttertoast.showToast(
      msg: cleanedMessage,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      textColor: Colors.white,
    );
  }
}
