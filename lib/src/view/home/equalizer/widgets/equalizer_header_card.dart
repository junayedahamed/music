import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class EqualizerHeaderCard extends StatelessWidget {
  final Color cardBg;
  final Color borderColor;
  final Color textPrimary;
  final Color textSecondary;
  final Color accentBlue;
  final Color accentGreen;
  final bool isDark;

  const EqualizerHeaderCard({
    super.key,
    required this.cardBg,
    required this.borderColor,
    required this.textPrimary,
    required this.textSecondary,
    required this.accentBlue,
    required this.accentGreen,
    required this.isDark,
  });

  Widget _buildEqBar(double height, Color color) {
    return Container(
      width: 7,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.5),
            blurRadius: 6,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.4)
                : Colors.black.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildEqBar(28, accentBlue),
              const SizedBox(width: 6),
              _buildEqBar(44, accentBlue),
              const SizedBox(width: 6),
              _buildEqBar(62, accentGreen),
              const SizedBox(width: 6),
              _buildEqBar(50, accentGreen),
              const SizedBox(width: 6),
              _buildEqBar(34, accentBlue),
              const SizedBox(width: 6),
              _buildEqBar(56, accentBlue),
              const SizedBox(width: 6),
              _buildEqBar(40, accentGreen),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            "Hardware Sound Engine",
            style: GoogleFonts.acme(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: textPrimary,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            "Real-time Android Equalizer & Bass Controller",
            style: TextStyle(
              fontSize: 12,
              color: textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
