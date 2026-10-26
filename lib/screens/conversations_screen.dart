import 'package:flutter/material.dart';
import '../models/conversation_model.dart';
import '../services/supabase_data_service.dart';
import '../theme/app_colors.dart';
import 'chat_negotiation_screen.dart';

/// تبويب "المحادثات" — كل محادثاتي كمشترٍ أو بائع، الأحدث أولاً.
class ConversationsScreen extends StatefulWidget {
  const ConversationsScreen({super.key});

  @override
  State<ConversationsScreen> createState() => _ConversationsScreenState();
}

class _ConversationsScreenState extends State<ConversationsScreen> {
  late Future<List<Conversation>> _future;

  @override
  void initState() {
    super.initState();
    _future = SupabaseDataService.fetchMyConversations();
  }

  Future<void> _refresh() async {
    final future = SupabaseDataService.fetchMyConversations();
    setState(() => _future = future);
    await future;
  }

  String _timeLabel(DateTime t) {
    final diff = DateTime.now().difference(t);
    if (diff.inMinutes < 60) return diff.inMinutes <= 1 ? 'الآن' : 'قبل ${diff.inMinutes} د';
    if (diff.inHours < 24) return 'قبل ${diff.inHours} س';
    if (diff.inDays < 7) return diff.inDays == 1 ? 'أمس' : 'قبل ${diff.inDays} أيام';
    return '${t.year}/${t.month.toString().padLeft(2, '0')}/${t.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: SouqnaColors.surface,
        appBar: AppBar(title: const Text('المحادثات')),
        body: FutureBuilder<List<Conversation>>(
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
                        Icon(Icons.chat_bubble_outline, size: 48, color: SouqnaColors.textMuted),
                        SizedBox(height: 10),
                        Center(child: Text('لا توجد محادثات بعد', style: TextStyle(color: SouqnaColors.textMuted))),
                      ],
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(12, 10, 12, 90),
                      itemCount: items.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (ctx, i) {
                        final c = items[i];
                        return ListTile(
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.network(
                              c.productImage,
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                width: 50,
                                height: 50,
                                color: SouqnaColors.surfaceLow,
                                child: const Icon(Icons.image_not_supported_outlined, color: SouqnaColors.textMuted, size: 18),
                              ),
                            ),
                          ),
                          title: Text(c.otherUserName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          subtitle: Text(
                            c.lastMessage.isEmpty ? c.productTitle : c.lastMessage,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 12, color: SouqnaColors.textSecondary),
                          ),
                          trailing: Text(_timeLabel(c.lastMessageAt), style: const TextStyle(fontSize: 10, color: SouqnaColors.textMuted)),
                          onTap: () async {
                            await Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => ChatNegotiationScreen.fromConversation(
                                  conversationId: c.id,
                                  productId: c.productId,
                                  productTitle: c.productTitle,
                                  otherUserName: c.otherUserName,
                                ),
                              ),
                            );
                            _refresh();
                          },
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
