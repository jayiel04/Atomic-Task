class UserProgress {
  const UserProgress({
    required this.gems,
    required this.totalFocusSeconds,
    required this.profileName,
  });

  final int gems;
  final int totalFocusSeconds;
  final String profileName;

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
    profileName: 'NOMBRE',
  );
}
