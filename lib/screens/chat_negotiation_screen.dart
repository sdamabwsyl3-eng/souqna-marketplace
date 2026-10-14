import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../theme/app_colors.dart';
import 'checkout_screen.dart';

class _Msg {
  final String text;
  final bool mine;
  final bool isOffer;
  _Msg(this.text, {required this.mine, this.isOffer = false});
}

class ChatNegotiationScreen extends StatefulWidget {
  final Product product;
  const ChatNegotiationScreen({super.key, required this.product});

  @override
  State<ChatNegotiationScreen> createState() => _ChatNegotiationScreenState();
}

class _ChatNegotiationScreenState extends State<ChatNegotiationScreen> {
  final _controller = TextEditingController();
  final _scroll = ScrollController();
  late final List<_Msg> _messages;

  @override
  void initState() {
    super.initState();
    _messages = [
      _Msg('السلام عليكم، هل السلعة ما زالت متوفرة؟', mine: true),
      _Msg('وعليكم السلام، نعم متوفرة.', mine: false),
    ];
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

  void _send(String text, {bool isOffer = false}) {
    if (text.trim().isEmpty) return;
    setState(() => _messages.add(_Msg(text.trim(), mine: true, isOffer: isOffer)));
    _controller.clear();
    _scrollDown();

    // رد تجريبي من البائع
    Future.delayed(const Duration(milliseconds: 900), () {
      if (!mounted) return;
      setState(() => _messages.add(_Msg(
            isOffer ? 'تم قبول عرضك، يمكنك إتمام الشراء بضمان سوقنا.' : 'تمام، أرسل لي عرضك.',
            mine: false,
          )));
      _scrollDown();
    });
  }

  void _offer(double pct) {
    final price = (widget.product.price * pct).round();
    _send('عرض سعر: $price ج.س', isOffer: true);
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
              Text(p.sellerName, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              Text(p.title, style: const TextStyle(fontSize: 10, color: SouqnaColors.textSecondary)),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => CheckoutScreen(product: p)),
              ),
              child: const Text('شراء', style: TextStyle(color: SouqnaColors.accent, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: ListView.builder(
                controller: _scroll,
                padding: const EdgeInsets.all(16),
                itemCount: _messages.length,
                itemBuilder: (ctx, i) {
                  final m = _messages[i];
                  return Align(
                    alignment: m.mine ? AlignmentDirectional.centerStart : AlignmentDirectional.centerEnd,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                      decoration: BoxDecoration(
                        color: m.isOffer
                            ? SouqnaColors.successLight
                            : m.mine
                                ? SouqnaColors.primary
                                : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: m.isOffer ? SouqnaColors.successBorder : SouqnaColors.border),
                      ),
                      child: Text(
                        m.text,
                        style: TextStyle(
                          fontSize: 13,
                          height: 1.4,
                          fontWeight: m.isOffer ? FontWeight.bold : FontWeight.normal,
                          color: m.isOffer
                              ? const Color(0xFF065F46)
                              : m.mine
                                  ? Colors.white
                                  : SouqnaColors.textPrimary,
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
                    const SizedBox(height: 6),
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
                          child: IconButton(
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
