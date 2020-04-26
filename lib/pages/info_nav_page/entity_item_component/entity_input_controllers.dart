import 'package:flutter/material.dart';

class EntityInputControllers {
  static final titleController = TextEditingController();
  static final overviewController = TextEditingController();
  static final overviewFocusNode = FocusNode();
  static final contentController = TextEditingController();
  static final contentFocusNode = FocusNode();
  static final tagController = TextEditingController();
  static final tagFocusNode = FocusNode();

  static void clearAll() {
    titleController.clear();
    overviewController.clear();
    contentController.clear();
    tagController.clear();
  }
}
