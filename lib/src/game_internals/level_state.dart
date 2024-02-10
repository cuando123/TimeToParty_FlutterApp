import 'package:flutter/foundation.dart';

class LevelState extends ChangeNotifier {
  final VoidCallback onWin;

  final int goal;

  LevelState({required this.onWin, this.goal = 100});

  int _progress = 0;

  int get progress => _progress;

  void setProgress(int value) {
    _progress = value;
    notifyListeners();
  }

  void evaluate() {
    if (_progress >= goal) {
      onWin();
    }
  }
}
