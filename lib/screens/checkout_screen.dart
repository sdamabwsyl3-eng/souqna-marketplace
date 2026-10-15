import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../services/supabase_data_service.dart';
import '../theme/app_colors.dart';
import '../widgets/souqna_button.dart';
import 'order_tracking_screen.dart';

class CheckoutScreen extends StatefulWidget {
  final Product product;
  const CheckoutScreen({super.key, required this.product});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  String _method = 'bank_transfer';
  bool _confirming = false;

  // رسوم الضمان (1%) — نفس النسبة المحسوبة في قاعدة البيانات عند إنشاء الطلب
  double get _escrowFee => widget.product.price * 0.01;
  double get _total => widget.product.price + _escrowFee;

  static const _methods = {
    'bank_transfer': ['تحويل بنكي (بنك الخرطوم / فيصل)', Icons.account_balance_rounded],
    'bankak': ['بنكك (Bankak)', Icons.smartphone_rounded],
    'mashreq_ocash': ['مشرق أوكاش', Icons.account_balance_wallet_rounded],
    'cash_on_delivery': ['الدفع عند الاستلام (كاش)', Icons.payments_rounded],
  };

  Future<void> _confirm() async {
    setState(() => _confirming = true);
    String orderId;
    try {
      orderId = await SupabaseDataService.createOrder(
        productId: widget.product.id,
        paymentMethod: _method,
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _confirming = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('تعذّر إتمام الطلب: ${e.toString()}')));
      return;
    }
    if (!mounted) return;
    setState(() => _confirming = false);

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Row(children: [
            Icon(Icons.shield_rounded, color: SouqnaColors.success),
            SizedBox(width: 8),
            Text('تم حجز المبلغ في الضمان', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
          ]),
          content: Text(
            'سيبقى مبلغ ${_total.toStringAsFixed(2)} ج.س معلّقاً حتى تستلم السلعة وتؤكد سلامتها.',
            style: const TextStyle(fontSize: 13, height: 1.5),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => OrderTrackingScreen(product: widget.product, orderId: orderId)),
                );
              },
              child: const Text('تتبع الطلب', style: TextStyle(fontWeight: FontWeight.bold, color: SouqnaColors.accent)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(String label, String value, {bool bold = false}) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: TextStyle(fontSize: 13, color: bold ? SouqnaColors.textPrimary : SouqnaColors.textSecondary, fontWeight: bold ? FontWeight.bold : FontWeight.normal)),
            Text(value, style: TextStyle(fontSize: bold ? 16 : 13, fontWeight: bold ? FontWeight.w900 : FontWeight.w600, color: bold ? SouqnaColors.primary : SouqnaColors.textPrimary)),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    final p = widget.product;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('إتمام الطلب')),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: SouqnaColors.border)),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(p.images.first, width: 64, height: 64, fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(width: 64, height: 64, color: SouqnaColors.surfaceLow)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(p.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        const SizedBox(height: 2),
                        Text('البائع: ${p.sellerName}', style: const TextStyle(fontSize: 11, color: SouqnaColors.textSecondary)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            const Text('طريقة الدفع', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: SouqnaColors.border)),
              child: Column(
                children: _methods.entries.map((e) {
                  return RadioListTile<String>(
                    value: e.key,
                    // ignore: deprecated_member_use
                    groupValue: _method,
                    // ignore: deprecated_member_use
                    onChanged: (v) => setState(() => _method = v!),
                    activeColor: SouqnaColors.primary,
                    title: Text(e.value[0] as String, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                    secondary: Icon(e.value[1] as IconData, color: SouqnaColors.primary),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: SouqnaColors.border)),
              child: Column(
                children: [
                  _row('سعر السلعة', '${p.price.toStringAsFixed(2)} ج.س'),
                  _row('رسوم الضمان البنكي', '${_escrowFee.toStringAsFixed(2)} ج.س'),
                  const Divider(),
                  _row('الإجمالي', '${_total.toStringAsFixed(2)} ج.س', bold: true),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: SouqnaColors.successLight, borderRadius: BorderRadius.circular(14), border: Border.all(color: SouqnaColors.successBorder)),
              child: const Row(
                children: [
                  Icon(Icons.shield_rounded, color: SouqnaColors.success),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'المبلغ لا يصل للبائع إلا بعد تأكيدك الاستلام.',
                      style: TextStyle(fontSize: 12, color: Color(0xFF065F46), fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SouqnaButton(
              title: _confirming ? 'جارِ التأكيد...' : 'تأكيد ودفع ${_total.toStringAsFixed(0)} ج.س',
              icon: Icons.lock_rounded,
              onPressed: _confirming ? null : _confirm,
            ),
          ],
        ),
      ),
    );
  }
}
