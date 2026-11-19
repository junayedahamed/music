import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:music/src/controller/theme_controller.dart';

class MusicListtile extends StatelessWidget {
  const MusicListtile({
    super.key,
    required this.musicName,
    required this.artistName,
    required this.onPressed,
    required this.leading,
    this.trailing,
  });

  final String musicName;
  final VoidCallback onPressed;
  final String artistName;
  final Widget leading;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final themeController = Get.put(ThemeController());

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      child: Obx(() {
        final cardBg = themeController.cardBg;
        final titleColor = themeController.textPrimary;
        final subtitleColor = themeController.textSecondary;

        return ListTile(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: BorderSide(
              color: themeController.borderColor,
              width: 0.8,
            ),
          ),
          tileColor: cardBg,
          onTap: onPressed,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          leading: leading,
          title: Text(
            musicName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: titleColor,
            ),
          ),
          subtitle: Text(
            artistName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12,
              color: subtitleColor,
            ),
          ),
          trailing: trailing,
        );
      }),
    );
  }
}
