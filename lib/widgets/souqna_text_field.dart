import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class SouqnaTextField extends StatefulWidget {
  final TextEditingController? controller;
  final String? hint;
  final String? prefixText;
  final TextInputType? keyboardType;
  final int maxLines;
  final int? maxLength;
  final TextAlign textAlign;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;

  /// يفعّل إخفاء النص مع أيقونة إظهار/إخفاء، مناسب لحقول كلمات المرور.
  final bool isPassword;

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
    this.isPassword = false,
  });

  @override
  State<SouqnaTextField> createState() => _SouqnaTextFieldState();
}

class _SouqnaTextFieldState extends State<SouqnaTextField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    OutlineInputBorder border(Color c, [double w = 1]) => OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: c, width: w),
        );

    return TextFormField(
      controller: widget.controller,
      keyboardType: widget.keyboardType,
      maxLines: widget.isPassword ? 1 : widget.maxLines,
      maxLength: widget.maxLength,
      textAlign: widget.textAlign,
      validator: widget.validator,
      onChanged: widget.onChanged,
      obscureText: widget.isPassword && _obscure,
      decoration: InputDecoration(
        hintText: widget.hint,
        prefixText: widget.prefixText,
        counterText: '',
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: border(SouqnaColors.border),
        enabledBorder: border(SouqnaColors.border),
        focusedBorder: border(SouqnaColors.primary, 1.8),
        suffixIcon: widget.isPassword
            ? IconButton(
                icon: Icon(
                  _obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                  color: SouqnaColors.textMuted,
                  size: 20,
                ),
                onPressed: () => setState(() => _obscure = !_obscure),
              )
            : null,
      ),
    );
  }
}
