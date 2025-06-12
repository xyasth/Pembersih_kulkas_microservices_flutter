import 'package:flutter/foundation.dart';
import '../models/profile_model.dart';
import '../services/profile_service.dart';


class ProfileViewModel extends ChangeNotifier {
  List<ProfileModel> _profiles = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  List<ProfileModel> get profiles => _profiles;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Load profiles from API Gateway
  Future<void> loadProfiles() async {
    _setLoading(true);
    _error = null;
    
    try {
      print('🔄 Loading profiles...');
      
      // Test connection first
      final isConnected = await ProfileService.testConnection();
      if (!isConnected) {
        throw Exception('Cannot connect to API Gateway. Please check if the server is running on http://localhost:8000');
      }
      
      // Load profiles
      _profiles = await ProfileService.getProfiles();
      
      print('✅ Profiles loaded successfully: ${_profiles.length} profiles');
      
    } catch (e) {
      print('❌ Error loading profiles: $e');
      _error = e.toString();
      _profiles = [];
    } finally {
      _setLoading(false);
    }
  }

  /// Refresh profiles
  Future<void> refreshProfiles() async {
    await loadProfiles();
  }

  /// Debug: Test all services
  // Future<void> debugServices() async {
  //   try {
  //     final debug = await ProfileService.debugServices();
  //     print('🔍 Debug services result: $debug');
  //   } catch (e) {
  //     print('❌ Debug services error: $e');
  //   }
  // }

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Private helper to set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}