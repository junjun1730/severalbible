/// User subscription tier levels
enum UserTier {
  guest,
  member,
  premium;

  /// Convert string to UserTier
  static UserTier fromString(String value) {
    return UserTier.values.firstWhere(
      (tier) => tier.name == value,
      orElse: () => UserTier.guest,
    );
  }
}
