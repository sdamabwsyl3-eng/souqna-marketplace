enum TransactionType { deposit, withdrawal, escrowHold, escrowReleased }

class WalletTransaction {
  final String id;
  final String title;
  final double amount;
  final TransactionType type;
  final DateTime date;
  final String referenceNumber;
  final String status;

  WalletTransaction({
    required this.id,
    required this.title,
    required this.amount,
    required this.type,
    required this.date,
    required this.referenceNumber,
    required this.status,
  });

  static TransactionType _typeFromString(String? s) {
    switch (s) {
      case 'deposit':
        return TransactionType.deposit;
      case 'withdrawal':
        return TransactionType.withdrawal;
      case 'escrow_released':
        return TransactionType.escrowReleased;
      case 'escrow_hold':
      default:
        return TransactionType.escrowHold;
    }
  }

  /// يبني WalletTransaction من صف جدول wallet_transactions في Supabase.
  factory WalletTransaction.fromJson(Map<String, dynamic> j) {
    return WalletTransaction(
      id: j['id'] as String,
      title: j['title'] as String? ?? '',
      amount: (j['amount'] as num).toDouble(),
      type: _typeFromString(j['type'] as String?),
      date: DateTime.parse(j['created_at'] as String).toLocal(),
      referenceNumber: j['reference_number'] as String? ?? '',
      status: j['status'] as String? ?? '',
    );
  }
}
