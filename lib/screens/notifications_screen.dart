import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  String _filter = 'all';

  final List<Map<String, dynamic>> _items = [
    {
      'id': '1',
      'title': 'حساب الضمان البنكي (Escrow)',
      'body': 'تم حجز مبلغ 3,850 ج.س لطلب شراء آيفون 15 برو ماكس. أموالك في أمان حتى الفحص.',
      'cat': 'escrow',
      'time': 'منذ 10 دقائق',
      'isRead': false,
      'icon': Icons.shield_rounded,
    },
    {
      'id': '2',
      'title': 'عرض سعر جديد من البائع',
      'body': 'وافق البائع عبدالله محمد على عرض السعر (3,650 ج.س). يمكنك إتمام الشراء الآن.',
      'cat': 'chat',
      'time': 'منذ 45 دقيقة',
      'isRead': false,
      'icon': Icons.forum_rounded,
    },
    {
      'id': '3',
      'title': 'اكتمال الفحص الفني',
      'body': 'تقرير الفحص الهندسي المعتمد لجهاز آيباد برو أصبح متاحاً للمراجعة.',
      'cat': 'order',
      'time': 'أمس، 02:15 م',
      'isRead': true,
      'icon': Icons.verified_rounded,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final filtered = _items.where((i) => _filter == 'all' || (_filter == 'unread' ? !i['isRead'] : i['cat'] == _filter)).toList();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: SouqnaColors.surface,
        appBar: AppBar(
          title: const Text('الإشعارات والتنبيهات'),
          actions: [
            TextButton(
              onPressed: () => setState(() => _items.forEach((i) => i['isRead'] = true)),
              child: const Text('تحديد الكل كمقروء', style: TextStyle(color: SouqnaColors.accent, fontSize: 12, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        body: Column(
          children: [
            // شريط الفلاتر
            Container(
              height: 48,
              color: Colors.white,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                children: [
                  _tab('all', 'الكل'),
                  _tab('unread', 'غير مقروءة'),
                  _tab('escrow', 'الضمان البنكي'),
                  _tab('chat', 'المحادثات'),
                  _tab('order', 'الطلبات والفحص'),
                ],
              ),
            ),
            const Divider(height: 1, color: SouqnaColors.border),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: filtered.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (ctx, idx) {
                  final item = filtered[idx];
                  final isRead = item['isRead'] as bool;
                  return InkWell(
                    onTap: () => setState(() => item['isRead'] = true),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: isRead ? Colors.white : const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: isRead ? SouqnaColors.border : SouqnaColors.borderDim, width: isRead ? 1 : 1.5),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(color: SouqnaColors.surfaceLow, borderRadius: BorderRadius.circular(12)),
                            child: Icon(item['icon'] as IconData, color: SouqnaColors.primary, size: 22),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(item['title'], style: TextStyle(fontWeight: isRead ? FontWeight.w600 : FontWeight.bold, fontSize: 13)),
                                    if (!isRead) const CircleAvatar(radius: 4, backgroundColor: SouqnaColors.accent),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(item['body'], style: const TextStyle(fontSize: 11, color: SouqnaColors.textSecondary, height: 1.4)),
                                const SizedBox(height: 6),
                                Text(item['time'], style: const TextStyle(fontSize: 10, color: SouqnaColors.textMuted)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tab(String id, String label) {
    final isSel = _filter == id;
    return GestureDetector(
      onTap: () => setState(() => _filter = id),
      child: Container(
        margin: const EdgeInsets.only(left: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(color: isSel ? SouqnaColors.primary : const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(16)),
        child: Text(label, style: TextStyle(color: isSel ? Colors.white : SouqnaColors.textSecondary, fontSize: 11, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
