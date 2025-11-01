/// Represents a check-in entry with emotion data and timestamp.
///
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

  /// **Creates a `CheckIn` object from a JSON map.**
  ///
  /// - Parses the API response format with emoji, textFeeling, createdAt, checkInTime
  /// - Converts the createdAt timestamp to **local time** for consistency.
  ///
  /// **Throws:**
  /// - `FormatException` if the timestamp format is invalid.
  ///
  /// **Example Usage:**
  /// ```dart
  /// final checkIn = CheckIn.fromJson({
  ///   'emoji': '😏',
  ///   'textFeeling': 'Feeling pretty smug',
  ///   'createdAt': '2025-10-28T13:29:02.493Z',
  ///   'checkInTime': 'October 28, 2025 at 8:29 PM'
  /// });
  /// ```
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

  /// **Converts a `CheckIn` object to a JSON-compatible map.**
  ///
  /// - The createdAt timestamp is stored in **UTC format** (`ISO 8601`).
  ///
  /// **Example Output:**
  /// ```json
  /// {
  ///   "emoji": "😏",
  ///   "textFeeling": "Feeling pretty smug",
  ///   "createdAt": "2025-10-28T13:29:02.493Z",
  ///   "checkInTime": "October 28, 2025 at 8:29 PM"
  /// }
  /// ```
  Map<String, dynamic> toJson() {
    return {
      'emoji': emoji,
      'textFeeling': textFeeling,
      'createdAt': createdAt.toUtc().toIso8601String(),
      'checkInTime': checkInTime,
    };
  }

  /// **Returns a string representation of the `CheckIn` object.**
  ///
  /// Useful for debugging and logging.
  ///
  /// **Example Output:**
  /// ```
  /// CheckIn(Emoji: 😏, Time: 2025-10-28 19:00:00.000)
  /// ```
  @override
  String toString() {
    return 'CheckIn(Emoji: $emoji, Time: $createdAt)';
  }
}