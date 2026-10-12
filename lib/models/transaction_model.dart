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
}
