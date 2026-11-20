import 'package:flutter/material.dart';

/// Displayed on the home screen when no songs are discovered on the device.
class HomeEmptyView extends StatelessWidget {
  final Color textSecondary;
  final Color accentGreen;
  final VoidCallback onRefresh;

  const HomeEmptyView({
    super.key,
    required this.textSecondary,
    required this.accentGreen,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.music_off_rounded,
              size: 48, color: textSecondary.withValues(alpha: 0.5)),
          const SizedBox(height: 12),
          Text("No songs found on device",
              style: TextStyle(fontSize: 15, color: textSecondary)),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: onRefresh,
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: const Text("Scan for Music / Grant Permission"),
            style: ElevatedButton.styleFrom(
              backgroundColor: accentGreen,
              foregroundColor: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
