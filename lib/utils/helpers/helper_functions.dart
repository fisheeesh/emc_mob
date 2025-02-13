import 'dart:io';

import 'package:emotion_check_in_app/utils/constants/text_strings.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class EHelperFunctions {
  static void showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  static void showAlert(BuildContext context, String title, String message) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(title),
            content: Text(message),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(ETexts.OK))
            ],
          );
        });
  }

  static void navigateToScreen(BuildContext context, Widget screen) {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (builder) => screen));
  }

  static String ensureEndsWithFullStop(String text) {
    text = text.trim();
    if (text.isEmpty) return text;
    return text.endsWith('.') ? text : "$text.";
  }

  static String getFormattedDate(DateTime date, String format) {
    return DateFormat(format).format(date);
  }

  static bool isIOS() {
    return Platform.isIOS;
  }

  static bool isAndroid() {
    return Platform.isAndroid;
  }
}
