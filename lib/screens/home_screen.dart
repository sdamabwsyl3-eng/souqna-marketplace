import 'package:flutter/material.dart';
import '../data/mock_data.dart';
import '../models/product_model.dart';
import '../theme/app_colors.dart';
import '../widgets/trust_badge.dart';
import 'add_listing_screen.dart';
import 'notifications_screen.dart';
import 'product_details_screen.dart';
import 'profile_screen.dart';
import 'wallet_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: IndexedStack(
          index: _tab,
          children: const [
            _ExploreTab(),
            NotificationsScreen(),
            WalletScreen(),
            ProfileScreen(),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          backgroundColor: SouqnaColors.accent,
          foregroundColor: Colors.white,
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const AddListingScreen()),
          ),
          icon: const Icon(Icons.add),
          label: const Text('بيع سلعة', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _tab,
          onDestinationSelected: (i) => setState(() => _tab = i),
          backgroundColor: Colors.white,
          indicatorColor: SouqnaColors.surfaceLow,
          destinations: const [
            NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home_rounded), label: 'الرئيسية'),
            NavigationDestination(icon: Icon(Icons.notifications_outlined), selectedIcon: Icon(Icons.notifications_rounded), label: 'الإشعارات'),
            NavigationDestination(icon: Icon(Icons.account_balance_wallet_outlined), selectedIcon: Icon(Icons.account_balance_wallet_rounded), label: 'المحفظة'),
            NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person_rounded), label: 'حسابي'),
          ],
        ),
      ),
    );
  }
}

class _ExploreTab extends StatefulWidget {
  const _ExploreTab();

  @override
  State<_ExploreTab> createState() => _ExploreTabState();
}

class _ExploreTabState extends State<_ExploreTab> {
  final _searchController = TextEditingController();
  String _query = '';
  String _category = 'الكل';

  static const _categories = ['الكل', 'أجهزة وإلكترونيات', 'سيارات ومركبات', 'عقارات', 'ساعات ومقتنيات'];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<Product> items = MockData.products
        .where((p) =>
            p.title.toLowerCase().contains(_query.trim().toLowerCase()) &&
            (_category == 'الكل' || p.category == _category))
        .toList();

    return Scaffold(
      appBar: AppBar(title: const Text('سوقنا')),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
            child: TextField(
              controller: _searchController,
              onChanged: (v) => setState(() => _query = v),
              decoration: InputDecoration(
                hintText: 'ابحث عن سلعة...',
                prefixIcon: const Icon(Icons.search, color: SouqnaColors.textMuted),
                filled: true,
                fillColor: const Color(0xFFF1F5F9),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
              ),
            ),
          ),
          Container(
            height: 46,
            color: Colors.white,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              children: _categories.map((c) {
                final sel = c == _category;
                return GestureDetector(
                  onTap: () => setState(() => _category = c),
                  child: Container(
                    margin: const EdgeInsets.only(left: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: sel ? SouqnaColors.primary : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Text(c, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: sel ? Colors.white : SouqnaColors.textSecondary)),
                  ),
                );
              }).toList(),
            ),
          ),
          const Divider(height: 1, color: SouqnaColors.border),
          Expanded(
            child: items.isEmpty
                ? const Center(child: Text('لا توجد نتائج', style: TextStyle(color: SouqnaColors.textMuted)))
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 14),
                    itemBuilder: (ctx, i) => _ProductCard(product: items[i]),
                  ),
          ),
        ],
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final Product product;
  const _ProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => ProductDetailsScreen(product: product)),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: SouqnaColors.border),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Image.network(
                    product.images.first,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    errorBuilder: (_, __, ___) => Container(
                      color: SouqnaColors.surfaceLow,
                      child: const Icon(Icons.image_not_supported_outlined, color: SouqnaColors.textMuted),
                    ),
                  ),
                ),
                if (product.isInspected)
                  const Positioned(top: 10, right: 10, child: TrustBadge(label: 'مفحوص ومضمون')),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 4),
                  Text('${product.city} • ${product.district} • ${product.condition}',
                      style: const TextStyle(fontSize: 11, color: SouqnaColors.textSecondary)),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('${product.price.toStringAsFixed(0)} ج.س',
                          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: SouqnaColors.primary)),
                      if (product.hasEscrow)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(color: SouqnaColors.surfaceLow, borderRadius: BorderRadius.circular(8)),
                          child: const Text('ضمان بنكي', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: SouqnaColors.primary)),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
