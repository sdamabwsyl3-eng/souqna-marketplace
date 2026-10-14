import 'package:flutter/material.dart';
import '../data/sudan_states.dart';
import '../theme/app_colors.dart';

class AddListingScreen extends StatefulWidget {
  const AddListingScreen({super.key});

  @override
  State<AddListingScreen> createState() => _AddListingScreenState();
}

class _AddListingScreenState extends State<AddListingScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _districtController = TextEditingController();

  String _category = 'أجهزة وإلكترونيات';
  String _condition = 'كالجديد';
  String _city = 'الخرطوم';
  bool _isNegotiable = true;
  bool _enableEscrow = true;
  bool _requestInspection = false;

  final List<String> _images = [
    'https://images.unsplash.com/photo-1511707171634-5f897ff02aa9?q=80&w=400&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1592750475338-74b7b21085ab?q=80&w=400&auto=format&fit=crop',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _priceController.dispose();
    _descController.dispose();
    _districtController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: SouqnaColors.surface,
        appBar: AppBar(
          title: const Text('إضافة سلعة للبيع'),
          actions: [
            TextButton(
              onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم حفظ المسودة'))),
              child: const Text('حفظ كمسودة', style: TextStyle(color: SouqnaColors.textSecondary, fontWeight: FontWeight.bold, fontSize: 13)),
            ),
          ],
        ),
        body: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // 1. قسم رفع ومعاينة الصور
                _card(
                  title: 'صور السلعة (حتى 8 صور)',
                  subtitle: 'الصور الواضحة ترفع سرعة البيع وتزيد موثوقية إعلانك',
                  child: SizedBox(
                    height: 100,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        GestureDetector(
                          onTap: () => _images.length >= 8 ? ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('الحد الأقصى 8 صور'))) : setState(() => _images.add('https://images.unsplash.com/photo-1580910051074-3eb694886505?q=80&w=400&auto=format&fit=crop')),
                          child: Container(
                            width: 90,
                            margin: const EdgeInsets.only(left: 10),
                            decoration: BoxDecoration(
                              color: SouqnaColors.surfaceLow,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: SouqnaColors.borderDim),
                            ),
                            child: const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add_a_photo_outlined, color: SouqnaColors.primary, size: 26),
                                SizedBox(height: 4),
                                Text('إضافة صورة', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: SouqnaColors.primary)),
                              ],
                            ),
                          ),
                        ),
                        ..._images.asMap().entries.map((e) => Stack(
                          children: [
                            Container(
                              width: 90,
                              margin: const EdgeInsets.only(left: 10),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                image: DecorationImage(image: NetworkImage(e.value), fit: BoxFit.cover),
                              ),
                            ),
                            if (e.key == 0)
                              Positioned(
                                bottom: 6,
                                right: 14,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(color: SouqnaColors.primary.withAlpha(217), borderRadius: BorderRadius.circular(6)),
                                  child: const Text('الرئيسية', style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold)),
                                ),
                              ),
                            Positioned(
                              top: 4,
                              left: 14,
                              child: GestureDetector(
                                onTap: () => setState(() => _images.removeAt(e.key)),
                                child: const CircleAvatar(radius: 10, backgroundColor: Colors.red, child: Icon(Icons.close, size: 12, color: Colors.white)),
                              ),
                            ),
                          ],
                        )),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // 2. تفاصيل السلعة
                _card(
                  title: 'بيانات السلعة',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFormField(
                        controller: _titleController,
                        decoration: _inputDec(hint: 'عنوان الإعلان (مثال: آيفون 15 برو ماكس 256GB)'),
                        validator: (v) => (v ?? '').trim().isEmpty ? 'يرجى كتابة عنوان الإعلان' : null,
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: _category,
                        decoration: _inputDec(),
                        items: ['أجهزة وإلكترونيات', 'سيارات ومركبات', 'عقارات', 'ساعات ومقتنيات'].map((c) => DropdownMenuItem(value: c, child: Text(c, style: const TextStyle(fontSize: 13)))).toList(),
                        onChanged: (v) => setState(() => _category = v!),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        children: ['جديد', 'كالجديد', 'مستعمل ممتاز'].map((cond) {
                          final isSel = _condition == cond;
                          return ChoiceChip(
                            label: Text(cond, style: TextStyle(color: isSel ? Colors.white : SouqnaColors.textPrimary, fontSize: 12, fontWeight: FontWeight.bold)),
                            selected: isSel,
                            selectedColor: SouqnaColors.primary,
                            onSelected: (_) => setState(() => _condition = cond),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _descController,
                        maxLines: 3,
                        decoration: _inputDec(hint: 'اكتب وصفاً مفصلاً لحالة السلعة ومرفقاتها...'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // 2.5 الموقع (الولاية والمنطقة)
                _card(
                  title: 'الموقع',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      DropdownButtonFormField<String>(
                        value: _city,
                        decoration: _inputDec(hint: 'الولاية'),
                        items: SudanStates.all
                            .map((s) => DropdownMenuItem(value: s, child: Text(s, style: const TextStyle(fontSize: 13))))
                            .toList(),
                        onChanged: (v) => setState(() => _city = v!),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _districtController,
                        decoration: _inputDec(hint: 'الحي / المنطقة (مثال: حي العمارات)'),
                        validator: (v) => (v ?? '').trim().isEmpty ? 'يرجى كتابة الحي أو المنطقة' : null,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // 3. السعر والتفاوض
                _card(
                  title: 'السعر وخيارات التفاوض',
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _priceController,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(fontWeight: FontWeight.w900, color: SouqnaColors.primary, fontSize: 16),
                        decoration: _inputDec(hint: '0.00', prefix: 'ج.س  '),
                        validator: (v) {
          final n = double.tryParse((v ?? '').trim());
          return (n == null || n <= 0) ? 'أدخل سعراً صحيحاً أكبر من صفر' : null;
        },
                      ),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        activeColor: SouqnaColors.primary,
                        title: const Text('السماح بتقديم عروض أسعار والتفاوض', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                        value: _isNegotiable,
                        onChanged: (v) => setState(() => _isNegotiable = v),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // 4. الضمان البنكي والفحص
                _card(
                  title: 'مزايا الأمان (سوقنا الموثوق)',
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: SouqnaColors.surfaceLow, borderRadius: BorderRadius.circular(14), border: Border.all(color: SouqnaColors.borderDim)),
                        child: Row(
                          children: [
                            const Icon(Icons.shield_rounded, color: SouqnaColors.primary, size: 26),
                            const SizedBox(width: 10),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('تفعيل حساب الضمان البنكي (Escrow)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: SouqnaColors.primary)),
                                  Text('يمنح الإعلان شارة موثوق، ويُحجز المبلغ بحساب معلق حتى الاستلام.', style: TextStyle(fontSize: 10, color: SouqnaColors.textSecondary)),
                                ],
                              ),
                            ),
                            Switch(value: _enableEscrow, activeColor: SouqnaColors.primary, onChanged: (v) => setState(() => _enableEscrow = v)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: SouqnaColors.successLight, borderRadius: BorderRadius.circular(14), border: Border.all(color: SouqnaColors.successBorder)),
                        child: Row(
                          children: [
                            const Icon(Icons.verified_rounded, color: SouqnaColors.success, size: 26),
                            const SizedBox(width: 10),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('طلب فحص فني وهندسي معتمد', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF065F46))),
                                  Text('فحص ميداني للسلعة وإصدار شهادة تقرير فني معتمدة داخل الإعلان.', style: TextStyle(fontSize: 10, color: Color(0xFF047857))),
                                ],
                              ),
                            ),
                            Checkbox(value: _requestInspection, activeColor: SouqnaColors.success, onChanged: (v) => setState(() => _requestInspection = v ?? false)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // زر النشر
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: SouqnaColors.accent,
                    minimumSize: const Size(double.infinity, 52),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم نشر السلعة بنجاح بضمان سوقنا!')));
                    }
                  },
                  child: const Text('نشر السلعة في سوقنا الآن', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _card({required String title, String? subtitle, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: SouqnaColors.border)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: SouqnaColors.textPrimary)),
          if (subtitle != null) ...[const SizedBox(height: 2), Text(subtitle, style: const TextStyle(fontSize: 11, color: SouqnaColors.textSecondary))],
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  InputDecoration _inputDec({String? hint, String? prefix}) {
    return InputDecoration(
      hintText: hint,
      prefixText: prefix,
      prefixStyle: const TextStyle(fontWeight: FontWeight.bold, color: SouqnaColors.primary),
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: SouqnaColors.border)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: SouqnaColors.border)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: SouqnaColors.primary, width: 1.8)),
    );
  }
}
