import 'package:flutter/material.dart';

class RecommendationAcceptedDialog extends StatelessWidget {
  const RecommendationAcceptedDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Checkmark Icon Container
            Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFF10B981), // Emerald green
              ),
              child: const Center(
                child: Icon(
                  Icons.check_circle_outline,
                  color: Colors.white,
                  size: 52,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Title
            const Text(
              'Recommendation\nAccepted',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1E293B),
                height: 1.3,
              ),
            ),
            const SizedBox(height: 12),

            // Subtitle
            const Text(
              'Medication interchange approved\nand documented.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF64748B),
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
