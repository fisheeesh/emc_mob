import 'dart:convert';
import 'dart:io';
import 'package:emc_mob/enums/tokens.dart';
import 'package:emc_mob/utils/constants/urls.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class EmployeeService {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  Future<Map<String, dynamic>> getEmployeeData() async {
    try {
      /// Get tokens from secure storage
      final accessToken = await _secureStorage.read(key: ETokens.accessToken.name);
      final refreshToken = await _secureStorage.read(key: ETokens.refreshToken.name);

      if (accessToken == null) {
        throw Exception('No access token found');
      }

      final response = await http.get(
        Uri.parse(EUrls.EMP_DATA_ENDPOINT),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'x-refresh-token': refreshToken ?? '',
          'x-platform': 'mobile',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data;
      } else {
        throw Exception('Failed to load employee data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching employee data: $e');
    }
  }

  Future<Map<String, dynamic>> updateEmployeeData({
    required int id,
    required String firstName,
    required String lastName,
    required String phone,
    required String gender,
    required DateTime birthdate,
    File? avatarFile,
  }) async {
    try {
      final accessToken = await _secureStorage.read(key: ETokens.accessToken.name);
      final refreshToken = await _secureStorage.read(key: ETokens.refreshToken.name);

      if (accessToken == null) {
        throw Exception('No access token found');
      }

      /// Create multipart request
      var request = http.MultipartRequest(
        'PATCH',
        Uri.parse(EUrls.UPDATE_EMP_DATA_ENDPOINT),
      );

      request.headers.addAll({
        'Authorization': 'Bearer $accessToken',
        'x-refresh-token': refreshToken ?? '',
        'x-platform': 'mobile',
      });

      request.fields['id'] = id.toString();
      request.fields['firstName'] = firstName;
      request.fields['lastName'] = lastName;
      request.fields['phone'] = phone;
      request.fields['gender'] = gender;
      final birthdateUtc = DateTime.utc(
        birthdate.year,
        birthdate.month,
        birthdate.day,
      );
      request.fields['birthdate'] = birthdateUtc.toIso8601String();

      debugPrint('Sending birthdate: ${birthdateUtc.toIso8601String()}');

      /// Add avatar file if provided
      if (avatarFile != null) {
        var avatarStream = http.ByteStream(avatarFile.openRead());
        var avatarLength = await avatarFile.length();
        var multipartFile = http.MultipartFile(
          'avatar',
          avatarStream,
          avatarLength,
          filename: avatarFile.path.split('/').last,
        );
        request.files.add(multipartFile);
      }

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data;
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to update employee data');
      }
    } catch (e) {
      throw Exception('Error updating employee data: $e');
    }
  }
}