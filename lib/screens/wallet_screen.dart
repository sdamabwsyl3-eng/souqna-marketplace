import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../data/mock_data.dart';
import '../models/transaction_model.dart';
import '../theme/app_colors.dart';

class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

  IconData _icon(TransactionType t) {
    switch (t) {
      case TransactionType.deposit:
        return Icons.south_west_rounded;
      case TransactionType.withdrawal:
        return Icons.north_east_rounded;
      case TransactionType.escrowHold:
        return Icons.lock_clock_rounded;
      case TransactionType.escrowReleased:
        return Icons.lock_open_rounded;
    }
  }

  bool _isIncoming(TransactionType t) =>
      t == TransactionType.deposit || t == TransactionType.escrowReleased;

  @override
  Widget build(BuildContext context) {
    final user = MockData.user;
    final fmt = NumberFormat('#,##0.00');
    final dateFmt = DateFormat('yyyy/MM/dd - HH:mm');

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('المحفظة')),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [SouqnaColors.primary, SouqnaColors.primaryLight],
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                ),
                borderRadius: BorderRadius.circular(22),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('الرصيد المتاح', style: TextStyle(color: Colors.white70, fontSize: 12)),
                  const SizedBox(height: 4),
                  Text('${fmt.format(user.walletBalance)} ر.س',
                      style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: Colors.white.withAlpha(31), borderRadius: BorderRadius.circular(12)),
                    child: Row(
                      children: [
                        const Icon(Icons.shield_rounded, color: SouqnaColors.accent, size: 18),
                        const SizedBox(width: 8),
                        const Text('محجوز في الضمان', style: TextStyle(color: Colors.white70, fontSize: 12)),
                        const Spacer(),
                        Text('${fmt.format(user.escrowBalance)} ر.س',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text('سجل العمليات', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 10),
            ...MockData.transactions.map((t) {
              final incoming = _isIncoming(t.type);
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: SouqnaColors.border)),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: SouqnaColors.surfaceLow, borderRadius: BorderRadius.circular(12)),
                      child: Icon(_icon(t.type), color: SouqnaColors.primary, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(t.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                          const SizedBox(height: 3),
                          Text('${dateFmt.format(t.date)} • ${t.referenceNumber}',
                              style: const TextStyle(fontSize: 10, color: SouqnaColors.textMuted)),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('${incoming ? '+' : '-'}${fmt.format(t.amount)}',
                            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: incoming ? SouqnaColors.success : SouqnaColors.textPrimary)),
                        Text(t.status, style: const TextStyle(fontSize: 10, color: SouqnaColors.textSecondary)),
                      ],
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}