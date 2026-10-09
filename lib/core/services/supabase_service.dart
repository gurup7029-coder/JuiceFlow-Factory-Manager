import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../constants/app_constants.dart';

enum SyncStatus {
  online,
  offline,
  syncing,
  synced,
}

class SupabaseService {
  static final SupabaseService instance = SupabaseService._init();
  SupabaseService._init();

  bool _isInitialized = false;
  SyncStatus _syncStatus = SyncStatus.synced;

  SyncStatus get syncStatus => _syncStatus;
  bool get isInitialized => _isInitialized;

  SupabaseClient? get client {
    if (!_isInitialized) return null;
    try {
      return Supabase.instance.client;
    } catch (_) {
      return null;
    }
  }

  Future<void> initialize({String? customUrl, String? customKey}) async {
    final url = customUrl ?? AppConstants.defaultSupabaseUrl;
    final anonKey = customKey ?? AppConstants.defaultSupabaseAnonKey;

    try {
      // Initialize Supabase only if valid configuration is supplied
      if (url.startsWith('https://') && !url.contains('xyzcompany')) {
        await Supabase.initialize(
          url: url,
          anonKey: anonKey,
        );
        _isInitialized = true;
        _syncStatus = SyncStatus.synced;
      } else {
        // Standalone offline-first mode
        _isInitialized = false;
        _syncStatus = SyncStatus.offline;
      }
    } catch (e) {
      debugPrint('Supabase init notice (operating in offline-first mode): $e');
      _isInitialized = false;
      _syncStatus = SyncStatus.offline;
    }
  }

  void setSyncStatus(SyncStatus status) {
    _syncStatus = status;
  }
}
