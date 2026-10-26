class Conversation {
  final String id;
  final String productId;
  final String productTitle;
  final String productImage;
  final String otherUserId;
  final String otherUserName;
  final String lastMessage;
  final DateTime lastMessageAt;

  Conversation({
    required this.id,
    required this.productId,
    required this.productTitle,
    required this.productImage,
    required this.otherUserId,
    required this.otherUserName,
    required this.lastMessage,
    required this.lastMessageAt,
  });

  /// يبني Conversation من صف conversations بعد عمل join مع products وطرفي
  /// المحادثة (profiles) — يحدّد الطرف الآخر بالمقارنة مع المستخدم الحالي.
  factory Conversation.fromJson(Map<String, dynamic> j, String myUserId) {
    final product = j['product'] as Map<String, dynamic>?;
    final buyer = j['buyer'] as Map<String, dynamic>?;
    final seller = j['seller'] as Map<String, dynamic>?;
    final isBuyer = j['buyer_id'] == myUserId;
    final other = isBuyer ? seller : buyer;
    final otherName = (other?['full_name'] as String?)?.trim();
    final images = (product?['images'] as List<dynamic>? ?? const []).map((e) => e.toString()).toList();

    return Conversation(
      id: j['id'] as String,
      productId: j['product_id'] as String,
      productTitle: product?['title'] as String? ?? 'سلعة',
      productImage: images.isNotEmpty
          ? images.first
          : 'https://images.unsplash.com/photo-1472851294608-062f824d29cc?q=80&w=600&auto=format&fit=crop',
      otherUserId: isBuyer ? (j['seller_id'] as String) : (j['buyer_id'] as String),
      otherUserName: (otherName != null && otherName.isNotEmpty) ? otherName : 'مستخدم سوقنا',
      lastMessage: j['last_message'] as String? ?? '',
      lastMessageAt: DateTime.parse(j['last_message_at'] as String).toLocal(),
    );
  }
}

class ChatMessage {
  final String id;
  final String conversationId;
  final String senderId;
  final String text;
  final DateTime createdAt;

  ChatMessage({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.text,
    required this.createdAt,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> j) {
    return ChatMessage(
      id: j['id'] as String,
      conversationId: j['conversation_id'] as String,
      senderId: j['sender_id'] as String,
      text: j['text'] as String,
      createdAt: DateTime.parse(j['created_at'] as String).toLocal(),
    );
  }
}
