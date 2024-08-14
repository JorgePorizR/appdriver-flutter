import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

class DataStorage {
  final SharedPreferences prefs;
  DataStorage(this.prefs);

  static Future<void> saveToken(String key, String title) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, title);
  }

  static Future<String> loadToken(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(key) ?? '';
  }

  static Future<void> deleteToken(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(key);
  }

  static Future<void> saveChoferId(String key, String choferId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, choferId);
  }

  static Future<String> loadChoferId(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(key) ?? '';
  }

  static Future<void> deleteChoferId(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(key);
  }
}
