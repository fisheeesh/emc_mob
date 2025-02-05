import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:emotion_check_in_app/utils/constants/text_strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/io_client.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class LoginProvider with ChangeNotifier {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _authToken;
  String? get authToken => _authToken;

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      /// **Allow self-signed certificates (ONLY FOR DEVELOPMENT)**
      HttpClient httpClient = HttpClient()
        ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
      IOClient ioClient = IOClient(httpClient);

      final response = await ioClient.post(
        Uri.parse(ETexts.LOGIN_ENDPOINT),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        // Extract tokens from headers
        String? authToken = response.headers['authorization'];
        String? refreshToken = response.headers['refresh'];

        if (authToken != null && refreshToken != null) {
          await _saveTokens(authToken, refreshToken);
          _authToken = authToken;
          _isLoading = false;
          notifyListeners();
          return true;
        }
      } else {
        debugPrint('Login failed: ${response.body}');
      }
    } on TimeoutException {
      debugPrint("Request Timeout: The server took too long to respond.");
    } on SocketException {
      debugPrint("Server Unreachable: Could not connect to the server.");
    } catch (e) {
      debugPrint('Login error: $e');
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  /// Save tokens securely in Flutter Secure Storage
  Future<void> _saveTokens(String authToken, String refreshToken) async {
    await _secureStorage.write(key: 'auth_token', value: authToken);
    await _secureStorage.write(key: 'refresh_token', value: refreshToken);
  }

  /// Get Refresh Token
  Future<String?> getRefreshToken() async {
    return await _secureStorage.read(key: 'refresh_token');
  }

  /// Check if token is valid
  bool isTokenValid(String? token) {
    if (token == null || token.isEmpty) return false;
    try {
      final cleanToken = token.startsWith('Bearer ') ? token.substring(7) : token;
      return !JwtDecoder.isExpired(cleanToken);
    } catch (e) {
      debugPrint("Invalid token: $e");
      return false;
    }
  }

  /// Restore session
  Future<bool> restoreSession() async {
    String? refreshToken = await getRefreshToken();
    return refreshToken != null && isTokenValid(refreshToken);
  }

  /// Logout and clear tokens
  Future<void> logout(BuildContext context) async {
    await _secureStorage.delete(key: 'auth_token');
    await _secureStorage.delete(key: 'refresh_token');
    _authToken = null;
    notifyListeners();
    Navigator.pushReplacementNamed(context, '/login');
  }
}