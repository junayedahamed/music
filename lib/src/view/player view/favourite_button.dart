import 'package:flutter/material.dart';

class PlayerFunctionalities extends ChangeNotifier {
  bool _fav = false;
  get pressFav => _fav;
  void changefav() {
    _fav = !_fav;
    notifyListeners();
  }
}
