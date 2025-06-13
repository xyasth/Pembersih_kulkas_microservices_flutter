// services/ingredient_service.dart
import '../models/kulkasku_model.dart';
import 'kulkasku_service.dart';

class IngredientService {
  final ApiService _apiService;

  IngredientService({required ApiService apiService}) : _apiService = apiService;

  Future<List<Ingredient>> getAllIngredients() async {
    return await _apiService.getIngredients();
  }

  Future<Ingredient?> getIngredient(int id) async {
    return await _apiService.getIngredientById(id);
  }

  Future<Ingredient?> createIngredient({
    required String name,
    required int quantity,
    required String unit,
  }) async {
    final ingredient = Ingredient(
      id: '',
      name: name,
      quantity: quantity,
      unit: unit,
      userId: _apiService.userId, // ✅ get from injected service
    );

    return await _apiService.addIngredient(ingredient);
  }

  Future<Ingredient?> updateIngredient(String id, Ingredient ingredient) async {
    return await _apiService.updateIngredient(id, ingredient);
  }

  Future<bool> deleteIngredient(String id) async {
    return await _apiService.deleteIngredient(id);
  }

  Future<List<dynamic>> getRecipeRecommendations() async {
    return await _apiService.getRecipes();
  }
}