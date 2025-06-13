// viewmodels/profile_viewmodel.dart
import 'package:flutter/material.dart';
import 'package:pembersih_kulkas_microservice_flutter/models/chat_model.dart';
import 'package:pembersih_kulkas_microservice_flutter/services/chat_service.dart';
import '../models/profile_model.dart';
import '../services/profile_service.dart';
import 'dart:io';
import 'package:http/http.dart' as http;

class ProfileViewModel extends ChangeNotifier {
  final ProfileService _profileService = ProfileService();

  // Controllers for form fields
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController searchController = TextEditingController();
  final RecipeService _recipeService = RecipeService();

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

  List<Recipe> _recipes = [];
  List<Recipe> get recipes => _recipes;

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

  // Enhanced error handling method
  String _handleError(dynamic error) {
    if (error is SocketException) {
      return 'Tidak dapat terhubung ke server. Periksa koneksi internet Anda.';
    } else if (error is http.ClientException) {
      return 'Gagal menghubungi server. Silakan coba lagi nanti.';
    } else if (error is FormatException) {
      return 'Data yang diterima dari server tidak valid.';
    } else if (error.toString().contains('404')) {
      return 'Data yang diminta tidak ditemukan.';
    } else if (error.toString().contains('401')) {
      return 'Akses ditolak. Silakan login kembali.';
    } else if (error.toString().contains('403')) {
      return 'Anda tidak memiliki izin untuk mengakses data ini.';
    } else if (error.toString().contains('500')) {
      return 'Terjadi kesalahan pada server. Silakan coba lagi nanti.';
    } else if (error.toString().contains('timeout')) {
      return 'Koneksi timeout. Silakan coba lagi.';
    } else if (error.toString().contains('No profiles found')) {
      return 'Belum ada profil yang terdaftar.';
    } else if (error.toString().contains('Profile not found')) {
      return 'Profil yang dicari tidak ditemukan.';
    } else if (error.toString().contains('Email already exists')) {
      return 'Email sudah terdaftar. Gunakan email lain.';
    } else if (error.toString().contains('Invalid email format')) {
      return 'Format email tidak valid.';
    } else if (error.toString().contains('Name too short')) {
      return 'Nama terlalu pendek. Minimal 2 karakter.';
    } else if (error.toString().contains('Network error')) {
      return 'Terjadi kesalahan jaringan. Periksa koneksi internet Anda.';
    }

    // Generic error message
    return 'Terjadi kesalahan: ${error.toString()}';
  }

  // Load all profiles with better error handling
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
      final errorMessage = _handleError(e);
      _setError(errorMessage);
    } finally {
      _setLoading(false);
    }
  }

  // Load recipes with better error handling
  Future<void> loadRecipes() async {
    _setLoading(true);
    _setError(null);
    try {
      _recipes = await _recipeService.getAllRecipes();
      notifyListeners();
    } catch (e) {
      final errorMessage = _handleError(e);
      _setError(errorMessage);
    } finally {
      _setLoading(false);
    }
  }

  // Load specific profile by ID with better error handling
  Future<void> loadProfile(int id) async {
    _setLoading(true);
    _setError(null);

    try {
      _currentProfile = await _profileService.getProfile(id);
      if (_currentProfile != null) {
        // Update form controllers with current profile data
        nameController.text = _currentProfile!.name;
        emailController.text = _currentProfile!.email;
      }
      notifyListeners();
    } catch (e) {
      final errorMessage = _handleError(e);
      _setError(errorMessage);
    } finally {
      _setLoading(false);
    }
  }

  // Create new profile with enhanced validation and error handling
  Future<bool> createProfile() async {
    // Client-side validation
    if (nameController.text.trim().isEmpty) {
      _setError('Nama tidak boleh kosong');
      return false;
    }

    if (nameController.text.trim().length < 2) {
      _setError('Nama minimal 2 karakter');
      return false;
    }

    if (emailController.text.trim().isEmpty) {
      _setError('Email tidak boleh kosong');
      return false;
    }

    if (!_isValidEmail(emailController.text.trim())) {
      _setError('Format email tidak valid');
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
      final errorMessage = _handleError(e);
      _setError(errorMessage);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Update existing profile with better error handling
  Future<bool> updateProfile() async {
    if (_currentProfile == null) {
      _setError('Tidak ada profil yang dipilih untuk diupdate');
      return false;
    }

    // Client-side validation
    if (nameController.text.trim().isEmpty) {
      _setError('Nama tidak boleh kosong');
      return false;
    }

    if (nameController.text.trim().length < 2) {
      _setError('Nama minimal 2 karakter');
      return false;
    }

    if (emailController.text.trim().isEmpty) {
      _setError('Email tidak boleh kosong');
      return false;
    }

    if (!_isValidEmail(emailController.text.trim())) {
      _setError('Format email tidak valid');
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
      final errorMessage = _handleError(e);
      _setError(errorMessage);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Delete profile with better error handling
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
        return true;
      } else {
        _setError('Gagal menghapus profil');
        return false;
      }
    } catch (e) {
      final errorMessage = _handleError(e);
      _setError(errorMessage);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Search profiles with better error handling
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
      final errorMessage = _handleError(e);
      _setError(errorMessage);
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

  // Enhanced email validation
  bool _isValidEmail(String email) {
    return RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
        .hasMatch(email);
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    searchController.dispose();
    super.dispose();
  }
}
