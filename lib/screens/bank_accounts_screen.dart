import 'package:flutter/material.dart';
import '../services/supabase_data_service.dart';
import '../theme/app_colors.dart';
import '../widgets/souqna_button.dart';
import '../widgets/souqna_text_field.dart';

class BankAccountsScreen extends StatefulWidget {
  const BankAccountsScreen({super.key});

  @override
  State<BankAccountsScreen> createState() => _BankAccountsScreenState();
}

class _BankAccountsScreenState extends State<BankAccountsScreen> {
  late Future<List<Map<String, dynamic>>> _accountsFuture;

  static const _banks = ['بنك الخرطوم', 'بنك فيصل المحدود', 'بنكك (Bankak)', 'بنك أم درمان الوطني'];

  @override
  void initState() {
    super.initState();
    _accountsFuture = SupabaseDataService.fetchMyBankAccounts();
  }

  void _refresh() => setState(() => _accountsFuture = SupabaseDataService.fetchMyBankAccounts());

  Future<void> _addAccount() async {
    String bank = _banks.first;
    final numberController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    final added = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: Padding(
          padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + MediaQuery.of(ctx).viewInsets.bottom),
          child: StatefulBuilder(
            builder: (ctx, setSheetState) => Container(
              padding: const EdgeInsets.all(18),
              decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(22))),
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('إضافة حساب بنكي', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    const SizedBox(height: 14),
                    DropdownButtonFormField<String>(
                      value: bank,
                      decoration: const InputDecoration(
                        filled: true,
                        fillColor: Color(0xFFF8FAFC),
                        border: OutlineInputBorder(),
                      ),
                      items: _banks.map((b) => DropdownMenuItem(value: b, child: Text(b, style: const TextStyle(fontSize: 13)))).toList(),
                      onChanged: (v) => setSheetState(() => bank = v!),
                    ),
                    const SizedBox(height: 12),
                    SouqnaTextField(
                      controller: numberController,
                      hint: 'رقم الحساب (مثال: 1234567890)',
                      keyboardType: TextInputType.number,
                      validator: (v) => (v ?? '').trim().isEmpty ? 'أدخل رقم الحساب' : null,
                    ),
                    const SizedBox(height: 16),
                    SouqnaButton(
                      title: 'حفظ الحساب',
                      onPressed: () async {
                        if (!formKey.currentState!.validate()) return;
                        try {
                          await SupabaseDataService.addBankAccount(bankName: bank, accountNumber: numberController.text.trim());
                          if (ctx.mounted) Navigator.of(ctx).pop(true);
                        } catch (e) {
                          if (ctx.mounted) {
                            ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text('تعذّر الحفظ: ${e.toString()}')));
                          }
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );

    if (added == true) _refresh();
  }

  Future<void> _delete(String id) async {
    await SupabaseDataService.deleteBankAccount(id);
    _refresh();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: SouqnaColors.surface,
        appBar: AppBar(title: const Text('الحسابات البنكية')),
        body: FutureBuilder<List<Map<String, dynamic>>>(
          future: _accountsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            final accounts = snapshot.data ?? const [];
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (accounts.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: Center(child: Text('ما عندك حسابات بنكية مسجّلة بعد', style: TextStyle(color: SouqnaColors.textMuted))),
                  )
                else
                  ...accounts.map((a) => Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: SouqnaColors.border)),
                        child: ListTile(
                          leading: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(color: SouqnaColors.surfaceLow, borderRadius: BorderRadius.circular(12)),
                            child: const Icon(Icons.account_balance_rounded, color: SouqnaColors.primary),
                          ),
                          title: Text(a['bank_name'] as String, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          subtitle: Text('**** ${_lastFour(a['account_number'] as String)}', style: const TextStyle(fontSize: 11, color: SouqnaColors.textSecondary)),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_outline_rounded, color: SouqnaColors.textMuted, size: 20),
                            onPressed: () => _delete(a['id'] as String),
                          ),
                        ),
                      )),
                const SizedBox(height: 8),
                SouqnaButton(title: 'إضافة حساب بنكي جديد', icon: Icons.add_rounded, onPressed: _addAccount),
              ],
            );
          },
        ),
      ),
    );
  }

  String _lastFour(String number) => number.length > 4 ? number.substring(number.length - 4) : number;
}
