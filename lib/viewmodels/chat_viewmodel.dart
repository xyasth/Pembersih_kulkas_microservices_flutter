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
  List<Recipe> _allRecipes = [];

  // Form controllers and data
  final TextEditingController nameController = TextEditingController();
  final TextEditingController cookingTimeController = TextEditingController();
  final TextEditingController cuisineController = TextEditingController();
  final TextEditingController dietController = TextEditingController();

  List<Ingredient> _ingredients = [];
  List<String> _steps = [];
  List<String> _aiIngredients = [];

  // Editing state
  bool _isEditing = false;
  String? _editingRecipeId;

  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  Recipe? get currentRecipe => _currentRecipe;
  Recipe? get generatedRecipe => _generatedRecipe;
  List<Recipe> get allRecipes => _allRecipes;
  List<Ingredient> get ingredients => _ingredients;
  List<String> get steps => _steps;
  List<String> get aiIngredients => _aiIngredients;
  bool get isEditing => _isEditing;
  String? get editingRecipeId => _editingRecipeId;

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

  // Get all recipes
  Future<void> getAllRecipes() async {
    _setLoading(true);
    _setError(null);

    try {
      _allRecipes = await _recipeService.getAllRecipes();
      _setLoading(false);
    } catch (e) {
      _setError(e.toString());
      _allRecipes = [];
      _setLoading(false);
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

      // Refresh the recipes list
      getAllRecipes();
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

  // Populate form for editing
  void populateFormForEditing(Recipe recipe) {
    _isEditing = true;
    _editingRecipeId = recipe.id;

    nameController.text = recipe.name;
    cookingTimeController.text = recipe.cookingTime;
    cuisineController.text = recipe.cuisine ?? '';
    dietController.text = recipe.dietaryInfo ?? '';

    _ingredients = List<Ingredient>.from(recipe.ingredients);
    _steps = List<String>.from(recipe.steps);

    notifyListeners();
  }

  // Update recipe
  Future<bool> updateRecipe() async {
    if (_editingRecipeId == null) {
      _setError('No recipe selected for editing');
      return false;
    }

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
        id: _editingRecipeId,
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

      await _recipeService.updateRecipe(_editingRecipeId!, recipe);
      _clearForm();
      _exitEditingMode();
      _setLoading(false);

      // Refresh the recipes list
      getAllRecipes();
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  // Delete recipe
  Future<bool> deleteRecipe(String id) async {
    _setLoading(true);
    _setError(null);

    try {
      final success = await _recipeService.deleteRecipe(id);
      _setLoading(false);

      if (success) {
        // Remove from local list if deletion was successful
        _allRecipes.removeWhere((recipe) => recipe.id == id);

        // If we're currently viewing the deleted recipe, clear it
        if (_currentRecipe?.id == id) {
          _currentRecipe = null;
        }

        // If we're editing the deleted recipe, exit editing mode
        if (_editingRecipeId == id) {
          _exitEditingMode();
          _clearForm();
        }

        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
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

  // Use generated recipe as template for new recipe
  void useGeneratedRecipe() {
    if (_generatedRecipe == null) return;

    nameController.text = _generatedRecipe!.name;
    cookingTimeController.text = _generatedRecipe!.cookingTime;
    cuisineController.text = _generatedRecipe!.cuisine ?? '';
    dietController.text = _generatedRecipe!.dietaryInfo ?? '';

    _ingredients = List<Ingredient>.from(_generatedRecipe!.ingredients);
    _steps = List<String>.from(_generatedRecipe!.steps);

    // Clear AI form and generated recipe
    _aiIngredients.clear();
    _generatedRecipe = null;

    notifyListeners();
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

  // Exit editing mode
  void _exitEditingMode() {
    _isEditing = false;
    _editingRecipeId = null;
  }

  // Cancel editing
  void cancelEditing() {
    _exitEditingMode();
    _clearForm();
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
