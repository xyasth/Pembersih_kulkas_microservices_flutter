import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/recipe_detail_model.dart';

class RecipeDetailService {
  final String baseUrl = 'http://localhost:8000/recipes';

  Future<RecipeDetail> fetchRecipeDetail(int recipeId) async {
    final response = await http.get(Uri.parse('$baseUrl/$recipeId'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return RecipeDetail.fromJson(data);
    } else {
      throw Exception('Gagal memuat detail resep');
    }
  }
}