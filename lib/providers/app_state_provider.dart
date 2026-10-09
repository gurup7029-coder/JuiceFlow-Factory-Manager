import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/app_constants.dart';
import '../models/factory_profile.dart';

class AppStateProvider extends ChangeNotifier {
  Locale _locale = const Locale('en');
  ThemeMode _themeMode = ThemeMode.light;
  String _currentRole = AppConstants.roleAdmin;
  String _currentUserName = 'Ramasamy Kumar';
  bool _isLoggedIn = true;
  FactoryProfile _factoryProfile = FactoryProfile();

  Locale get locale => _locale;
  ThemeMode get themeMode => _themeMode;
  String get currentRole => _currentRole;
  String get currentUserName => _currentUserName;
  bool get isLoggedIn => _isLoggedIn;
  FactoryProfile get factoryProfile => _factoryProfile;

  AppStateProvider() {
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final langCode = prefs.getString('language_code');
    if (langCode != null) {
      _locale = Locale(langCode);
    }
    final themeStr = prefs.getString('theme_mode');
    if (themeStr == 'dark') {
      _themeMode = ThemeMode.dark;
    } else if (themeStr == 'light') {
      _themeMode = ThemeMode.light;
    } else if (themeStr == 'system') {
      _themeMode = ThemeMode.system;
    }

    final savedRole = prefs.getString('current_role');
    if (savedRole != null && AppConstants.allRoles.contains(savedRole)) {
      _currentRole = savedRole;
    }

    notifyListeners();
  }

  Future<void> setLocale(Locale newLocale) async {
    if (_locale == newLocale) return;
    _locale = newLocale;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language_code', newLocale.languageCode);
  }

  Future<void> toggleLanguage() async {
    if (_locale.languageCode == 'en') {
      await setLocale(const Locale('ta'));
    } else {
      await setLocale(const Locale('en'));
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    if (mode == ThemeMode.dark) {
      await prefs.setString('theme_mode', 'dark');
    } else if (mode == ThemeMode.light) {
      await prefs.setString('theme_mode', 'light');
    } else {
      await prefs.setString('theme_mode', 'system');
    }
  }

  Future<void> setCurrentRole(String role) async {
    _currentRole = role;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('current_role', role);
  }

  void updateFactoryProfile(FactoryProfile profile) {
    _factoryProfile = profile;
    notifyListeners();
  }

  void login(String userName, String role) {
    _currentUserName = userName;
    _currentRole = role;
    _isLoggedIn = true;
    notifyListeners();
  }

  void logout() {
    _isLoggedIn = false;
    notifyListeners();
  }
}
