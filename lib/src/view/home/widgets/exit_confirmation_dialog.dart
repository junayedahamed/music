import 'package:flutter/material.dart';

class ExitConfirmationDialog extends StatelessWidget {
  final Color cardBg;
  final Color textPrimary;
  final Color textSecondary;
  final Color accentGreen;

  const ExitConfirmationDialog({
    super.key,
    required this.cardBg,
    required this.textPrimary,
    required this.textSecondary,
    required this.accentGreen,
  });

  static Future<bool?> show(
    BuildContext context, {
    required Color cardBg,
    required Color textPrimary,
    required Color textSecondary,
    required Color accentGreen,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => ExitConfirmationDialog(
        cardBg: cardBg,
        textPrimary: textPrimary,
        textSecondary: textSecondary,
        accentGreen: accentGreen,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: cardBg,
      title: Text('Exit App?',
          style: TextStyle(color: textPrimary, fontWeight: FontWeight.bold)),
      content: Text('Do you really want to exit?',
          style: TextStyle(color: textSecondary)),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text('Cancel', style: TextStyle(color: textSecondary)),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text('Exit',
              style:
                  TextStyle(color: accentGreen, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}
