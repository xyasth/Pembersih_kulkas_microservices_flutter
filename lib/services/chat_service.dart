import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/chat_model.dart';

class RecipeService {
  static const String baseUrl = 'http://localhost:8000';

  // Create a new recipe
  Future<Map<String, dynamic>> createRecipe(Recipe recipe) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/chat/recipes'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(recipe.toJson()),
      );

      if (response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to create recipe: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error creating recipe: $e');
    }
  }

  // Get a recipe by ID
  Future<Recipe> getRecipe(String id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/chat/recipes/$id'),
      );

      if (response.statusCode == 200) {
        return Recipe.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to get recipe: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error getting recipe: $e');
    }
  }

  // Get all recipes
  Future<List<Recipe>> getAllRecipes() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/chat/recipes'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> recipesJson = jsonDecode(response.body);
        return recipesJson.map((json) => Recipe.fromJson(json)).toList();
      } else {
        throw Exception('Failed to get recipes: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error getting recipes: $e');
    }
  }

  // Update a recipe
  Future<Map<String, dynamic>> updateRecipe(String id, Recipe recipe) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/chat/recipes/$id'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(recipe.toJson()),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to update recipe: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error updating recipe: $e');
    }
  }

  // Delete a recipe
  Future<bool> deleteRecipe(String id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/chat/recipes/$id'),
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        return true;
      } else {
        throw Exception('Failed to delete recipe: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error deleting recipe: $e');
    }
  }

  // Generate recipe using AI
  Future<Map<String, dynamic>> generateRecipe({
    required List<String> ingredients,
    String? cuisine,
    String? diet,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/chat/recipes/generate'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'ingredients': ingredients,
          if (cuisine != null && cuisine.isNotEmpty) 'cuisine': cuisine,
          if (diet != null && diet.isNotEmpty) 'diet': diet,
        }),
      );

      if (response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to generate recipe: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error generating recipe: $e');
    }
  }

  // Upload image
  Future<String> uploadImage(File imageFile) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/chat/upload'),
      );

      request.files.add(
        await http.MultipartFile.fromPath('image', imageFile.path),
      );

      var response = await request.send();
      var responseData = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        var data = jsonDecode(responseData);
        return data['image_url'];
      } else {
        throw Exception('Failed to upload image: $responseData');
      }
    } catch (e) {
      throw Exception('Error uploading image: $e');
    }
  }
}
