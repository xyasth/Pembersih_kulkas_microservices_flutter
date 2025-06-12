import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/home_model.dart';

class ApiService {
  final String baseUrl = 'https://your-api.com/api/recipes'; // Ganti dengan endpoint sebenarnya

  Future<List<Recipe>> fetchRecipes() async {
    final response = await http.get(Uri.parse(baseUrl));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<dynamic> results = data['results'];
      return results.map((item) => Recipe.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load recipes');
    }
  }
}
