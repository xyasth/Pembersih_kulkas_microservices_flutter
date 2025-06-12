import 'dart:io';
import 'package:flutter/material.dart';
import '../models/chat_model.dart';
import '../services/chat_service.dart';

class RecipeViewModel extends ChangeNotifier {
  final RecipeService _recipeService = RecipeService();

  // State variables
  bool _isLoading = false;
  String? _error;
  Recipe? _currentRecipe;
  Recipe? _generatedRecipe;

  // Form controllers and data
  final TextEditingController nameController = TextEditingController();
  final TextEditingController cookingTimeController = TextEditingController();
  final TextEditingController cuisineController = TextEditingController();
  final TextEditingController dietController = TextEditingController();

  List<Ingredient> _ingredients = [];
  List<String> _steps = [];
  List<String> _aiIngredients = [];

  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  Recipe? get currentRecipe => _currentRecipe;
  Recipe? get generatedRecipe => _generatedRecipe;
  List<Ingredient> get ingredients => _ingredients;
  List<String> get steps => _steps;
  List<String> get aiIngredients => _aiIngredients;

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  // Add ingredient
  void addIngredient(String name, String quantity,
      [String? unit, String? notes]) {
    if (name.trim().isEmpty || quantity.trim().isEmpty) return;

    _ingredients.add(Ingredient(
      name: name.trim(),
      quantity: quantity.trim(),
      unit: unit?.trim().isEmpty == true ? null : unit?.trim(),
      notes: notes?.trim().isEmpty == true ? null : notes?.trim(),
    ));
    notifyListeners();
  }

  void removeIngredient(int index) {
    if (index >= 0 && index < _ingredients.length) {
      _ingredients.removeAt(index);
      notifyListeners();
    }
  }

  // Add step
  void addStep(String step) {
    if (step.trim().isEmpty) return;
    _steps.add(step.trim());
    notifyListeners();
  }

  void removeStep(int index) {
    if (index >= 0 && index < _steps.length) {
      _steps.removeAt(index);
      notifyListeners();
    }
  }

  // Add AI ingredient
  void addAIIngredient(String ingredient) {
    if (ingredient.trim().isEmpty) return;
    _aiIngredients.add(ingredient.trim());
    notifyListeners();
  }

  void removeAIIngredient(int index) {
    if (index >= 0 && index < _aiIngredients.length) {
      _aiIngredients.removeAt(index);
      notifyListeners();
    }
  }

  // Create recipe
  Future<bool> createRecipe() async {
    if (nameController.text.trim().isEmpty ||
        _ingredients.isEmpty ||
        _steps.isEmpty ||
        cookingTimeController.text.trim().isEmpty) {
      _setError('Please fill in all required fields');
      return false;
    }

    _setLoading(true);
    _setError(null);

    try {
      final recipe = Recipe(
        name: nameController.text.trim(),
        ingredients: _ingredients,
        steps: _steps,
        cookingTime: cookingTimeController.text.trim(),
        cuisine: cuisineController.text.trim().isEmpty
            ? null
            : cuisineController.text.trim(),
        dietaryInfo: dietController.text.trim().isEmpty
            ? null
            : dietController.text.trim(),
      );

      await _recipeService.createRecipe(recipe);
      _clearForm();
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  // Get recipe by ID
  Future<void> getRecipe(String id) async {
    _setLoading(true);
    _setError(null);

    try {
      _currentRecipe = await _recipeService.getRecipe(id);
      _setLoading(false);
    } catch (e) {
      _setError(e.toString());
      _currentRecipe = null;
      _setLoading(false);
    }
  }

  // Generate recipe with AI
  Future<bool> generateRecipe() async {
    if (_aiIngredients.isEmpty) {
      _setError('Please add at least one ingredient');
      return false;
    }

    _setLoading(true);
    _setError(null);

    try {
      final result = await _recipeService.generateRecipe(
        ingredients: _aiIngredients,
        cuisine: cuisineController.text.trim().isEmpty
            ? null
            : cuisineController.text.trim(),
        diet: dietController.text.trim().isEmpty
            ? null
            : dietController.text.trim(),
      );

      _generatedRecipe = Recipe.fromJson(result['recipe']);
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _generatedRecipe = null;
      _setLoading(false);
      return false;
    }
  }

  // Upload image
  Future<String?> uploadImage(File imageFile) async {
    _setLoading(true);
    _setError(null);

    try {
      final imageUrl = await _recipeService.uploadImage(imageFile);
      _setLoading(false);
      return imageUrl;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return null;
    }
  }

  // Clear form
  void _clearForm() {
    nameController.clear();
    cookingTimeController.clear();
    cuisineController.clear();
    dietController.clear();
    _ingredients.clear();
    _steps.clear();
    notifyListeners();
  }

  // Clear AI form
  void clearAIForm() {
    cuisineController.clear();
    dietController.clear();
    _aiIngredients.clear();
    _generatedRecipe = null;
    notifyListeners();
  }

  // Clear error
  void clearError() {
    _setError(null);
  }

  @override
  void dispose() {
    nameController.dispose();
    cookingTimeController.dispose();
    cuisineController.dispose();
    dietController.dispose();
    super.dispose();
  }
}
