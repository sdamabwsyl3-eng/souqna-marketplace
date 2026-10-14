import '../models/product_model.dart';
import '../models/transaction_model.dart';
import '../models/user_profile_model.dart';

/// بيانات تجريبية للعرض فقط. استبدلها بـ API حقيقي لاحقاً.
class MockData {
  static final UserProfile user = UserProfile(
    fullName: 'عبدالله محمد السالم',
    nationalIdMasked: '10****4582',
    rating: 4.9,
    successfulDealsCount: 42,
    walletBalance: 14850,
    escrowBalance: 3850,
  );

  static final List<Product> products = [
    Product(
      id: 'p1',
      title: 'آيفون 15 برو ماكس 256GB',
      price: 3850,
      city: 'الخرطوم',
      district: 'حي العمارات',
      condition: 'كالجديد',
      images: [
        'https://images.unsplash.com/photo-1511707171634-5f897ff02aa9?q=80&w=600&auto=format&fit=crop',
        'https://images.unsplash.com/photo-1592750475338-74b7b21085ab?q=80&w=600&auto=format&fit=crop',
      ],
      sellerId: 's1',
      sellerName: 'عبدالله محمد',
      sellerRating: 4.9,
      sellerDealsCount: 42,
    ),
    Product(
      id: 'p2',
      title: 'آيباد برو 12.9 إنش M2',
      price: 4200,
      city: 'أم درمان',
      district: 'حي ودنوباوي',
      condition: 'مستعمل ممتاز',
      images: [
        'https://images.unsplash.com/photo-1544244015-0df4b3ffc6b0?q=80&w=600&auto=format&fit=crop',
      ],
      sellerId: 's2',
      sellerName: 'سارة إبراهيم',
      sellerRating: 4.7,
      sellerDealsCount: 18,
    ),
    Product(
      id: 'p3',
      title: 'ساعة ذكية Apple Watch Ultra',
      category: 'ساعات ومقتنيات',
      price: 2100,
      city: 'بورتسودان',
      district: 'حي الديم',
      condition: 'جديد',
      isInspected: false,
      images: [
        'https://images.unsplash.com/photo-1580910051074-3eb694886505?q=80&w=600&auto=format&fit=crop',
      ],
      sellerId: 's3',
      sellerName: 'خالد آدم',
      sellerRating: 4.5,
      sellerDealsCount: 9,
    ),
  ];

  static final List<WalletTransaction> transactions = [
    WalletTransaction(
      id: 't1',
      title: 'حجز مبلغ في الضمان - آيفون 15 برو ماكس',
      amount: 3850,
      type: TransactionType.escrowHold,
      date: DateTime(2026, 10, 11, 12, 30),
      referenceNumber: 'SQ-100231',
      status: 'معلّق',
    ),
    WalletTransaction(
      id: 't2',
      title: 'إيداع عبر بنكك',
      amount: 5000,
      type: TransactionType.deposit,
      date: DateTime(2026, 10, 9, 18, 5),
      referenceNumber: 'SQ-100198',
      status: 'مكتمل',
    ),
    WalletTransaction(
      id: 't3',
      title: 'تحرير مبلغ من الضمان - ساعة ذكية',
      amount: 2100,
      type: TransactionType.escrowReleased,
      date: DateTime(2026, 10, 5, 10, 0),
      referenceNumber: 'SQ-100150',
      status: 'مكتمل',
    ),
    WalletTransaction(
      id: 't4',
      title: 'سحب إلى الحساب البنكي',
      amount: 1500,
      type: TransactionType.withdrawal,
      date: DateTime(2026, 10, 1, 9, 20),
      referenceNumber: 'SQ-100102',
      status: 'مكتمل',
    ),
  ];
}
