import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/api_service.dart';

// Settings state
class SettingsState {
  final ThemeMode themeMode;
  final String apiSource;

  SettingsState({required this.themeMode, required this.apiSource});

  SettingsState copyWith({ThemeMode? themeMode, String? apiSource}) {
    return SettingsState(
      themeMode: themeMode ?? this.themeMode,
      apiSource: apiSource ?? this.apiSource,
    );
  }
}

class SettingsNotifier extends StateNotifier<SettingsState> {
  SettingsNotifier() : super(SettingsState(themeMode: ThemeMode.light, apiSource: 'themealdb')) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool('isDark') ?? false;
    final source = prefs.getString('apiSource') ?? 'themealdb';
    state = SettingsState(
      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
      apiSource: source,
    );
  }

  Future<void> toggleTheme() async {
    final isDark = state.themeMode == ThemeMode.dark;
    final newMode = isDark ? ThemeMode.light : ThemeMode.dark;
    state = state.copyWith(themeMode: newMode);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDark', !isDark);
  }

  Future<void> setApiSource(String source) async {
    state = state.copyWith(apiSource: source);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('apiSource', source);
  }
}

final settingsProvider = StateNotifierProvider<SettingsNotifier, SettingsState>((ref) {
  return SettingsNotifier();
});

// API Service provider based on current setting
final apiServiceProvider = Provider<ApiService>((ref) {
  final settings = ref.watch(settingsProvider);
  if (settings.apiSource == 'dummyjson') {
    return DummyJSONService();
  }
  return TheMealDBService();
});
