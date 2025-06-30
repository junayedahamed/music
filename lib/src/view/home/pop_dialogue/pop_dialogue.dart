import 'package:flutter/material.dart';

class PopDialogue extends StatelessWidget {
  const PopDialogue({super.key, required this.onpress, required this.onpress2});
  final VoidCallback onpress, onpress2;
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Are you sure?Want to exit app"),
      actions: [
        FilledButton(onPressed: onpress, child: Text("No")),
        FilledButton(onPressed: onpress2, child: Text("Yes"))
      ],
    );
  }
}
