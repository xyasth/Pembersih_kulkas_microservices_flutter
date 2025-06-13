import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pembersih_kulkas_microservice_flutter/models/youtube_video_model.dart';

class YouTubeService {
  final String baseUrl = 'http://localhost:8000/youtube'; 

  Future<List<YouTubeVideo>> searchVideos(String query) async {
    final response = await http.get(
      Uri.parse('$baseUrl/search?q=$query&maxResults=10'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      
      if (data['items'] != null && data['items'] is List) {
        return (data['items'] as List)
            .map((item) => YouTubeVideo.fromJson(item))
            .toList();
      } else {
        throw Exception('Data items tidak ditemukan atau bukan List');
      }
    } else {
      throw Exception('Gagal mencari video YouTube: ${response.statusCode}');
    }
  }
}