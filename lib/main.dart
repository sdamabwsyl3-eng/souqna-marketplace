import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _isSignUp = false, _loading = false, _hide = true;
  static const navy = Color(0xFF112A4E);

  Future<void> _submit() async {
    final email = _email.text.trim();
    final pass = _password.text;
    if (!email.contains('@') || pass.length < 6) {
      _msg('أدخل بريداً صحيحاً وكلمة سر لا تقل عن 6 أحرف');
      return;
    }
    setState(() => _loading = true);
    try {
      final auth = Supabase.instance.client.auth;
      if (_isSignUp) {
        await auth.signUp(email: email, password: pass);
        _msg('تم إنشاء الحساب، تحقق من بريدك لتأكيده');
      } else {
        await auth.signInWithPassword(email: email, password: pass);
        // الانتقال للرئيسية: Navigator.pushReplacementNamed(context, '/home');
      }
    } on AuthException catch (e) {
      _msg(e.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _msg(String t) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t)));

  InputDecoration _dec(String hint, {Widget? suffix}) => InputDecoration(
        hintText: hint,
        suffixIcon: suffix,
        filled: true,
        fillColor: const Color(0xFFF8F9FB),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: const BorderSide(color: Color(0xFFE2E6EE)),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              const SizedBox(height: 40),
              Container(
                width: 96, height: 96,
                decoration: BoxDecoration(
                    color: navy, borderRadius: BorderRadius.circular(28)),
                child: const Icon(Icons.storefront, color: Colors.white, size: 48),
              ),
              const SizedBox(height: 32),
              const Text('أهلاً بك في سوقنا',
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: navy)),
              const SizedBox(height: 8),
              const Text('سوق موثّق، وضمان بنكي لكل صفقة.',
                  style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 32),
              const Text('البريد الإلكتروني', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextField(
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                textDirection: TextDirection.ltr,
                decoration: _dec('name@example.com'),
              ),
              const SizedBox(height: 16),
              const Text('كلمة السر', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextField(
                controller: _password,
                obscureText: _hide,
                textDirection: TextDirection.ltr,
                decoration: _dec('6 أحرف على الأقل',
                    suffix: IconButton(
                      icon: Icon(_hide ? Icons.visibility_off : Icons.visibility),
                      onPressed: () => setState(() => _hide = !_hide),
                    )),
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 56,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                      backgroundColor: navy,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24))),
                  onPressed: _loading ? null : _submit,
                  child: _loading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(_isSignUp ? 'إنشاء حساب' : 'تسجيل الدخول',
                          style: const TextStyle(fontSize: 18)),
                ),
              ),
              TextButton(
                onPressed: () => setState(() => _isSignUp = !_isSignUp),
                child: Text(_isSignUp ? 'عندي حساب، تسجيل الدخول' : 'ليس لديك حساب؟ أنشئ حساباً'),
              ),
              TextButton(
                onPressed: () { /* وضع المعاينة */ },
                child: const Text('تخطي (وضع المعاينة)'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
