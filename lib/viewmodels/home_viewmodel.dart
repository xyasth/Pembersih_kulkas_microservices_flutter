import 'package:flutter/material.dart';
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

  Future<void> fetchRecipes() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _recipes = await _apiService.fetchRecipes();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
