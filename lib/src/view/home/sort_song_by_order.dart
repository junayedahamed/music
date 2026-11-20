import 'package:flutter/material.dart';
import 'package:music/src/utils/custom_order.dart';
import 'package:music/src/view/home/home_view.dart';
import 'package:on_audio_query/on_audio_query.dart';

class SortSongByOrder extends ChangeNotifier {
  OrderType _order = OrderType.ASC_OR_SMALLER;
  OrderType get order => _order;
  // setSorttype(value) {
  //   if (value == Customorder.duration) {
  //     _order = SongSortType.DURATION;
  //   } else if (value == Customorder.addeddate) {
  //     _order = SongSortType.DATE_ADDED;
  //   } else if (value == Customorder.name) {
  //     _order = SongSortType.DISPLAY_NAME;
  //   } else if (value == Customorder.title) {
  //     _order = SongSortType.TITLE;
  //   } else {
  //     _order = SongSortType.SIZE;
  //   }

  //   notifyListeners();
  // }

  void sortby(Customorder value) {
    // print(_order);
    if (value == Customorder.ztoa) {
      _order = OrderType.DESC_OR_GREATER;
    } else {
      _order = OrderType.ASC_OR_SMALLER;
    }
    // print(_order);
    notifyListeners();
  }

  // ztoA(value) {
  //   // print(_order);

  //   // print(_order);
  //   notifyListeners();
  //  }
}
