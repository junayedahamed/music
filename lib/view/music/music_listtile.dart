import 'package:flutter/material.dart';
import 'package:music/src/colors/colors.dart';
import 'package:music/src/colors/styled_text.dart';

class MusicListtile extends StatelessWidget {
  const MusicListtile({
    super.key,
    required this.musicName,
    required this.artistName,
  });
  final String musicName;
  final String artistName;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(
        bottom: 2,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(13),
        color: bgcolor,
      ),
      // color: Colors.amber,
      child: ListTile(
        leading: Icon(
          Icons.music_note,
          color: whiteColor,
        ),
        title: Text(
          "Name",
          style: fontStyle(
            15,
            whiteColor,
          ),
        ),
        subtitle: Text(
          "Artist name...",
          style: fontStyle(
            11,
            whiteColor,
          ),
        ),
        trailing: Icon(
          Icons.play_arrow,
          size: 26,
          color: whiteColor,
        ),
      ),
    );
  }
}
