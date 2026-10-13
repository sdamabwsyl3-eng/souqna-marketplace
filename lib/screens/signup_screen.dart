import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/souqna_button.dart';
import '../widgets/souqna_text_field.dart';
import 'home_screen.dart';

final RegExp _emailPattern = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');

/// شاشة إنشاء حساب جديد بالبريد الإلكتروني وكلمة المرور.
/// ملاحظة: الإنشاء هنا محاكاة (Mock) محليًا فقط، لحين ربط مزود مصادقة حقيقي.
class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _createAccount() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    setState(() => _loading = false);

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const HomeScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(title: const Text('إنشاء حساب جديد')),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('انضم إلى سوقنا', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: SouqnaColors.primary)),
                  const SizedBox(height: 6),
                  const Text(
                    'أنشئ حسابك للبيع والشراء بضمان بنكي كامل.',
                    style: TextStyle(fontSize: 13, color: SouqnaColors.textSecondary, height: 1.5),
                  ),
                  const SizedBox(height: 28),
                  const Text('الاسم الكامل', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 8),
                  SouqnaTextField(
                    controller: _nameController,
                    hint: 'مثال: عبدالله محمد السالم',
                    validator: (v) => (v ?? '').trim().length < 3 ? 'أدخل اسمك الكامل' : null,
                  ),
                  const SizedBox(height: 16),
                  const Text('البريد الإلكتروني', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 8),
                  SouqnaTextField(
                    controller: _emailController,
                    hint: 'name@example.com',
                    keyboardType: TextInputType.emailAddress,
                    textAlign: TextAlign.left,
                    validator: (v) {
                      final value = (v ?? '').trim();
                      if (value.isEmpty) return 'أدخل البريد الإلكتروني';
                      if (!_emailPattern.hasMatch(value)) return 'صيغة البريد الإلكتروني غير صحيحة';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  const Text('كلمة المرور', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 8),
                  SouqnaTextField(
                    controller: _passwordController,
                    hint: '6 أحرف على الأقل',
                    isPassword: true,
                    textAlign: TextAlign.left,
                    validator: (v) {
                      if ((v ?? '').length < 6) return 'كلمة المرور يجب ألا تقل عن 6 أحرف';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  const Text('تأكيد كلمة المرور', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 8),
                  SouqnaTextField(
                    controller: _confirmPasswordController,
                    hint: 'أعد كتابة كلمة المرور',
                    isPassword: true,
                    textAlign: TextAlign.left,
                    validator: (v) {
                      if (v != _passwordController.text) return 'كلمتا المرور غير متطابقتين';
                      return null;
                    },
                  ),
                  const SizedBox(height: 28),
                  SouqnaButton(
                    title: 'إنشاء حساب',
                    icon: Icons.person_add_alt_1_rounded,
                    variant: SouqnaButtonVariant.primary,
                    onPressed: _loading ? null : _createAccount,
                  ),
                  if (_loading) ...[
                    const SizedBox(height: 16),
                    const Center(child: CircularProgressIndicator(color: SouqnaColors.accent)),
                  ],
                  const SizedBox(height: 16),
                  Center(
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Text('لديك حساب بالفعل؟ ', style: TextStyle(color: SouqnaColors.textSecondary)),
                          Text('تسجيل الدخول', style: TextStyle(color: SouqnaColors.primary, fontWeight: FontWeight.bold)),
                        ],
                      ),
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
