// import 'dart:io';
// import 'package:flutter/material.dart';
// import '../models/chat_model.dart';
// import '../services/chat_service.dart';

// class RecipeViewModel extends ChangeNotifier {
//   final RecipeService _recipeService = RecipeService();

//   // State variables
//   bool _isLoading = false;
//   String? _error;
//   Recipe? _currentRecipe;
//   Recipe? _generatedRecipe;
//   List<Recipe> _allRecipes = [];

//   // Form controllers and data
//   final TextEditingController nameController = TextEditingController();
//   final TextEditingController cookingTimeController = TextEditingController();
//   final TextEditingController cuisineController = TextEditingController();
//   final TextEditingController dietController = TextEditingController();

//   List<Ingredient> _ingredients = [];
//   List<String> _steps = [];
//   List<String> _aiIngredients = [];

//   // Editing state
//   bool _isEditing = false;
//   String? _editingRecipeId;

//   // Getters
//   bool get isLoading => _isLoading;
//   String? get error => _error;
//   Recipe? get currentRecipe => _currentRecipe;
//   Recipe? get generatedRecipe => _generatedRecipe;
//   List<Recipe> get allRecipes => _allRecipes;
//   List<Ingredient> get ingredients => _ingredients;
//   List<String> get steps => _steps;
//   List<String> get aiIngredients => _aiIngredients;
//   bool get isEditing => _isEditing;
//   String? get editingRecipeId => _editingRecipeId;

//   void _setLoading(bool loading) {
//     _isLoading = loading;
//     notifyListeners();
//   }

//   void _setError(String? error) {
//     _error = error;
//     notifyListeners();
//   }

//   // Add ingredient
//   void addIngredient(String name, String quantity,
//       [String? unit, String? notes]) {
//     if (name.trim().isEmpty || quantity.trim().isEmpty) return;

//     _ingredients.add(Ingredient(
//       name: name.trim(),
//       quantity: quantity.trim(),
//       unit: unit?.trim().isEmpty == true ? null : unit?.trim(),
//       notes: notes?.trim().isEmpty == true ? null : notes?.trim(),
//     ));
//     notifyListeners();
//   }

//   void removeIngredient(int index) {
//     if (index >= 0 && index < _ingredients.length) {
//       _ingredients.removeAt(index);
//       notifyListeners();
//     }
//   }

//   // Add step
//   void addStep(String step) {
//     if (step.trim().isEmpty) return;
//     _steps.add(step.trim());
//     notifyListeners();
//   }

//   void removeStep(int index) {
//     if (index >= 0 && index < _steps.length) {
//       _steps.removeAt(index);
//       notifyListeners();
//     }
//   }

//   // Add AI ingredient
//   void addAIIngredient(String ingredient) {
//     if (ingredient.trim().isEmpty) return;
//     _aiIngredients.add(ingredient.trim());
//     notifyListeners();
//   }

//   void removeAIIngredient(int index) {
//     if (index >= 0 && index < _aiIngredients.length) {
//       _aiIngredients.removeAt(index);
//       notifyListeners();
//     }
//   }

//   // Get all recipes
//   Future<void> getAllRecipes() async {
//     _setLoading(true);
//     _setError(null);

//     try {
//       _allRecipes = await _recipeService.getAllRecipes();
//       _setLoading(false);
//     } catch (e) {
//       _setError(e.toString());
//       _allRecipes = [];
//       _setLoading(false);
//     }
//   }

//   // Create recipe
//   Future<bool> createRecipe() async {
//     if (nameController.text.trim().isEmpty ||
//         _ingredients.isEmpty ||
//         _steps.isEmpty ||
//         cookingTimeController.text.trim().isEmpty) {
//       _setError('Please fill in all required fields');
//       return false;
//     }

//     _setLoading(true);
//     _setError(null);

//     try {
//       final recipe = Recipe(
//         name: nameController.text.trim(),
//         ingredients: _ingredients,
//         steps: _steps,
//         cookingTime: cookingTimeController.text.trim(),
//         cuisine: cuisineController.text.trim().isEmpty
//             ? null
//             : cuisineController.text.trim(),
//         dietaryInfo: dietController.text.trim().isEmpty
//             ? null
//             : dietController.text.trim(),
//       );

//       await _recipeService.createRecipe(recipe);
//       _clearForm();
//       _setLoading(false);

//       // Refresh the recipes list
//       getAllRecipes();
//       return true;
//     } catch (e) {
//       _setError(e.toString());
//       _setLoading(false);
//       return false;
//     }
//   }

//   // Get recipe by ID
//   Future<void> getRecipe(String id) async {
//     _setLoading(true);
//     _setError(null);

//     try {
//       _currentRecipe = await _recipeService.getRecipe(id);
//       _setLoading(false);
//     } catch (e) {
//       _setError(e.toString());
//       _currentRecipe = null;
//       _setLoading(false);
//     }
//   }

//   // Populate form for editing
//   void populateFormForEditing(Recipe recipe) {
//     _isEditing = true;
//     _editingRecipeId = recipe.id;

//     nameController.text = recipe.name;
//     cookingTimeController.text = recipe.cookingTime;
//     cuisineController.text = recipe.cuisine ?? '';
//     dietController.text = recipe.dietaryInfo ?? '';

//     _ingredients = List<Ingredient>.from(recipe.ingredients);
//     _steps = List<String>.from(recipe.steps);

//     notifyListeners();
//   }

//   // Update recipe
//   Future<bool> updateRecipe() async {
//     if (_editingRecipeId == null) {
//       _setError('No recipe selected for editing');
//       return false;
//     }

//     if (nameController.text.trim().isEmpty ||
//         _ingredients.isEmpty ||
//         _steps.isEmpty ||
//         cookingTimeController.text.trim().isEmpty) {
//       _setError('Please fill in all required fields');
//       return false;
//     }

//     _setLoading(true);
//     _setError(null);

//     try {
//       final recipe = Recipe(
//         id: _editingRecipeId,
//         name: nameController.text.trim(),
//         ingredients: _ingredients,
//         steps: _steps,
//         cookingTime: cookingTimeController.text.trim(),
//         cuisine: cuisineController.text.trim().isEmpty
//             ? null
//             : cuisineController.text.trim(),
//         dietaryInfo: dietController.text.trim().isEmpty
//             ? null
//             : dietController.text.trim(),
//       );

//       await _recipeService.updateRecipe(_editingRecipeId!, recipe);
//       _clearForm();
//       _exitEditingMode();
//       _setLoading(false);

//       // Refresh the recipes list
//       getAllRecipes();
//       return true;
//     } catch (e) {
//       _setError(e.toString());
//       _setLoading(false);
//       return false;
//     }
//   }

//   // Delete recipe
//   Future<bool> deleteRecipe(String id) async {
//     _setLoading(true);
//     _setError(null);

//     try {
//       final success = await _recipeService.deleteRecipe(id);
//       _setLoading(false);

//       if (success) {
//         // Remove from local list if deletion was successful
//         _allRecipes.removeWhere((recipe) => recipe.id == id);

//         // If we're currently viewing the deleted recipe, clear it
//         if (_currentRecipe?.id == id) {
//           _currentRecipe = null;
//         }

//         // If we're editing the deleted recipe, exit editing mode
//         if (_editingRecipeId == id) {
//           _exitEditingMode();
//           _clearForm();
//         }

//         notifyListeners();
//         return true;
//       }
//       return false;
//     } catch (e) {
//       _setError(e.toString());
//       _setLoading(false);
//       return false;
//     }
//   }

//   // Generate recipe with AI
//   Future<bool> generateRecipe() async {
//     if (_aiIngredients.isEmpty) {
//       _setError('Please add at least one ingredient');
//       return false;
//     }

//     _setLoading(true);
//     _setError(null);

//     try {
//       final result = await _recipeService.generateRecipe(
//         ingredients: _aiIngredients,
//         cuisine: cuisineController.text.trim().isEmpty
//             ? null
//             : cuisineController.text.trim(),
//         diet: dietController.text.trim().isEmpty
//             ? null
//             : dietController.text.trim(),
//       );

//       _generatedRecipe = Recipe.fromJson(result['recipe']);
//       _setLoading(false);
//       return true;
//     } catch (e) {
//       _setError(e.toString());
//       _generatedRecipe = null;
//       _setLoading(false);
//       return false;
//     }
//   }

//   // Use generated recipe as template for new recipe
//   void useGeneratedRecipe() {
//     if (_generatedRecipe == null) return;

//     nameController.text = _generatedRecipe!.name;
//     cookingTimeController.text = _generatedRecipe!.cookingTime;
//     cuisineController.text = _generatedRecipe!.cuisine ?? '';
//     dietController.text = _generatedRecipe!.dietaryInfo ?? '';

//     _ingredients = List<Ingredient>.from(_generatedRecipe!.ingredients);
//     _steps = List<String>.from(_generatedRecipe!.steps);

//     // Clear AI form and generated recipe
//     _aiIngredients.clear();
//     _generatedRecipe = null;

//     notifyListeners();
//   }

//   // Upload image
//   Future<String?> uploadImage(File imageFile) async {
//     _setLoading(true);
//     _setError(null);

//     try {
//       final imageUrl = await _recipeService.uploadImage(imageFile);
//       _setLoading(false);
//       return imageUrl;
//     } catch (e) {
//       _setError(e.toString());
//       _setLoading(false);
//       return null;
//     }
//   }

//   // Exit editing mode
//   void _exitEditingMode() {
//     _isEditing = false;
//     _editingRecipeId = null;
//   }

//   // Cancel editing
//   void cancelEditing() {
//     _exitEditingMode();
//     _clearForm();
//   }

//   // Clear form
//   void _clearForm() {
//     nameController.clear();
//     cookingTimeController.clear();
//     cuisineController.clear();
//     dietController.clear();
//     _ingredients.clear();
//     _steps.clear();
//     notifyListeners();
//   }

//   // Clear AI form
//   void clearAIForm() {
//     cuisineController.clear();
//     dietController.clear();
//     _aiIngredients.clear();
//     _generatedRecipe = null;
//     notifyListeners();
//   }

//   // Clear error
//   void clearError() {
//     _setError(null);
//   }

//   @override
//   void dispose() {
//     nameController.dispose();
//     cookingTimeController.dispose();
//     cuisineController.dispose();
//     dietController.dispose();
//     super.dispose();
//   }
// }
// ====================================

import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import '../models/chat_model.dart';
import '../services/chat_service.dart';

// Custom exception classes for better error handling
class RecipeException implements Exception {
  final String message;
  final String? details;
  final int? statusCode;
  
  RecipeException(this.message, {this.details, this.statusCode});
  
  @override
  String toString() => message;
}

class NetworkException extends RecipeException {
  NetworkException(String message, {String? details}) 
    : super(message, details: details);
}

class ValidationException extends RecipeException {
  ValidationException(String message, {String? details}) 
    : super(message, details: details);
}

class ServerException extends RecipeException {
  ServerException(String message, {String? details, int? statusCode}) 
    : super(message, details: details, statusCode: statusCode);
}

class RecipeViewModel extends ChangeNotifier {
  final RecipeService _recipeService = RecipeService();

  // State variables
  bool _isLoading = false;
  String? _error;
  String? _errorDetails;
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
  String? get errorDetails => _errorDetails;
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

  void _setError(String? error, {String? details}) {
    _error = error;
    _errorDetails = details;
    notifyListeners();
  }

  // Enhanced error handling method
  String _handleError(dynamic error) {
    if (error is RecipeException) {
      _setError(error.message, details: error.details);
      return error.message;
    }
    
    if (error is SocketException) {
      const message = 'Tidak dapat terhubung ke server';
      const details = 'Periksa koneksi internet Anda dan coba lagi';
      _setError(message, details: details);
      return message;
    }
    
    if (error is FormatException) {
      const message = 'Data tidak valid';
      const details = 'Server mengirim data yang tidak dapat diproses';
      _setError(message, details: details);
      return message;
    }
    
    if (error is TimeoutException) {
      const message = 'Koneksi timeout';
      const details = 'Server tidak merespons dalam waktu yang wajar. Coba lagi.';
      _setError(message, details: details);
      return message;
    }

    // Handle HTTP status codes
    final errorString = error.toString();
    if (errorString.contains('404')) {
      const message = 'Resep tidak ditemukan';
      const details = 'Resep yang Anda cari mungkin telah dihapus atau tidak tersedia';
      _setError(message, details: details);
      return message;
    } else if (errorString.contains('403')) {
      const message = 'Akses ditolak';
      const details = 'Anda tidak memiliki izin untuk melakukan tindakan ini';
      _setError(message, details: details);
      return message;
    } else if (errorString.contains('500')) {
      const message = 'Terjadi kesalahan pada server';
      const details = 'Server mengalami masalah internal. Tim teknis telah diberitahu.';
      _setError(message, details: details);
      return message;
    } else if (errorString.contains('429')) {
      const message = 'Terlalu banyak permintaan';
      const details = 'Anda telah mencapai batas maksimal. Tunggu beberapa saat sebelum mencoba lagi.';
      _setError(message, details: details);
      return message;
    }
    
    // Generic error
    const message = 'Terjadi kesalahan yang tidak terduga';
    final details = 'Detail: ${error.toString()}';
    _setError(message, details: details);
    return message;
  }

  // Validation methods
  String? _validateRecipeForm() {
    if (nameController.text.trim().isEmpty) {
      return 'Nama resep tidak boleh kosong';
    }
    
    if (nameController.text.trim().length < 3) {
      return 'Nama resep minimal 3 karakter';
    }
    
    if (cookingTimeController.text.trim().isEmpty) {
      return 'Waktu memasak tidak boleh kosong';
    }
    
    if (_ingredients.isEmpty) {
      return 'Tambahkan minimal 1 bahan untuk resep';
    }
    
    if (_steps.isEmpty) {
      return 'Tambahkan minimal 1 langkah memasak';
    }
    
    // Validate ingredients
    for (int i = 0; i < _ingredients.length; i++) {
      final ingredient = _ingredients[i];
      if (ingredient.name.trim().isEmpty) {
        return 'Bahan ke-${i + 1}: Nama bahan tidak boleh kosong';
      }
      if (ingredient.quantity.trim().isEmpty) {
        return 'Bahan ke-${i + 1}: Jumlah bahan tidak boleh kosong';
      }
    }
    
    // Validate steps
    for (int i = 0; i < _steps.length; i++) {
      if (_steps[i].trim().length < 10) {
        return 'Langkah ke-${i + 1}: Deskripsi langkah terlalu pendek (minimal 10 karakter)';
      }
    }
    
    return null;
  }

  String? _validateAIForm() {
    if (_aiIngredients.isEmpty) {
      return 'Tambahkan minimal 1 bahan untuk generate resep dengan AI';
    }
    
    if (_aiIngredients.length > 20) {
      return 'Maksimal 20 bahan untuk generate resep dengan AI';
    }
    
    for (int i = 0; i < _aiIngredients.length; i++) {
      if (_aiIngredients[i].trim().length < 2) {
        return 'Bahan ke-${i + 1}: Nama bahan terlalu pendek';
      }
    }
    
    return null;
  }

  // Add ingredient with validation
  bool addIngredient(String name, String quantity, [String? unit, String? notes]) {
    final trimmedName = name.trim();
    final trimmedQuantity = quantity.trim();
    
    if (trimmedName.isEmpty) {
      _setError('Nama bahan tidak boleh kosong');
      return false;
    }
    
    if (trimmedQuantity.isEmpty) {
      _setError('Jumlah bahan tidak boleh kosong');
      return false;
    }
    
    if (trimmedName.length < 2) {
      _setError('Nama bahan minimal 2 karakter');
      return false;
    }
    
    // Check for duplicate ingredients
    final exists = _ingredients.any((ingredient) => 
        ingredient.name.toLowerCase() == trimmedName.toLowerCase());
    
    if (exists) {
      _setError('Bahan "$trimmedName" sudah ditambahkan');
      return false;
    }

    _ingredients.add(Ingredient(
      name: trimmedName,
      quantity: trimmedQuantity,
      unit: unit?.trim().isEmpty == true ? null : unit?.trim(),
      notes: notes?.trim().isEmpty == true ? null : notes?.trim(),
    ));
    
    // Clear error if successful
    _setError(null);
    notifyListeners();
    return true;
  }

  bool removeIngredient(int index) {
    if (index < 0 || index >= _ingredients.length) {
      _setError('Indeks bahan tidak valid');
      return false;
    }
    
    _ingredients.removeAt(index);
    _setError(null);
    notifyListeners();
    return true;
  }

  // Add step with validation
  bool addStep(String step) {
    final trimmedStep = step.trim();
    
    if (trimmedStep.isEmpty) {
      _setError('Langkah memasak tidak boleh kosong');
      return false;
    }
    
    if (trimmedStep.length < 10) {
      _setError('Deskripsi langkah minimal 10 karakter');
      return false;
    }
    
    if (_steps.length >= 50) {
      _setError('Maksimal 50 langkah memasak');
      return false;
    }
    
    _steps.add(trimmedStep);
    _setError(null);
    notifyListeners();
    return true;
  }

  bool removeStep(int index) {
    if (index < 0 || index >= _steps.length) {
      _setError('Indeks langkah tidak valid');
      return false;
    }
    
    _steps.removeAt(index);
    _setError(null);
    notifyListeners();
    return true;
  }

  // Add AI ingredient with validation
  bool addAIIngredient(String ingredient) {
    final trimmedIngredient = ingredient.trim();
    
    if (trimmedIngredient.isEmpty) {
      _setError('Nama bahan tidak boleh kosong');
      return false;
    }
    
    if (trimmedIngredient.length < 2) {
      _setError('Nama bahan minimal 2 karakter');
      return false;
    }
    
    if (_aiIngredients.length >= 20) {
      _setError('Maksimal 20 bahan untuk AI generate');
      return false;
    }
    
    // Check for duplicates
    final exists = _aiIngredients.any((item) => 
        item.toLowerCase() == trimmedIngredient.toLowerCase());
    
    if (exists) {
      _setError('Bahan "$trimmedIngredient" sudah ditambahkan');
      return false;
    }
    
    _aiIngredients.add(trimmedIngredient);
    _setError(null);
    notifyListeners();
    return true;
  }

  bool removeAIIngredient(int index) {
    if (index < 0 || index >= _aiIngredients.length) {
      _setError('Indeks bahan tidak valid');
      return false;
    }
    
    _aiIngredients.removeAt(index);
    _setError(null);
    notifyListeners();
    return true;
  }

  // Get all recipes with enhanced error handling
  Future<void> getAllRecipes() async {
    _setLoading(true);
    _setError(null);

    try {
      _allRecipes = await _recipeService.getAllRecipes();
      
      if (_allRecipes.isEmpty) {
        _setError('Belum ada resep tersimpan', 
                 details: 'Mulai dengan membuat resep pertama Anda atau generate dengan AI');
      }
      
      _setLoading(false);
    } catch (e) {
      _handleError(e);
      _allRecipes = [];
      _setLoading(false);
    }
  }

  // Create recipe with enhanced validation and error handling
  Future<bool> createRecipe() async {
    // Client-side validation
    final validationError = _validateRecipeForm();
    if (validationError != null) {
      _setError(validationError);
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
      _handleError(e);
      _setLoading(false);
      return false;
    }
  }

  // Get recipe by ID with enhanced error handling
  Future<void> getRecipe(String id) async {
    if (id.trim().isEmpty) {
      _setError('ID resep tidak valid');
      return;
    }

    _setLoading(true);
    _setError(null);

    try {
      _currentRecipe = await _recipeService.getRecipe(id);
      
      if (_currentRecipe == null) {
        _setError('Resep tidak ditemukan', 
                 details: 'Resep dengan ID tersebut mungkin telah dihapus');
      }
      
      _setLoading(false);
    } catch (e) {
      _handleError(e);
      _currentRecipe = null;
      _setLoading(false);
    }
  }

  // Populate form for editing
  void populateFormForEditing(Recipe recipe) {
    try {
      _isEditing = true;
      _editingRecipeId = recipe.id;

      nameController.text = recipe.name;
      cookingTimeController.text = recipe.cookingTime;
      cuisineController.text = recipe.cuisine ?? '';
      dietController.text = recipe.dietaryInfo ?? '';

      _ingredients = List<Ingredient>.from(recipe.ingredients);
      _steps = List<String>.from(recipe.steps);

      _setError(null);
      notifyListeners();
    } catch (e) {
      _setError('Gagal memuat data resep untuk diedit', 
               details: e.toString());
    }
  }

  // Update recipe with enhanced validation and error handling
  Future<bool> updateRecipe() async {
    if (_editingRecipeId == null) {
      _setError('Tidak ada resep yang dipilih untuk diedit');
      return false;
    }

    // Client-side validation
    final validationError = _validateRecipeForm();
    if (validationError != null) {
      _setError(validationError);
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
      _handleError(e);
      _setLoading(false);
      return false;
    }
  }

  // Delete recipe with enhanced error handling
  Future<bool> deleteRecipe(String id) async {
    if (id.trim().isEmpty) {
      _setError('ID resep tidak valid');
      return false;
    }

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
      } else {
        _setError('Gagal menghapus resep', 
                 details: 'Resep mungkin sudah dihapus atau terjadi kesalahan pada server');
        return false;
      }
    } catch (e) {
      _handleError(e);
      _setLoading(false);
      return false;
    }
  }

  // Generate recipe with AI with enhanced validation and error handling
  Future<bool> generateRecipe() async {
    // Client-side validation
    final validationError = _validateAIForm();
    if (validationError != null) {
      _setError(validationError);
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

      if (result == null || result['recipe'] == null) {
        _setError('Gagal generate resep', 
                 details: 'AI tidak dapat membuat resep dengan bahan-bahan tersebut');
        return false;
      }

      _generatedRecipe = Recipe.fromJson(result['recipe']);
      _setLoading(false);
      return true;
    } catch (e) {
      _handleError(e);
      _generatedRecipe = null;
      _setLoading(false);
      return false;
    }
  }

  // Use generated recipe as template for new recipe
  bool useGeneratedRecipe() {
    if (_generatedRecipe == null) {
      _setError('Tidak ada resep yang di-generate');
      return false;
    }

    try {
      nameController.text = _generatedRecipe!.name;
      cookingTimeController.text = _generatedRecipe!.cookingTime;
      cuisineController.text = _generatedRecipe!.cuisine ?? '';
      dietController.text = _generatedRecipe!.dietaryInfo ?? '';

      _ingredients = List<Ingredient>.from(_generatedRecipe!.ingredients);
      _steps = List<String>.from(_generatedRecipe!.steps);

      // Clear AI form and generated recipe
      _aiIngredients.clear();
      _generatedRecipe = null;

      _setError(null);
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Gagal menggunakan resep yang di-generate', 
               details: e.toString());
      return false;
    }
  }

  // Upload image with enhanced error handling
  Future<String?> uploadImage(File imageFile) async {
    if (!imageFile.existsSync()) {
      _setError('File gambar tidak ditemukan');
      return null;
    }
    
    // Check file size
    final fileSize = imageFile.lengthSync();
    if (fileSize > 5 * 1024 * 1024) { // 5MB
      _setError('Ukuran file terlalu besar', 
               details: 'Maksimal ukuran file adalah 5MB');
      return null;
    }
    
    // Check file extension
    final extension = imageFile.path.split('.').last.toLowerCase();
    if (!['jpg', 'jpeg', 'png', 'gif'].contains(extension)) {
      _setError('Format file tidak didukung', 
               details: 'Gunakan format JPG, JPEG, PNG, atau GIF');
      return null;
    }

    _setLoading(true);
    _setError(null);

    try {
      final imageUrl = await _recipeService.uploadImage(imageFile);
      _setLoading(false);
      
      if (imageUrl == null || imageUrl.isEmpty) {
        _setError('Gagal upload gambar', 
                 details: 'Server tidak mengembalikan URL gambar');
        return null;
      }
      
      return imageUrl;
    } catch (e) {
      _handleError(e);
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
    _setError(null);
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
    _setError(null);
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