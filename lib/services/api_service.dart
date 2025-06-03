import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl = 'http://localhost:8000'; // Ganti sesuai IP server

  Future<List<dynamic>> fetchCars() async {
    final response = await http.get(Uri.parse('$baseUrl/api/mobil'));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Gagal mengambil data');
    }
  }
}
