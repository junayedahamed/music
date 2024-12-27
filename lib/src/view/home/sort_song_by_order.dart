import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';

class SortSongByOrder extends ChangeNotifier {
  var _order = OrderType.ASC_OR_SMALLER;
  get order => _order;
  asc(value) {
    //print(_order);
    _order = OrderType.DESC_OR_GREATER;
    //  print(_order);
    notifyListeners();
  }

  desc(value) {
    // print(_order);
    _order = OrderType.ASC_OR_SMALLER;
    // print(_order);
    notifyListeners();
  }
}
