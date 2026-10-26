import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/conversation_model.dart';
import '../models/product_model.dart';
import '../services/supabase_data_service.dart';
import '../theme/app_colors.dart';
import 'checkout_screen.dart';

/// شاشة محادثة حقيقية مرتبطة بجدول conversations/messages في Supabase.
/// تُفتح إما من تفاصيل سلعة (ينشئ/يجلب المحادثة تلقائياً ويعرض زر الشراء
/// وعروض الأسعار السريعة)، أو من قائمة "المحادثات" مباشرة بمعرّف محادثة
/// جاهز (بدون كائن Product كامل، فلا يظهر زر الشراء في هذا المسار).
class ChatNegotiationScreen extends StatefulWidget {
  final Product? product;
  final String? conversationId;
  final String? productIdOverride;
  final String? productTitleOverride;
  final String? otherUserNameOverride;

  const ChatNegotiationScreen({super.key, required Product this.product})
      : conversationId = null,
        productIdOverride = null,
        productTitleOverride = null,
        otherUserNameOverride = null;

  const ChatNegotiationScreen.fromConversation({
    super.key,
    required String conversationId,
    required String productId,
    required String productTitle,
    required String otherUserName,
  })  : product = null,
        conversationId = conversationId,
        productIdOverride = productId,
        productTitleOverride = productTitle,
        otherUserNameOverride = otherUserName;

  @override
  State<ChatNegotiationScreen> createState() => _ChatNegotiationScreenState();
}

class _ChatNegotiationScreenState extends State<ChatNegotiationScreen> {
  final _controller = TextEditingController();
  final _scroll = ScrollController();

  String? _conversationId;
  List<ChatMessage> _messages = [];
  bool _loading = true;
  String? _error;
  bool _sending = false;

  String get _myUserId => Supabase.instance.client.auth.currentUser?.id ?? '';

  String get _headerName => widget.product?.sellerName ?? widget.otherUserNameOverride ?? 'محادثة';
  String get _headerSubtitle => widget.product?.title ?? widget.productTitleOverride ?? '';

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    try {
      String convoId;
      if (widget.conversationId != null) {
        convoId = widget.conversationId!;
      } else {
        final p = widget.product!;
        convoId = await SupabaseDataService.getOrCreateConversation(
          productId: p.id,
          sellerId: p.sellerId,
        );
      }
      final msgs = await SupabaseDataService.fetchMessages(convoId);
      if (!mounted) return;
      setState(() {
        _conversationId = convoId;
        _messages = msgs;
        _loading = false;
      });
      _scrollDown();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'تعذّر فتح المحادثة: $e';
        _loading = false;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _scrollDown() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(_scroll.position.maxScrollExtent + 80,
            duration: const Duration(milliseconds: 200), curve: Curves.easeOut);
      }
    });
  }

  Future<void> _send(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty || _conversationId == null || _sending) return;
    setState(() => _sending = true);
    _controller.clear();
    try {
      final msg = await SupabaseDataService.sendMessage(conversationId: _conversationId!, text: trimmed);
      if (!mounted) return;
      setState(() => _messages.add(msg));
      _scrollDown();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('تعذّر إرسال الرسالة: $e')));
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  void _offer(double pct) {
    final p = widget.product;
    if (p == null) return;
    final price = (p.price * pct).round();
    _send('عرض سعر: $price ج.س');
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.product;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Column(
            children: [
              Text(_headerName, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              if (_headerSubtitle.isNotEmpty)
                Text(_headerSubtitle, style: const TextStyle(fontSize: 10, color: SouqnaColors.textSecondary)),
            ],
          ),
          actions: [
            if (p != null)
              TextButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => CheckoutScreen(product: p)),
                ),
                child: const Text('شراء', style: TextStyle(color: SouqnaColors.accent, fontWeight: FontWeight.bold)),
              ),
          ],
        ),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? Center(child: Padding(padding: const EdgeInsets.all(24), child: Text(_error!, textAlign: TextAlign.center)))
                : Column(
                    children: [
                      Expanded(
                        child: _messages.isEmpty
                            ? const Center(child: Text('ابدأ المحادثة بإرسال رسالة', style: TextStyle(color: SouqnaColors.textMuted)))
                            : ListView.builder(
                                controller: _scroll,
                                padding: const EdgeInsets.all(16),
                                itemCount: _messages.length,
                                itemBuilder: (ctx, i) {
                                  final m = _messages[i];
                                  final mine = m.senderId == _myUserId;
                                  return Align(
                                    alignment: mine ? AlignmentDirectional.centerEnd : AlignmentDirectional.centerStart,
                                    child: Container(
                                      margin: const EdgeInsets.only(bottom: 8),
                                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                                      decoration: BoxDecoration(
                                        color: mine ? SouqnaColors.primary : Colors.white,
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(color: SouqnaColors.border),
                                      ),
                                      child: Text(
                                        m.text,
                                        style: TextStyle(
                                          fontSize: 13,
                                          height: 1.4,
                                          color: mine ? Colors.white : SouqnaColors.textPrimary,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ),
                      Container(
                        color: Colors.white,
                        padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
                        child: SafeArea(
                          top: false,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (p != null)
                                SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                    children: [
                                      for (final pct in [0.95, 0.9, 0.85])
                                        Padding(
                                          padding: const EdgeInsetsDirectional.only(end: 8),
                                          child: ActionChip(
                                            label: Text('عرض ${(p.price * pct).round()} ج.س', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                                            backgroundColor: SouqnaColors.surfaceLow,
                                            onPressed: () => _offer(pct),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              if (p != null) const SizedBox(height: 6),
                              Row(
                                children: [
                                  Expanded(
                                    child: TextField(
                                      controller: _controller,
                                      onSubmitted: _send,
                                      decoration: InputDecoration(
                                        hintText: 'اكتب رسالتك...',
                                        filled: true,
                                        fillColor: const Color(0xFFF1F5F9),
                                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  CircleAvatar(
                                    backgroundColor: SouqnaColors.accent,
                                    child: _sending
                                        ? const Padding(
                                            padding: EdgeInsets.all(8),
                                            child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
                                          )
                                        : IconButton(
                                            icon: const Icon(Icons.send_rounded, color: Colors.white, size: 18),
                                            onPressed: () => _send(_controller.text),
                                          ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
      ),
    );
  }
}
