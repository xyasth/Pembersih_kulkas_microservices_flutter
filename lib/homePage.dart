import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl = 'http://10.0.2.2:3001'; // ← untuk emulator. Gunakan IP LAN kalau testing di HP

  Future<List<dynamic>> fetchRecipes({String query = 'pasta'}) async {
    final response = await http.get(Uri.parse('$baseUrl/recipes?query=$query'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['results']; // list resep
    } else {
      throw Exception('Failed to load recipes');
    }
  }
}
