// import 'dart:async';

// import 'package:flutter/widgets.dart';
// import 'package:get/get.dart';
// import 'package:music/src/controller/audio_controller.dart';
// import 'package:on_audio_query/on_audio_query.dart';

// class LazyLoading extends GetxController {
//   List<SongModel> song = [];
//   final ScrollController _controller = ScrollController();
//   final Stream<List<SongModel>> _visibleSongs = Stream.empty();
//   final PlayerController contoller = Get.put(PlayerController());
//   bool _isLoading = false;
//   int _itemsPerPage = 10;
//   int _currentMaxIndex = 0;

//   @override
//   void onInit() async {
//     song = await contoller.audioQuery.querySongs(
//       ignoreCase: true,
//       sortType: null,
//       uriType: UriType.EXTERNAL,
//     );
//     super.onInit();
//   }

//   void loadMore(){
//     if(_controller.position.pixels>=_controller.position.maxScrollExtent&&!_isLoading){

//     }
//   }
// }
