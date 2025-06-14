import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/kulkasku_model.dart';

class ApiService {
  static const String baseUrl =
      'http://localhost:8000'; // Replace with your actual URL
  late final int userId; 
  ApiService({required this.userId});
  // Add ingredient
  Future<Ingredient?> addIngredient(Ingredient ingredient) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/ingredients'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(ingredient.toJson()),
      );

      if (response.statusCode == 201) {
        return Ingredient.fromJson(jsonDecode(response.body));
      }
      return null;
    } catch (e) {
      print('Error adding ingredient: $e');
      return null;
    }
  }

  // Get all ingredients
  Future<List<Ingredient>> getIngredients() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/ingredients?user_id=$userId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);

        // ✅ Check if the response is a valid list
        if (body is List) {
          return body.map((json) => Ingredient.fromJson(json)).toList();
        } else {
          print('❌ Expected list, got: $body');
          return [];
        }
      } else {
        print('❌ Server returned ${response.statusCode}: ${response.body}');
        return [];
      }
    } catch (e) {
      print('Error fetching ingredients: $e');
      return [];
    }
  }

  // Get ingredient by ID
  Future<Ingredient?> getIngredientById(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/ingredients/$id'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return Ingredient.fromJson(jsonDecode(response.body));
      }
      return null;
    } catch (e) {
      print('Error fetching ingredient: $e');
      return null;
    }
  }

  // Update ingredient
  Future<Ingredient?> updateIngredient(String id, Ingredient ingredient) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/ingredients/$id'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(ingredient.toJson()),
      );

      if (response.statusCode == 200) {
        return Ingredient.fromJson(jsonDecode(response.body));
      }
      return null;
    } catch (e) {
      print('Error updating ingredient: $e');
      return null;
    }
  }

  // Delete ingredient
  Future<bool> deleteIngredient(String id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/ingredients/$id'),
        headers: {'Content-Type': 'application/json'},
      );

      return response.statusCode == 204;
    } catch (e) {
      print('Error deleting ingredient: $e');
      return false;
    }
  }

  // Get recipes (if you have this endpoint)
  Future<List<dynamic>> getRecipes() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/recipes?user_id=$userId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return [];
    } catch (e) {
      print('Error fetching recipes: $e');
      return [];
    }
  }
}
