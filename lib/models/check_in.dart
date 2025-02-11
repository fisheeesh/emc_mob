/// Represents a check-in entry with a timestamp.
///
/// This model is used to store and retrieve check-in records from
/// both the API and local SQLite database.
class CheckIn {
  /// The timestamp of the check-in.
  final DateTime timestamp;

  CheckIn({required this.timestamp});

  /// **Creates a `CheckIn` object from a JSON map.**
  ///
  /// - Parses the `timestamp` string into a `DateTime` object.
  /// - Converts the timestamp to **local time** for consistency.
  ///
  /// **Throws:**
  /// - `FormatException` if the timestamp format is invalid.
  ///
  /// **Example Usage:**
  /// ```dart
  /// final checkIn = CheckIn.fromJson({'timestamp': '2025-02-10T12:00:00Z'});
  /// ```
  factory CheckIn.fromJson(Map<String, dynamic> json) {
    try {
      String timestampStr = json['timestamp'] ?? '';
      DateTime dateTime = DateTime.parse(timestampStr).toLocal();

      return CheckIn(timestamp: dateTime);
    } catch (e) {
      throw FormatException("Invalid timestamp format: ${json['timestamp']}");
    }
  }

  /// **Converts a `CheckIn` object to a JSON-compatible map.**
  ///
  /// - The timestamp is stored in **UTC format** (`ISO 8601`).
  ///
  /// **Example Output:**
  /// ```json
  /// { "timestamp": "2025-02-10T12:00:00Z" }
  /// ```
  Map<String, dynamic> toJson() {
    return {
      'timestamp': timestamp.toUtc().toIso8601String(),
    };
  }

  /// **Returns a string representation of the `CheckIn` object.**
  ///
  /// Useful for debugging and logging.
  ///
  /// **Example Output:**
  /// ```
  /// CheckIn(Timestamp: 2025-02-10 19:00:00.000)
  /// ```
  @override
  String toString() {
    return 'CheckIn(Timestamp: $timestamp)';
  }
}
