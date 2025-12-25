import 'package:hive/hive.dart';

part 'user_profile.g.dart';

/// User profile data model
@HiveType(typeId: 10)
class UserProfile extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  String? email;

  @HiveField(2)
  String? avatarUrl;

  @HiveField(3)
  DateTime joinedDate;

  @HiveField(4)
  int totalFocusMinutes;

  @HiveField(5)
  int totalReflections;

  @HiveField(6)
  int currentStreak;

  @HiveField(7)
  int longestStreak;

  UserProfile({
    required this.name,
    this.email,
    this.avatarUrl,
    required this.joinedDate,
    this.totalFocusMinutes = 0,
    this.totalReflections = 0,
    this.currentStreak = 0,
    this.longestStreak = 0,
  });

  /// Create a default profile
  factory UserProfile.createDefault() {
    return UserProfile(
      name: 'Student',
      joinedDate: DateTime.now(),
    );
  }
}
