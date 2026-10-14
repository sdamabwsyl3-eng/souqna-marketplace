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

  /// يبني UserProfile من صف جدول profiles في Supabase.
  factory UserProfile.fromJson(Map<String, dynamic> j) {
    return UserProfile(
      fullName: j['full_name'] as String? ?? '',
      nationalIdMasked: '',
      rating: (j['rating'] as num?)?.toDouble() ?? 5.0,
      successfulDealsCount: j['successful_deals_count'] as int? ?? 0,
      walletBalance: (j['wallet_balance'] as num?)?.toDouble() ?? 0,
      escrowBalance: (j['escrow_balance'] as num?)?.toDouble() ?? 0,
    );
  }
}
