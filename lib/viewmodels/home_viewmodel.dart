import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:async';
import '../models/home_model.dart';
import '../services/home_service.dart';

class HomeViewModel extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<Recipe> _recipes = [];
  List<Recipe> get recipes => _recipes;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // Tambahan untuk retry mechanism
  int _retryCount = 0;
  static const int maxRetryAttempts = 3;

  Future<void> fetchRecipes() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _recipes = await _apiService.fetchRecipes();
      _retryCount = 0; // Reset retry count on success
    } catch (e) {
      _handleError(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> retryFetchRecipes() async {
    if (_retryCount < maxRetryAttempts) {
      _retryCount++;
      await fetchRecipes();
    } else {
      _errorMessage = 'Gagal memuat data setelah percobaan. Silakan periksa koneksi internet Anda.';
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = null;
    _retryCount = 0;
    notifyListeners();
  }

  void _handleError(dynamic error) {
    String errorMessage = 'Terjadi kesalahan yang tidak diketahui';
    
    if (error is SocketException) {
      errorMessage = 'Tidak ada koneksi internet. Periksa koneksi Anda dan coba lagi.';
    } else if (error is TimeoutException) {
      errorMessage = 'Koneksi timeout. Server mungkin sedang sibuk, coba lagi nanti.';
    } else if (error is HttpException) {
      errorMessage = 'Terjadi kesalahan server. Coba lagi nanti.';
    } else if (error is FormatException) {
      errorMessage = 'Data yang diterima tidak valid. Silakan hubungi administrator.';
    } else if (error.toString().contains('404')) {
      errorMessage = 'Data tidak ditemukan. API mungkin sedang bermasalah.';
    } else if (error.toString().contains('500')) {
      errorMessage = 'Server sedang bermasalah. Coba lagi dalam beberapa menit.';
    } else if (error.toString().contains('401')) {
      errorMessage = 'Akses tidak diizinkan. Periksa API key Anda.';
    } else if (error.toString().contains('429')) {
      errorMessage = 'Terlalu banyak permintaan. Tunggu sebentar sebelum mencoba lagi.';
    } else {
      errorMessage = 'Gagal memuat data: ${error.toString()}';
    }

    _errorMessage = errorMessage;
    
    // Log error untuk debugging (optional)
    debugPrint('Error in HomeViewModel: $error');
  }
}