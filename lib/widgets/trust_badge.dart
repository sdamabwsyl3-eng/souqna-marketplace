import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class TrustBadge extends StatelessWidget {
  final String label;
  final IconData icon;

  const TrustBadge({
    super.key,
    this.label = 'موثق عبر نفاذ',
    this.icon = Icons.verified_rounded,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: SouqnaColors.successLight,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: SouqnaColors.successBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: SouqnaColors.success),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Color(0xFF047857),
            ),
          ),
        ],
      ),
    );
  }
}
