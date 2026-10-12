class UserProfile {
  final String fullName;
  final String nationalIdMasked;
  final bool isNafathVerified;
  final double rating;
  final int successfulDealsCount;
  final double walletBalance;
  final double escrowBalance;

  UserProfile({
    required this.fullName,
    required this.nationalIdMasked,
    this.isNafathVerified = true,
    required this.rating,
    required this.successfulDealsCount,
    required this.walletBalance,
    required this.escrowBalance,
  });
}
