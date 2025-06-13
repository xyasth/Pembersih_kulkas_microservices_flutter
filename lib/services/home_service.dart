import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/home_model.dart';

class ApiService {
  final String baseUrl = 'http://localhost:8000/recipes'; 

  Future<List<Recipe>> fetchRecipes() async {
  final response = await http.get(Uri.parse(baseUrl));

  if (response.statusCode == 200) {
    final data = json.decode(response.body);

    // CEK apakah 'results' ada dan berupa list
    if (data['results'] != null && data['results'] is List) {
      return (data['results'] as List)
          .map((item) => Recipe.fromJson(item))
          .toList();
    } else {
      throw Exception('Data results tidak ditemukan atau bukan List');
    }
  } else {
    throw Exception('Gagal memuat data resep');
  }
}
}
