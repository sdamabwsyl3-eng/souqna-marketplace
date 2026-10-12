import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../theme/app_colors.dart';
import '../widgets/souqna_button.dart';
import '../widgets/trust_badge.dart';
import 'chat_negotiation_screen.dart';
import 'checkout_screen.dart';

class ProductDetailsScreen extends StatelessWidget {
  final Product product;
  const ProductDetailsScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('تفاصيل السلعة')),
        body: ListView(
          padding: const EdgeInsets.only(bottom: 120),
          children: [
            SizedBox(
              height: 240,
              child: PageView(
                children: product.images
                    .map((u) => Image.network(
                          u,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            color: SouqnaColors.surfaceLow,
                            child: const Icon(Icons.image_not_supported_outlined),
                          ),
                        ))
                    .toList(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 6,
                    children: [
                      if (product.isInspected) const TrustBadge(label: 'مفحوص هندسياً', icon: Icons.fact_check_rounded),
                      if (product.hasEscrow) const TrustBadge(label: 'ضمان بنكي (Escrow)', icon: Icons.shield_rounded),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(product.title, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 6),
                  Text('${product.price.toStringAsFixed(0)} ر.س',
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: SouqnaColors.primary)),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined, size: 16, color: SouqnaColors.textSecondary),
                      const SizedBox(width: 4),
                      Text('${product.city} - ${product.district}', style: const TextStyle(color: SouqnaColors.textSecondary, fontSize: 12)),
                      const SizedBox(width: 14),
                      Text('الحالة: ${product.condition}', style: const TextStyle(color: SouqnaColors.textSecondary, fontSize: 12)),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: SouqnaColors.border),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 22,
                          backgroundColor: SouqnaColors.surfaceLow,
                          child: Text(product.sellerName.substring(0, 1), style: const TextStyle(color: SouqnaColors.primary, fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(children: [
                                Text(product.sellerName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                const SizedBox(width: 6),
                                const Icon(Icons.verified, size: 16, color: SouqnaColors.success),
                              ]),
                              Text('${product.sellerRating} ⭐ • ${product.sellerDealsCount} صفقة ناجحة',
                                  style: const TextStyle(fontSize: 11, color: SouqnaColors.textSecondary)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        bottomSheet: Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: SouqnaColors.border)),
          ),
          child: Row(
            children: [
              Expanded(
                child: SouqnaButton(
                  title: 'تفاوض',
                  icon: Icons.forum_outlined,
                  variant: SouqnaButtonVariant.outline,
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => ChatNegotiationScreen(product: product)),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 2,
                child: SouqnaButton(
                  title: 'شراء بضمان',
                  icon: Icons.shield_rounded,
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => CheckoutScreen(product: product)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
