import 'package:flutter/material.dart';

class BankAccountsScreen extends StatefulWidget {
  const BankAccountsScreen({super.key});

  @override
  State<BankAccountsScreen> createState() => _BankAccountsScreenState();
}

class _BankAccountsScreenState extends State<BankAccountsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الحسابات البنكية'),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // بطاقة الحساب الأول
          Card(
            elevation: 3,
            margin: const EdgeInsets.only(bottom: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.blue[100],
                child: const Icon(Icons.account_balance, color: Colors.blue),
              ),
              title: const Text('بنك الخرطوم'),
              subtitle: const Text('**** 1234'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                // تفاصيل الحساب
              },
            ),
          ),
          // بطاقة الحساب الثاني
          Card(
            elevation: 3,
            margin: const EdgeInsets.only(bottom: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.green[100],
                child: const Icon(Icons.account_balance_wallet, color: Colors.green),
              ),
              title: const Text('بنك فيصل المحدود'),
              subtitle: const Text('**** 5678'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                // تفاصيل الحساب
              },
            ),
          ),
          // زر إضافة حساب جديد
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              // فتح نموذج إضافة حساب جديد
            },
            icon: const Icon(Icons.add),
            label: const Text('إضافة حساب بنكي جديد'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              minimumSize: const Size(double.infinity, 50),
            ),
          ),
        ],
      ),
    );
  }
}
