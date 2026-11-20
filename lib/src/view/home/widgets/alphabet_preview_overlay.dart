import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AlphabetPreviewOverlay extends StatelessWidget {
  final bool showPreview;
  final String? activeLetter;
  final bool isDark;
  final Color cardBg;
  final Color accentBlue;

  const AlphabetPreviewOverlay({
    super.key,
    required this.showPreview,
    required this.activeLetter,
    required this.isDark,
    required this.cardBg,
    required this.accentBlue,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: showPreview && activeLetter != null ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 180),
      child: IgnorePointer(
        child: Center(
          child: Container(
            width: 80,
            height: 88,
            decoration: BoxDecoration(
              color: isDark
                  ? cardBg.withValues(alpha: 0.94)
                  : Colors.white.withValues(alpha: 0.96),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: accentBlue.withValues(alpha: 0.8),
                width: 2.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: isDark
                      ? Colors.black.withValues(alpha: 0.7)
                      : const Color(0xff64748b).withValues(alpha: 0.2),
                  blurRadius: 22,
                  spreadRadius: 3,
                  offset: const Offset(0, 6),
                ),
                if (isDark)
                  BoxShadow(
                    color: accentBlue.withValues(alpha: 0.3),
                    blurRadius: 18,
                    spreadRadius: 1,
                  ),
              ],
            ),
            child: Center(
              child: Text(
                activeLetter ?? '',
                style: GoogleFonts.acme(
                  fontSize: 42,
                  fontWeight: FontWeight.bold,
                  color: accentBlue,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
