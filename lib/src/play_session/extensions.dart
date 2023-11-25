// extensions.dart
import 'package:flutter/cupertino.dart';

extension StateExtensions on State {
  void safeSetState(VoidCallback callback) {
    if (mounted) {
      setState(callback);
    }
  }
}
