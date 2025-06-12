// viewmodels/profile_viewmodel.dart
import 'package:flutter/material.dart';
import '../models/profile_model.dart';
import '../services/profile_service.dart';

class ProfileViewModel extends ChangeNotifier {
  final ProfileService _profileService = ProfileService();

  // Controllers for form fields
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController searchController = TextEditingController();

  // State variables
  List<Profile> _profiles = [];
  Profile? _currentProfile;
  bool _isLoading = false;
  String? _error;

  // Getters
  List<Profile> get profiles => _profiles;
  Profile? get currentProfile => _currentProfile;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Set error state
  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Load all profiles
  Future<void> loadProfiles() async {
    _setLoading(true);
    _setError(null);

    try {
      _profiles = await _profileService.getAllProfiles();
      if (_profiles.isNotEmpty) {
        _currentProfile = _profiles.first;
      }
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Load specific profile by ID
  Future<void> loadProfile(int id) async {
    _setLoading(true);
    _setError(null);

    try {
      _currentProfile = await _profileService.getProfile(id);
      // Update form controllers with current profile data
      nameController.text = _currentProfile!.name;
      emailController.text = _currentProfile!.email;
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Create new profile
  Future<bool> createProfile() async {
    if (nameController.text.trim().isEmpty ||
        emailController.text.trim().isEmpty) {
      _setError('Name and email are required');
      return false;
    }

    if (!_isValidEmail(emailController.text.trim())) {
      _setError('Please enter a valid email address');
      return false;
    }

    _setLoading(true);
    _setError(null);

    try {
      final newProfile = Profile(
        name: nameController.text.trim(),
        email: emailController.text.trim(),
      );

      final createdProfile = await _profileService.createProfile(newProfile);
      _profiles.add(createdProfile);
      _currentProfile = createdProfile;
      clearForm();
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Update existing profile
  Future<bool> updateProfile() async {
    if (_currentProfile == null) {
      _setError('No profile selected for update');
      return false;
    }

    if (nameController.text.trim().isEmpty ||
        emailController.text.trim().isEmpty) {
      _setError('Name and email are required');
      return false;
    }

    if (!_isValidEmail(emailController.text.trim())) {
      _setError('Please enter a valid email address');
      return false;
    }

    _setLoading(true);
    _setError(null);

    try {
      final updatedProfile = _currentProfile!.copyWith(
        name: nameController.text.trim(),
        email: emailController.text.trim(),
      );

      final result = await _profileService.updateProfile(updatedProfile);

      // Update in local list
      final index = _profiles.indexWhere((p) => p.id == result.id);
      if (index != -1) {
        _profiles[index] = result;
      }

      _currentProfile = result;
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Delete profile
  Future<bool> deleteProfile(int id) async {
    _setLoading(true);
    _setError(null);

    try {
      final success = await _profileService.deleteProfile(id);
      if (success) {
        _profiles.removeWhere((p) => p.id == id);
        if (_currentProfile?.id == id) {
          _currentProfile = null;
          clearForm();
        }
        notifyListeners();
      }
      return success;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Search profiles
  Future<void> searchProfiles(String query) async {
    if (query.trim().isEmpty) {
      await loadProfiles();
      return;
    }

    _setLoading(true);
    _setError(null);

    try {
      _profiles = await _profileService.searchProfiles(query.trim());
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Select profile for editing
  void selectProfile(Profile profile) {
    _currentProfile = profile;
    nameController.text = profile.name;
    emailController.text = profile.email;
    notifyListeners();
  }

  // Clear form
  void clearForm() {
    nameController.clear();
    emailController.clear();
    _currentProfile = null;
    _setError(null);
    notifyListeners();
  }

  // Email validation
  bool _isValidEmail(String email) {
    return RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(email);
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    searchController.dispose();
    super.dispose();
  }
}
