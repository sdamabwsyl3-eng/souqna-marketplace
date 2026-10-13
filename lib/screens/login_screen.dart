import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../theme/app_colors.dart';
import '../widgets/souqna_button.dart';
import '../widgets/souqna_text_field.dart';
import 'home_screen.dart';
import 'signup_screen.dart';

final RegExp _emailPattern = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');

/// شاشة تسجيل الدخول بالبريد الإلكتروني وكلمة المرور، عبر Supabase Auth.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    try {
      await Supabase.instance.client.auth.signInWithPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } on AuthException catch (e) {
      _showError(e.message);
    } catch (_) {
      _showError('تعذّر الاتصال، تحقق من الإنترنت وحاول مرة أخرى');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
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
                  Align(
                    alignment: AlignmentDirectional.centerEnd,
                    child: TextButton(
                      onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('سيتم تفعيل استعادة كلمة المرور قريباً')),
                      ),
                      child: const Text('نسيت كلمة المرور؟', style: TextStyle(color: SouqnaColors.textSecondary, fontSize: 12)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SouqnaButton(
                    title: 'تسجيل الدخول',
                    icon: Icons.login_rounded,
                    variant: SouqnaButtonVariant.primary,
                    onPressed: _loading ? null : _login,
                  ),
                  if (_loading) ...[
                    const SizedBox(height: 16),
                    const Center(child: CircularProgressIndicator(color: SouqnaColors.accent)),
                  ],
                  const SizedBox(height: 20),
                  Center(
                    child: TextButton(
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const SignupScreen()),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Text('ليس لديك حساب؟ ', style: TextStyle(color: SouqnaColors.textSecondary)),
                          Text('إنشاء حساب جديد', style: TextStyle(color: SouqnaColors.primary, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
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
