import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/souqna_bottom_sheet.dart';
import '../widgets/souqna_button.dart';
import '../widgets/souqna_text_field.dart';
import 'home_screen.dart';

/// شاشة تسجيل الدخول. ملاحظة: التحقق هنا محاكاة (Mock) فقط.
/// للربط الحقيقي مع نفاذ لازم تسجيل رسمي كجهة مرتبطة مع المركز الوطني للمعلومات.
class NafathLoginScreen extends StatefulWidget {
  const NafathLoginScreen({super.key});

  @override
  State<NafathLoginScreen> createState() => _NafathLoginScreenState();
}

class _NafathLoginScreenState extends State<NafathLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _idController = TextEditingController();
  Timer? _approveTimer;

  @override
  void dispose() {
    _approveTimer?.cancel();
    _idController.dispose();
    super.dispose();
  }

  void _startVerification() {
    if (!_formKey.currentState!.validate()) return;
    final code = (10 + Random().nextInt(90)).toString();

    // نغلق الشيت تلقائياً بعد ثوانٍ لمحاكاة الموافقة من تطبيق نفاذ
    _approveTimer?.cancel();
    _approveTimer = Timer(const Duration(seconds: 3), () {
      if (!mounted) return;
      Navigator.of(context).popUntil((r) => r.isFirst);
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    });

    // لو أغلق المستخدم الشيت يدوياً نلغي الدخول التلقائي
    showSouqnaBottomSheet<void>(
      context: context,
      title: 'التحقق عبر نفاذ',
      child: Column(
        children: [
          const Text(
            'افتح تطبيق نفاذ واختر الرقم التالي للموافقة:',
            style: TextStyle(fontSize: 13, color: SouqnaColors.textSecondary),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 14),
            decoration: BoxDecoration(
              color: SouqnaColors.surfaceLow,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: SouqnaColors.borderDim),
            ),
            child: Text(code, style: const TextStyle(fontSize: 40, fontWeight: FontWeight.w900, color: SouqnaColors.primary)),
          ),
          const SizedBox(height: 16),
          const CircularProgressIndicator(color: SouqnaColors.accent),
          const SizedBox(height: 12),
          const Text('بانتظار الموافقة...', style: TextStyle(fontSize: 12, color: SouqnaColors.textMuted)),
          const SizedBox(height: 8),
        ],
      ),
    ).whenComplete(() {
      // الإغلاق اليدوي (قبل الموافقة) يلغي المؤقت؛ الإغلاق التلقائي يكون بعد تنفيذه
      if (_approveTimer?.isActive ?? false) _approveTimer!.cancel();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 40),
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(color: SouqnaColors.primary, borderRadius: BorderRadius.circular(20)),
                    child: const Icon(Icons.storefront_rounded, color: Colors.white, size: 34),
                  ),
                  const SizedBox(height: 24),
                  const Text('أهلاً بك في سوقنا', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: SouqnaColors.primary)),
                  const SizedBox(height: 6),
                  const Text(
                    'سوق موثّق بالهوية الوطنية، وضمان بنكي لكل صفقة.',
                    style: TextStyle(fontSize: 14, color: SouqnaColors.textSecondary, height: 1.5),
                  ),
                  const SizedBox(height: 36),
                  const Text('رقم الهوية الوطنية / الإقامة', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 8),
                  SouqnaTextField(
                    controller: _idController,
                    hint: '10 أرقام',
                    keyboardType: TextInputType.number,
                    maxLength: 10,
                    validator: (v) {
                      if (v == null || v.trim().length != 10) return 'أدخل 10 أرقام صحيحة';
                      if (int.tryParse(v.trim()) == null) return 'أرقام فقط';
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  SouqnaButton(
                    title: 'تسجيل الدخول عبر نفاذ',
                    icon: Icons.verified_user_rounded,
                    variant: SouqnaButtonVariant.primary,
                    onPressed: _startVerification,
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () => Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (_) => const HomeScreen()),
                    ),
                    child: const Center(
                      child: Text('تخطي (وضع المعاينة)', style: TextStyle(color: SouqnaColors.textSecondary)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
