import 'package:flutter/material.dart';

class CurrentScreenProvider extends ChangeNotifier {
  int index = 0;

  changeIndex(int i) {
    index = i;
    notifyListeners();
  }
}
