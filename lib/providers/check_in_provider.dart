import 'dart:convert';
import 'package:emc_mob/database/db_helper.dart';
import 'package:emc_mob/enums/tokens.dart';
import 'package:emc_mob/providers/login_provider.dart';
import 'package:emc_mob/utils/constants/status.dart';
import 'package:emc_mob/utils/constants/urls.dart';
import 'package:emc_mob/utils/helpers/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/check_in.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

/// **CheckInProvider** manages user check-in data, API requests, and local database storage.
///
/// This provider:
/// - Fetches check-ins from the server.
/// - Stores check-ins locally using SQLite.
/// - Sends new check-ins to the API.
/// - Backend handles token refresh automatically.
/// - Clears check-in data when the user logs out.
class CheckInProvider with ChangeNotifier {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  /// SQLite database helper instance for managing local storage.
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  List<CheckIn> _checkIns = [];
  List<CheckIn> get checkIns => _checkIns;

  /// **Makes an authorized HTTP request with the stored token.**
  ///
  /// Backend handles token refresh automatically via auth middleware.
  /// If tokens are rotated, they're returned in response headers.
  ///
  /// **Parameters:**
  /// - `context`: BuildContext for accessing LoginProvider
  /// - `method`: HTTP method (`"GET"` or `"POST"`).
  /// - `endpoint`: API endpoint URL.
  /// - `body`: Optional request body for `POST` requests.
  ///
  /// **Returns:**
  /// - `http.Response` if the request is successful.
  /// - `null` if authentication fails or an error occurs.
  Future<http.Response?> _makeAuthorizedRequest({
    required BuildContext context,
    required String method,
    required String endpoint,
    Map<String, dynamic>? body,
  }) async {
    String? accessToken =
    await _secureStorage.read(key: ETokens.accessToken.name);
    String? refreshToken =
    await _secureStorage.read(key: ETokens.refreshToken.name);

    if (accessToken == null || refreshToken == null) {
      debugPrint("No tokens found in storage.");
      return null;
    }

    // Remove "Bearer " prefix if exists
    accessToken = accessToken.trim();
    if (accessToken.startsWith("Bearer ")) {
      accessToken = accessToken.substring(7);
    }

    // Prepare request headers
    final headers = {
      "Authorization": "Bearer $accessToken",
      "Content-Type": "application/json",
      "x-platform": "mobile",
      "x-refresh-token": refreshToken,
    };

    final uri = Uri.parse(endpoint);
    http.Response response;

    try {
      if (method == "POST") {
        response = await http
            .post(uri, headers: headers, body: jsonEncode(body))
            .timeout(const Duration(seconds: 30));
      } else if (method == "GET") {
        response = await http
            .get(uri, headers: headers)
            .timeout(const Duration(seconds: 30));
      } else {
        debugPrint("Unsupported HTTP method: $method");
        return null;
      }

      // Check if backend rotated tokens (will be in response headers)
      if (context.mounted) {
        await context
            .read<LoginProvider>()
            .updateTokensFromHeaders(response.headers);
      }

      return response;
    } catch (e) {
      debugPrint("Error during HTTP request: $e");
      return null;
    }
  }

  /// **Fetches check-ins from the API after login.**
  ///
  /// - Retrieves check-ins from the server.
  /// - Backend returns: { message: string, data: array }
  /// - Saves them to SQLite for offline access.
  Future<void> fetchCheckIns() async {
    debugPrint("fetchCheckIns called - waiting for context");
  }

  /// **Fetches check-ins with BuildContext**
  Future<void> fetchCheckInsWithContext(BuildContext context) async {
    final endpoint = EHelperFunctions.isIOS()
        ? EUrls.HISTORY_ENDPOINT_IOS
        : EUrls.HISTORY_ENDPOINT_ANDROID;

    final response = await _makeAuthorizedRequest(
      context: context,
      method: "GET",
      endpoint: endpoint,
    );

    if (response != null && response.statusCode == 200) {
      try {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);

        // Backend returns: { message: "...", data: [...] }
        final List<dynamic> data = jsonResponse['data'] ?? [];

        _checkIns = data.map((item) => CheckIn.fromJson(item)).toList();

        // Save Check-Ins to SQLite
        await _dbHelper.clearCheckIns();
        for (var checkIn in _checkIns) {
          await _dbHelper.insertCheckIn(checkIn);
        }

        debugPrint("Check-ins saved to SQLite: ${_checkIns.length} items");
        notifyListeners();
      } catch (e) {
        debugPrint("Error parsing check-ins: $e");
      }
    } else {
      debugPrint("Failed to fetch check-ins: ${response?.statusCode} ${response?.body}");
    }
  }

  /// **Load Check-Ins From SQLite for Home Screen**
  Future<void> loadCheckInsFromDB() async {
    _checkIns = await _dbHelper.getCheckIns();
    notifyListeners();
  }

  /// **Submits a new check-in to the API.**
  ///
  /// - Sends check-in with format: emoji(I'm label) // textFeeling
  /// - Backend expects: { moodMessage: "😊(I'm happy) // I feel great today." }
  /// - Stores the check-in in SQLite for offline access.
  ///
  /// **Parameters:**
  /// - `context`: The current `BuildContext`.
  /// - `emoji`: The emoji representing the mood.
  /// - `label`: The label representing the mood (e.g., "happy", "sad").
  /// - `feelingText`: The text description of the mood.
  Future<bool> sendCheckIn(
      BuildContext context,
      String emoji,
      String label,
      String feelingText,
      ) async {
    String moodMessage = "$emoji(I'm $label) // $feelingText";

    final endpoint = EHelperFunctions.isIOS()
        ? EUrls.CHECK_IN_ENDPOINT_IOS
        : EUrls.CHECK_IN_ENDPOINT_ANDROID;

    final response = await _makeAuthorizedRequest(
      context: context,
      method: "POST",
      endpoint: endpoint,
      body: {"moodMessage": moodMessage},
    );

    if (response != null && response.statusCode == 200) {
      final now = DateTime.now();
      String checkInTime = EHelperFunctions.getFormattedDate(now, 'MMMM d, yyyy \'at\' h:mm a');

      final checkIn = CheckIn(
        emoji: emoji,
        textFeeling: feelingText,
        createdAt: now,
        checkInTime: checkInTime,
      );

      // Save Check-In to SQLite
      _checkIns.add(checkIn);
      await _dbHelper.insertCheckIn(checkIn);

      notifyListeners();
      debugPrint("Check-in saved locally: $emoji (I'm $label)");
      return true;
    } else {
      debugPrint("Failed to send check-in: ${response?.statusCode} ${response?.body}");
      if (context.mounted) {
        EHelperFunctions.showSnackBar(context, EStatus.COMMON_ERROR);
      }
      return false;
    }
  }

  /// **Clears all stored check-in data after Logout.**
  Future<void> clearData() async {
    await _dbHelper.clearCheckIns();
    _checkIns.clear();
    notifyListeners();
  }

  /// **Retrieves a check-in for a specific date.**
  ///
  /// **Returns:** A `CheckIn` object if found, otherwise `null`.
  CheckIn? getCheckInByDate(DateTime date) {
    return _checkIns.cast<CheckIn?>().firstWhere(
          (checkIn) =>
      checkIn!.createdAt.day == date.day &&
          checkIn.createdAt.month == date.month &&
          checkIn.createdAt.year == date.year,
      orElse: () => null,
    );
  }

  /// **Retrieves today's check-in.**
  ///
  /// **Returns:** The `CheckIn` object if found, otherwise `null`.
  CheckIn? get todayCheckIn {
    final today = DateTime.now();
    return _checkIns.cast<CheckIn?>().firstWhere(
          (checkIn) =>
      checkIn!.createdAt.day == today.day &&
          checkIn.createdAt.month == today.month &&
          checkIn.createdAt.year == today.year,
      orElse: () => null,
    );
  }
}