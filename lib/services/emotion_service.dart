import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:emc_mob/models/emotion_model.dart';
import 'package:emc_mob/utils/constants/urls.dart';

class EmotionService {
  static const String _cacheKey = 'emotion_categories_cache';
  static const String _cacheTimeKey = 'emotion_categories_cache_time';
  static const Duration _cacheDuration = Duration(hours: 24);

  /// Hardcoded fallback data
  static final List<EmotionCategory> _fallbackCategories = [
    EmotionCategory(
      title: 'Negative',
      emotions: [
        Emotion(icon: '😓', label: 'tired'),
        Emotion(icon: '😩', label: 'stressed'),
        Emotion(icon: '😴', label: 'bored'),
        Emotion(icon: '😡', label: 'frustrated'),
        Emotion(icon: '😞', label: 'disappointed'),
        Emotion(icon: '😭', label: 'sad'),
        Emotion(icon: '😰', label: 'anxious'),
        Emotion(icon: '😒', label: 'annoyed'),
        Emotion(icon: '😠', label: 'mad'),
      ],
    ),
    EmotionCategory(
      title: 'Neutral',
      emotions: [
        Emotion(icon: '😐', label: 'neutral'),
        Emotion(icon: '😌', label: 'calm'),
        Emotion(icon: '😑', label: 'meh'),
        Emotion(icon: '😶', label: 'indifferent'),
        Emotion(icon: '🙂', label: 'okay'),
        Emotion(icon: '😕', label: 'unsure'),
        Emotion(icon: '🤔', label: 'curious'),
        Emotion(icon: '🙃', label: 'playful'),
        Emotion(icon: '🫤', label: 'uncertain'),
      ],
    ),
    EmotionCategory(
      title: 'Positive',
      emotions: [
        Emotion(icon: '😀', label: 'happy'),
        Emotion(icon: '😄', label: 'excited'),
        Emotion(icon: '😍', label: 'loved'),
        Emotion(icon: '😁', label: 'joyful'),
        Emotion(icon: '🥳', label: 'celebratory'),
        Emotion(icon: '😎', label: 'confident'),
        Emotion(icon: '😊', label: 'grateful'),
        Emotion(icon: '🤩', label: 'thrilled'),
        Emotion(icon: '😇', label: 'peaceful'),
      ],
    ),
  ];

  /// Get emotions from cache or fallback -> instant - no API call
  static Future<List<EmotionCategory>> getEmotionsInstant() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedData = prefs.getString(_cacheKey);

      if (cachedData != null) {
        final List<dynamic> jsonList = json.decode(cachedData);
        return jsonList.map((json) => EmotionCategory.fromJson(json)).toList();
      }
    } catch (e) {
      print('Error loading cached emotions: $e');
    }

    /// Return fallback if no cache
    return _fallbackCategories;
  }

  /// Fetch from API and update cache -> background operation
  static Future<void> syncEmotionsInBackground(String accessToken) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      /// Check if cache is still fresh
      final cacheTimeStr = prefs.getString(_cacheTimeKey);
      if (cacheTimeStr != null) {
        final cacheTime = DateTime.parse(cacheTimeStr);
        if (DateTime.now().difference(cacheTime) < _cacheDuration) {
          print('Cache is still fresh, skipping sync');
          return;
        }
      }

      final response = await http.get(
        Uri.parse(EUrls.EMOTION_CATEGORIES_ENDPOINT),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
          'x-platform': 'mobile',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> categories = data['data'];

        /// Save to cache
        await prefs.setString(_cacheKey, json.encode(categories));
        await prefs.setString(_cacheTimeKey, DateTime.now().toIso8601String());

        print('Emotions synced successfully');
      } else {
        print('Failed to fetch emotions: ${response.statusCode}');
      }
    } catch (e) {
      print('Error syncing emotions: $e');
    }
  }

  static Future<List<EmotionCategory>> forceRefresh(String accessToken) async {
    try {
      final response = await http.get(
        Uri.parse(EUrls.EMOTION_CATEGORIES_ENDPOINT),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
          'x-platform': 'mobile',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> categories = data['data'];

        /// Save to cache
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_cacheKey, json.encode(categories));
        await prefs.setString(_cacheTimeKey, DateTime.now().toIso8601String());

        return categories.map((json) => EmotionCategory.fromJson(json)).toList();
      }
    } catch (e) {
      print('Error force refreshing emotions: $e');
    }

    return await getEmotionsInstant();
  }

  static Future<void> clearCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_cacheKey);
    await prefs.remove(_cacheTimeKey);
  }
}