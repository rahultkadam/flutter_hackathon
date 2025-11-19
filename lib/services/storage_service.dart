import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_profile.dart';

class StorageService {
  static const String _userProfileKey = 'user_profile';

  Future<void> saveUserProfile(UserProfile profile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userProfileKey, jsonEncode(profile.toJson()));
  }

  Future<UserProfile?> getUserProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final profileJson = prefs.getString(_userProfileKey);

      if (profileJson != null) {
        final Map<String, dynamic> json = jsonDecode(profileJson);
        return UserProfile.fromJson(json);
      }
      return null;
    } catch (e) {
      print('Error loading user profile: $e');
      return null;
    }
  }

  Future<bool> hasUserProfile() async {
    final profile = await getUserProfile();
    return profile != null;
  }

  Future<void> clearUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userProfileKey);
  }
}
