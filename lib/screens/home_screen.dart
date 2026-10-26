import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/sudan_states.dart';
import '../models/product_model.dart';
import '../services/supabase_data_service.dart';
import '../theme/app_colors.dart';
import '../widgets/trust_badge.dart';
import 'add_listing_screen.dart';
import 'bank_accounts_screen.dart';
import 'conversations_screen.dart';
import 'favorites_screen.dart';
import 'login_screen.dart';
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
            FavoritesScreen(),
            NotificationsScreen(),
            ConversationsScreen(),
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
            NavigationDestination(icon: Icon(Icons.favorite_border), selectedIcon: Icon(Icons.favorite_rounded), label: 'المفضلة'),
            NavigationDestination(icon: Icon(Icons.notifications_outlined), selectedIcon: Icon(Icons.notifications_rounded), label: 'الإشعارات'),
            NavigationDestination(icon: Icon(Icons.chat_bubble_outline), selectedIcon: Icon(Icons.chat_bubble_rounded), label: 'المحادثات'),
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
  String? _selectedState; // null = كل المحافظات
  late Future<List<Product>> _productsFuture;
  Set<String> _favoriteIds = {};

  static const _categories = ['الكل', 'أجهزة وإلكترونيات', 'سيارات ومركبات', 'عقارات', 'ساعات ومقتنيات'];

  @override
  void initState() {
    super.initState();
    _productsFuture = SupabaseDataService.fetchProducts();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final ids = await SupabaseDataService.fetchMyFavoriteProductIds();
    if (!mounted) return;
    setState(() => _favoriteIds = ids);
  }

  Future<void> _toggleFavorite(String productId) async {
    final wasFavorite = _favoriteIds.contains(productId);
    setState(() {
      if (wasFavorite) {
        _favoriteIds.remove(productId);
      } else {
        _favoriteIds.add(productId);
      }
    });
    try {
      await SupabaseDataService.toggleFavorite(productId);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        if (wasFavorite) {
          _favoriteIds.add(productId);
        } else {
          _favoriteIds.remove(productId);
        }
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('تعذّر تحديث المفضلة: $e')));
    }
  }

  Future<void> _refresh() async {
    final future = SupabaseDataService.fetchProducts();
    setState(() => _productsFuture = future);
    await future;
    _loadFavorites();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String get _displayName {
    final user = Supabase.instance.client.auth.currentUser;
    final fullName = (user?.userMetadata?['full_name'] as String?)?.trim();
    if (fullName != null && fullName.isNotEmpty) return fullName;
    return user?.email?.split('@').first ?? 'مستخدم سوقنا';
  }

  String get _email => Supabase.instance.client.auth.currentUser?.email ?? '';

  String get _initials {
    final parts = _displayName.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return 'س';
    final first = parts.first.substring(0, 1);
    final second = parts.length > 1 && parts.last.isNotEmpty ? parts.last.substring(0, 1) : '';
    return '$first$second';
  }

  Future<void> _logout() async {
    await Supabase.instance.client.auth.signOut();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('سوقنا'),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(left: 12),
            child: GestureDetector(
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              ),
              child: CircleAvatar(
                radius: 16,
                backgroundColor: SouqnaColors.surfaceLow,
                child: Text(_initials, style: const TextStyle(color: SouqnaColors.primary, fontWeight: FontWeight.bold, fontSize: 11)),
              ),
            ),
          ),
        ],
      ),
      drawer: _buildDrawer(context),
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
          Container(
            width: double.infinity,
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: GestureDetector(
              onTap: _openStateFilter,
              child: Row(
                children: [
                  const Icon(Icons.expand_more, size: 18, color: SouqnaColors.textSecondary),
                  const SizedBox(width: 4),
                  Text(
                    _selectedState ?? 'كل المحافظات',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: SouqnaColors.primary),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Product>>(
              future: _productsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return const Center(
                    child: Text('تعذّر تحميل السلع، تحقق من الإنترنت', style: TextStyle(color: SouqnaColors.textMuted)),
                  );
                }
                final items = (snapshot.data ?? const [])
                    .where((p) =>
                        p.title.toLowerCase().contains(_query.trim().toLowerCase()) &&
                        (_category == 'الكل' || p.category == _category) &&
                        (_selectedState == null || p.city == _selectedState))
                    .toList();

                return RefreshIndicator(
                  onRefresh: _refresh,
                  child: items.isEmpty
                      ? ListView(
                          children: const [
                            SizedBox(height: 120),
                            Center(child: Text('لا توجد سلع بعد', style: TextStyle(color: SouqnaColors.textMuted))),
                          ],
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
                          itemCount: items.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 14),
                          itemBuilder: (ctx, i) => _ProductCard(
                            product: items[i],
                            isFavorite: _favoriteIds.contains(items[i].id),
                            onToggleFavorite: () => _toggleFavorite(items[i].id),
                          ),
                        ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _openStateFilter() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: SafeArea(
            child: ListView(
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                ListTile(
                  title: const Text('كل المحافظات', style: TextStyle(fontWeight: FontWeight.bold)),
                  trailing: _selectedState == null ? const Icon(Icons.check, color: SouqnaColors.primary) : null,
                  onTap: () {
                    setState(() => _selectedState = null);
                    Navigator.of(ctx).pop();
                  },
                ),
                const Divider(height: 1),
                ...SudanStates.all.map((s) => ListTile(
                      title: Text(s),
                      trailing: _selectedState == s ? const Icon(Icons.check, color: SouqnaColors.primary) : null,
                      onTap: () {
                        setState(() => _selectedState = s);
                        Navigator.of(ctx).pop();
                      },
                    )),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              color: SouqnaColors.primary,
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: Colors.white,
                    child: Text(_initials, style: const TextStyle(color: SouqnaColors.primary, fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_displayName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14), overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 2),
                        Text(_email, style: const TextStyle(color: Colors.white70, fontSize: 11), textDirection: TextDirection.ltr, overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            ListTile(
              leading: const Icon(Icons.home_outlined, color: SouqnaColors.primary),
              title: const Text('الرئيسية'),
              onTap: () => Navigator.of(context).pop(),
            ),
            ListTile(
              leading: const Icon(Icons.favorite_border, color: SouqnaColors.primary),
              title: const Text('المفضلة'),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).push(MaterialPageRoute(builder: (_) => const FavoritesScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.chat_bubble_outline, color: SouqnaColors.primary),
              title: const Text('المحادثات'),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ConversationsScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.account_balance_wallet_outlined, color: SouqnaColors.primary),
              title: const Text('المحفظة وسجل العمليات'),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).push(MaterialPageRoute(builder: (_) => const WalletScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.credit_card_rounded, color: SouqnaColors.primary),
              title: const Text('الحسابات البنكية'),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).push(MaterialPageRoute(builder: (_) => const BankAccountsScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.person_outline, color: SouqnaColors.primary),
              title: const Text('الملف الشخصي والحساب'),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ProfileScreen()));
              },
            ),
            const Spacer(),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.logout_rounded, color: Colors.redAccent),
              title: const Text('تسجيل الخروج', style: TextStyle(color: Colors.redAccent)),
              onTap: _logout,
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final Product product;
  final bool isFavorite;
  final VoidCallback onToggleFavorite;
  const _ProductCard({required this.product, required this.isFavorite, required this.onToggleFavorite});

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
                Positioned(
                  top: 6,
                  left: 6,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: onToggleFavorite,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                        child: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          size: 18,
                          color: isFavorite ? SouqnaColors.accent : SouqnaColors.textMuted,
                        ),
                      ),
                    ),
                  ),
                ),
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
                  const SizedBox(height: 8),
                  const Divider(height: 1, color: SouqnaColors.border),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 9,
                            backgroundColor: SouqnaColors.surfaceLow,
                            child: Text(
                              product.sellerName.isNotEmpty ? product.sellerName.substring(0, 1) : 'س',
                              style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: SouqnaColors.primary),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(product.sellerName, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: SouqnaColors.textSecondary)),
                        ],
                      ),
                      Text(product.postedAgoLabel, style: const TextStyle(fontSize: 10, color: SouqnaColors.textMuted)),
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
