class UserProgress {
  const UserProgress({
    required this.gems,
    required this.totalFocusSeconds,
    required this.profileName,
  });

  static const int maxProfileNameLength = 8;
  static const String defaultProfileName = 'NOMBRE';

  final int gems;
  final int totalFocusSeconds;
  final String profileName;

  static String normalizeProfileName(String value) {
    final trimmedName = value.trim();
    if (trimmedName.isEmpty) {
      return defaultProfileName;
    }

    return String.fromCharCodes(trimmedName.runes.take(maxProfileNameLength));
  }

  UserProgress copyWith({
    int? gems,
    int? totalFocusSeconds,
    String? profileName,
  }) {
    return UserProgress(
      gems: gems ?? this.gems,
      totalFocusSeconds: totalFocusSeconds ?? this.totalFocusSeconds,
      profileName: profileName ?? this.profileName,
    );
  }

  static const empty = UserProgress(
    gems: 0,
    totalFocusSeconds: 0,
    profileName: defaultProfileName,
  );
}
