import 'package:shared_preferences/shared_preferences.dart';
import 'contains.dart';

class AppPref {
  static late SharedPreferences preferences;

  /// Initialize SharedPreferences instance
  static Future<void> init() async {
    preferences = await SharedPreferences.getInstance();
  }

  // ✅ Set token in SharedPreferences
  static Future<void> setToken(String token) async {
    await preferences.setString(Constrains.TOKEN, token);
  }

  // ✅ Get token from SharedPreferences
  static String? getToken() {
    return preferences.getString(Constrains.TOKEN);
  }

  // ✅ Set refresh token in SharedPreferences
  static Future<void> setRefreshToken(String refreshToken) async {
    await preferences.setString(Constrains.REFRESH_TOKEN, refreshToken);
  }

  // ✅ Get refresh token from SharedPreferences
  static String? getRefreshToken() {
    return preferences.getString(Constrains.REFRESH_TOKEN);
  }

  // ✅ Set login status in SharedPreferences
  static Future<void> setLogin() async {
    await preferences.setBool(Constrains.LOGIN, true);
  }

  // ✅ Get login status from SharedPreferences
  static bool isLoggedIn() {
    return preferences.getBool(Constrains.LOGIN) ?? false;
  }

  // ✅ Set language preference in SharedPreferences
  static Future<void> setLanguage(String language) async {
    await preferences.setString(Constrains.LANGUAGE, language);
  }

  // ✅ Get language preference from SharedPreferences
  static String? getLanguage() {
    return preferences.getString(Constrains.LANGUAGE);
  }

  // ✅ Clear ALL data (token, login, and any other user data)
  static Future<void> clearAllData() async {
    await preferences.remove(Constrains.TOKEN);
    await preferences.remove(Constrains.REFRESH_TOKEN);
    await preferences.remove(Constrains.LOGIN);
  }

  // ✅ Get DeviceId from AppPref class
  static String? getDeviceId() {
    return preferences.getString('deviceId');
  }

  // ✅ Get DeviceName from AppPref class
  static String? getDeviceName() {
    return preferences.getString('deviceName');
  }

  // ✅ Set DeviceInfo in AppPref class
  static Future<void> setDeviceInfo(String deviceId, String deviceName) async {
    await preferences.setString('deviceId', deviceId);
    await preferences.setString('deviceName', deviceName);
  }
}
