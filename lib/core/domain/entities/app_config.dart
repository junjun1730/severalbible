/// Global app configuration entity
///
/// Represents feature flags and global settings fetched from Supabase.
class AppConfig {
  final bool isFreeMode;
  final DateTime lastUpdated;

  const AppConfig({
    required this.isFreeMode,
    required this.lastUpdated,
  });

  factory AppConfig.fromJson(Map<String, dynamic> json) {
    return AppConfig(
      isFreeMode: json['isFreeMode'] as bool? ?? false,
      lastUpdated: json['lastUpdated'] != null
          ? DateTime.parse(json['lastUpdated'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'isFreeMode': isFreeMode,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  AppConfig copyWith({
    bool? isFreeMode,
    DateTime? lastUpdated,
  }) {
    return AppConfig(
      isFreeMode: isFreeMode ?? this.isFreeMode,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AppConfig &&
        other.isFreeMode == isFreeMode &&
        other.lastUpdated == lastUpdated;
  }

  @override
  int get hashCode => Object.hash(isFreeMode, lastUpdated);

  @override
  String toString() =>
      'AppConfig(isFreeMode: $isFreeMode, lastUpdated: $lastUpdated)';
}
