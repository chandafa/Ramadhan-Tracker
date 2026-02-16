import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
// import 'package:hugeicons/hugeicons.dart';

class ShareableStatWidget extends StatelessWidget {
  final int day;
  final int progress; // 0-100
  final String quote;
  final int streak;

  const ShareableStatWidget({
    super.key,
    required this.day,
    required this.progress,
    required this.quote,
    required this.streak,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1080 / 3, // Scaled down for preview, will be captured at high res
      height: 1920 / 3,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF1B5E20), // Deep Green
            const Color(0xFF004D40), // Teal Green
          ],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Logo / Header
          Icon(
            Icons.mosque_rounded,
            size: 64,
            color: Colors.white.withValues(alpha: 0.9),
          ),
          const SizedBox(height: 16),
          Text(
            'RAMADHAN TRACKER',
            style: GoogleFonts.outfit(
              color: Colors.white.withValues(alpha: 0.8),
              letterSpacing: 2.0,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 48),

          // Main Stat
          Text(
            'DAY $day',
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontSize: 48,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
            ),
            child: Text(
              '$progress% COMPLETED',
              style: GoogleFonts.outfit(
                color: Colors.amberAccent,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          if (streak > 0) ...[
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.local_fire_department_rounded,
                  color: Colors.orange,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  '$streak Days Streak!',
                  style: GoogleFonts.outfit(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],

          const SizedBox(height: 64),

          // Quote
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              '"$quote"',
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                color: Colors.white.withValues(alpha: 0.9),
                fontSize: 16,
                fontStyle: FontStyle.italic,
                height: 1.4,
              ),
            ),
          ),

          const Spacer(),
          Text(
            '#Ramadhan2025 #MyIbadahJourney',
            style: GoogleFonts.outfit(
              color: Colors.white.withValues(alpha: 0.6),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
