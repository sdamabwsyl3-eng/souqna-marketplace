import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'bank_accounts_screen.dart';
import 'wallet_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _pushNotifications = true;
  bool _escrowUpdates = true;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: SouqnaColors.surface,
        appBar: AppBar(title: const Text('الملف الشخصي والحساب')),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. بطاقة الهوية الرقمية ونفاذ
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [SouqnaColors.primary, Color(0xFF1E3A8A)],
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                  ),
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [BoxShadow(color: SouqnaColors.primary.withAlpha(38), blurRadius: 10, offset: const Offset(0, 4))],
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const CircleAvatar(
                          radius: 28,
                          backgroundColor: Colors.white,
                          child: Text('ع.م', style: TextStyle(color: SouqnaColors.primary, fontWeight: FontWeight.bold, fontSize: 18)),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Row(
                                children: [
                                  Text('عبدالله محمد السالم', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                                  SizedBox(width: 6),
                                  Icon(Icons.verified, color: SouqnaColors.success, size: 18),
                                ],
                              ),
                              const SizedBox(height: 3),
                              const Text('هوية: 10****4582 • الرياض', style: TextStyle(color: Colors.white70, fontSize: 11)),
                              const SizedBox(height: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(color: SouqnaColors.success.withAlpha(51), borderRadius: BorderRadius.circular(6)),
                                child: const Text('موثق بهوية وطنية عبر نفاذ', style: TextStyle(color: SouqnaColors.successBorder, fontSize: 10, fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Divider(color: Colors.white24, height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _stat('التقييم العام', '4.9 ⭐', '42 صفقة'),
                        Container(height: 22, width: 1, color: Colors.white24),
                        _stat('الرصيد المتاح', '14,850 ر.س', 'المحفظة'),
                        Container(height: 22, width: 1, color: Colors.white24),
                        _stat('في الضمان', '3,850 ر.س', 'Escrow'),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // 2. إعدادات الإشعارات والتنبيهات
              const Text('إعدادات التنبيهات المباشرة', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: SouqnaColors.textPrimary)),
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: SouqnaColors.border)),
                child: Column(
                  children: [
                    SwitchListTile(
                      activeColor: SouqnaColors.primary,
                      title: const Text('الإشعارات اللحظية (Push)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                      subtitle: const Text('تنبيهات المحادثات وعروض الأسعار الفورية', style: TextStyle(fontSize: 11, color: SouqnaColors.textSecondary)),
                      value: _pushNotifications,
                      onChanged: (v) => setState(() => _pushNotifications = v),
                    ),
                    const Divider(height: 1),
                    SwitchListTile(
                      activeColor: SouqnaColors.primary,
                      title: const Text('تحديثات الضمان البنكي والطلبات', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                      subtitle: const Text('مراحل الفحص وتحرير مبالغ Escrow', style: TextStyle(fontSize: 11, color: SouqnaColors.textSecondary)),
                      value: _escrowUpdates,
                      onChanged: (v) => setState(() => _escrowUpdates = v),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // 3. إدارة المعاملات
              const Text('إدارة الحساب والأمان', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: SouqnaColors.textPrimary)),
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: SouqnaColors.border)),
                child: Column(
                  children: [
                    _tile(Icons.account_balance_wallet_outlined, 'المحفظة وسجل العمليات', 'كشف الحساب والتحويل السريع', () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const WalletScreen()))),
                    _tile(Icons.credit_card_rounded, 'الحسابات البنكية والآيبان', 'إدارة حسابات السحب بنظام سريع', () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const BankAccountsScreen()))),
                    _tile(Icons.shield_outlined, 'مركز النزاعات وحماية المشتري', 'حل الخلافات وحماية المعاملات', () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('قريباً')))),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _stat(String label, String val, String sub) {
    return Column(
      children: [
        Text(val, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 10)),
        Text(sub, style: const TextStyle(color: SouqnaColors.accent, fontSize: 9, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _tile(IconData icon, String title, String sub, VoidCallback onTap) {
    return ListTile(
      leading: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: SouqnaColors.surfaceLow, borderRadius: BorderRadius.circular(10)), child: Icon(icon, color: SouqnaColors.primary, size: 20)),
      title: Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
      subtitle: Text(sub, style: const TextStyle(fontSize: 11, color: SouqnaColors.textSecondary)),
      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 13, color: SouqnaColors.textMuted),
      onTap: onTap,
    );
  }
}
