import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class SouqnaTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? hint;
  final String? prefixText;
  final TextInputType? keyboardType;
  final int maxLines;
  final int? maxLength;
  final TextAlign textAlign;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;

  const SouqnaTextField({
    super.key,
    this.controller,
    this.hint,
    this.prefixText,
    this.keyboardType,
    this.maxLines = 1,
    this.maxLength,
    this.textAlign = TextAlign.start,
    this.validator,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    OutlineInputBorder border(Color c, [double w = 1]) => OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: c, width: w),
        );

    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      maxLength: maxLength,
      textAlign: textAlign,
      validator: validator,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hint,
        prefixText: prefixText,
        counterText: '',
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: border(SouqnaColors.border),
        enabledBorder: border(SouqnaColors.border),
        focusedBorder: border(SouqnaColors.primary, 1.8),
      ),
    );
  }
}
