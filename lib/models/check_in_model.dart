/// This model is used to store and retrieve check-in records from
/// both the API and local SQLite database.
class CheckIn {
  final String emoji;
  final String textFeeling;
  final DateTime createdAt;
  final String checkInTime;

  CheckIn({
    required this.emoji,
    required this.textFeeling,
    required this.createdAt,
    required this.checkInTime,
  });

  factory CheckIn.fromJson(Map<String, dynamic> json) {
    try {
      String createdAtStr = json['createdAt'] ?? '';
      DateTime dateTime = DateTime.parse(createdAtStr).toLocal();

      return CheckIn(
        emoji: json['emoji'] ?? '',
        textFeeling: json['textFeeling'] ?? '',
        createdAt: dateTime,
        checkInTime: json['checkInTime'] ?? '',
      );
    } catch (e) {
      throw FormatException("Invalid check-in format: $e");
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'emoji': emoji,
      'textFeeling': textFeeling,
      'createdAt': createdAt.toUtc().toIso8601String(),
      'checkInTime': checkInTime,
    };
  }

  @override
  String toString() {
    return 'CheckIn(Emoji: $emoji, Time: $createdAt)';
  }
}