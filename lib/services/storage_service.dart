import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/user_profile.dart';

class StorageService {
  static const String _userProfileKey = 'user_profile';

  Future<void> saveUserProfile(UserProfile profile) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _userProfileKey,
        jsonEncode(profile.toJson()),
      );
    } catch (e) {
      throw Exception('Failed to save profile: $e');
    }
  }

  Future<UserProfile?> getUserProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final profileJson = prefs.getString(_userProfileKey);

      if (profileJson != null) {
        return UserProfile.fromJson(jsonDecode(profileJson));
      }
      return null;
    } catch (e) {
      throw Exception('Failed to load profile: $e');
    }
  }

  Future<void> clearUserProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_userProfileKey);
    } catch (e) {
      throw Exception('Failed to clear profile: $e');
    }
  }

  Future<bool> hasUserProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.containsKey(_userProfileKey);
    } catch (e) {
      return false;
    }
  }
}
