import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../services/supabase_data_service.dart';
import '../theme/app_colors.dart';
import 'product_details_screen.dart';

/// تبويب "المفضلة" — السلع التي أضافها المستخدم الحالي بأيقونة القلب.
class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  late Future<List<Product>> _future;

  @override
  void initState() {
    super.initState();
    _future = SupabaseDataService.fetchMyFavoriteProducts();
  }

  Future<void> _refresh() async {
    final future = SupabaseDataService.fetchMyFavoriteProducts();
    setState(() => _future = future);
    await future;
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: SouqnaColors.surface,
        appBar: AppBar(title: const Text('المفضلة')),
        body: FutureBuilder<List<Product>>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            final items = snapshot.data ?? const [];
            return RefreshIndicator(
              onRefresh: _refresh,
              child: items.isEmpty
                  ? ListView(
                      children: const [
                        SizedBox(height: 120),
                        Icon(Icons.favorite_border, size: 48, color: SouqnaColors.textMuted),
                        SizedBox(height: 10),
                        Center(child: Text('لا توجد سلع مفضّلة بعد', style: TextStyle(color: SouqnaColors.textMuted))),
                      ],
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
                      itemCount: items.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 14),
                      itemBuilder: (ctx, i) {
                        final p = items[i];
                        return InkWell(
                          borderRadius: BorderRadius.circular(18),
                          onTap: () async {
                            await Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => ProductDetailsScreen(product: p)),
                            );
                            _refresh();
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(color: SouqnaColors.border),
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 100,
                                  height: 90,
                                  child: Image.network(
                                    p.images.first,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => Container(
                                      color: SouqnaColors.surfaceLow,
                                      child: const Icon(Icons.image_not_supported_outlined, color: SouqnaColors.textMuted),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(p.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
                                        const SizedBox(height: 4),
                                        Text(p.city, style: const TextStyle(fontSize: 11, color: SouqnaColors.textSecondary)),
                                        const SizedBox(height: 6),
                                        Text('${p.price.toStringAsFixed(0)} ج.س',
                                            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: SouqnaColors.primary)),
                                      ],
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 8),
                                  child: IconButton(
                                    icon: const Icon(Icons.favorite, color: SouqnaColors.accent),
                                    onPressed: () async {
                                      await SupabaseDataService.toggleFavorite(p.id);
                                      _refresh();
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            );
          },
        ),
      ),
    );
  }
}
