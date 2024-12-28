import 'package:flutter/material.dart';
import 'package:music/src/colors/colors.dart';
import 'package:music/src/colors/styled_text.dart';

class MusicListtile extends StatelessWidget {
  const MusicListtile({
    super.key,
    required this.musicName,
    required this.artistName,
    required this.onPressed,
    required this.leading,
    required this.trailing,
  });
  final String musicName;
  final VoidCallback onPressed;
  final String artistName;
  final Widget leading;
  final Widget trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        tileColor: bgcolor,
        onTap: onPressed,
        leading: leading,
        title: Text(
          musicName,
          style: fontStyle(
            15,
            whiteColor,
          ),
        ),

        trailing: trailing,
        subtitle: Text(
          artistName,
          style: fontStyle(
            11,
            whiteColor,
          ),
        ),
        // trailing: Icon(
        //   Icons.play_arrow,
        //   size: 26,
        //   color: whiteColor,
        // ),
      ),
    );
  }
}
