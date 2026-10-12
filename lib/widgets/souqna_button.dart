import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

enum SouqnaButtonVariant { primary, accent, outline }

class SouqnaButton extends StatelessWidget {
  final String title;
  final VoidCallback? onPressed;
  final SouqnaButtonVariant variant;
  final IconData? icon;

  const SouqnaButton({
    super.key,
    required this.title,
    required this.onPressed,
    this.variant = SouqnaButtonVariant.accent,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final isOutline = variant == SouqnaButtonVariant.outline;
    final bg = variant == SouqnaButtonVariant.primary
        ? SouqnaColors.primary
        : variant == SouqnaButtonVariant.accent
            ? SouqnaColors.accent
            : Colors.white;
    final fg = isOutline ? SouqnaColors.primary : Colors.white;

    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: bg,
        foregroundColor: fg,
        elevation: 0,
        minimumSize: const Size(double.infinity, 52),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: isOutline
              ? const BorderSide(color: SouqnaColors.primary, width: 2)
              : BorderSide.none,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) ...[Icon(icon, size: 20), const SizedBox(width: 8)],
          Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
