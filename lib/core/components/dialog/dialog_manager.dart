import 'package:flutter/material.dart';

class DialogManager {
  static final _instance = DialogManager._init();
  static DialogManager get instance => _instance;
  DialogManager._init();

  static void showSnackbar(context, String content, Color? color) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(content),
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
    ));
  }

  static void showErrorSnackbar(context, String content) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(content),
      backgroundColor: Colors.orange,
      behavior: SnackBarBehavior.floating,
    ));
  }
}
