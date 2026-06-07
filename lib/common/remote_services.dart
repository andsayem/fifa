import 'package:flutter/material.dart';

class RemoteServices {
  static void successMessage(String msg) {
    debugPrint("SUCCESS: $msg");
  }

  static void errorMessage(String msg) {
    debugPrint("ERROR: $msg");
  }
}
