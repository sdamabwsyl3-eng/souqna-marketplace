import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../theme/app_colors.dart';
import '../widgets/souqna_button.dart';

class OrderTrackingScreen extends StatefulWidget {
  final Product product;
  const OrderTrackingScreen({super.key, required this.product});

  @override
  State<OrderTrackingScreen> createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen> {
  static const _steps = [
    ['تم الدفع وحجز المبلغ في الضمان', 'المبلغ معلّق لدى سوقنا'],
    ['الفحص الفني', 'فحص السلعة وإصدار التقرير'],
    ['الشحن والتوصيل', 'السلعة في الطريق إليك'],
    ['تأكيد الاستلام', 'تحرير المبلغ للبائع'],
  ];

  int _current = 0;

  @override
  Widget build(BuildContext context) {
    final done = _current >= _steps.length;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('تتبع الطلب')),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.product.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
              const SizedBox(height: 18),
              Expanded(
                child: ListView.builder(
                  itemCount: _steps.length,
                  itemBuilder: (ctx, i) {
                    final complete = i < _current;
                    final active = i == _current;
                    final color = complete || active ? SouqnaColors.success : SouqnaColors.border;
                    return IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Column(
                            children: [
                              CircleAvatar(
                                radius: 13,
                                backgroundColor: color,
                                child: Icon(complete ? Icons.check : (active ? Icons.more_horiz : null), size: 14, color: Colors.white),
                              ),
                              if (i != _steps.length - 1) Expanded(child: Container(width: 2, color: complete ? SouqnaColors.success : SouqnaColors.border)),
                            ],
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 22),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(_steps[i][0], style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: complete || active ? SouqnaColors.textPrimary : SouqnaColors.textMuted)),
                                  const SizedBox(height: 2),
                                  Text(_steps[i][1], style: const TextStyle(fontSize: 11, color: SouqnaColors.textSecondary)),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              if (!done)
                SouqnaButton(
                  title: 'تقدّم للمرحلة التالية (تجريبي)',
                  variant: SouqnaButtonVariant.primary,
                  onPressed: () => setState(() => _current++),
                )
              else
                const Center(
                  child: Text('اكتملت الصفقة بنجاح ✓', style: TextStyle(color: SouqnaColors.success, fontWeight: FontWeight.bold)),
                ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}
