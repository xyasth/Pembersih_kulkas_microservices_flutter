import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/profile_model.dart';
import '../models/api_response.dart';

class ProfileService {
  // API Gateway URL - sesuaikan dengan setup Anda
  static const String _baseUrl = 'http://localhost:8000';
  
  // Jika menggunakan emulator Android, gunakan:
  // static const String _baseUrl = 'http://10.0.2.2:8000';
  
  // Jika menggunakan device fisik, ganti dengan IP komputer Anda:
  // static const String _baseUrl = 'http://192.168.1.100:8000';
  
  static const Duration _timeout = Duration(seconds: 30);

  static const Map<String, String> _headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  /// Get all profiles dari API Gateway
  static Future<List<ProfileModel>> getProfiles() async {
    try {
      print('🔍 Fetching profiles from: $_baseUrl/users');
      
      final response = await http.get(
        Uri.parse('$_baseUrl/users'),
        headers: _headers,
      ).timeout(_timeout);

      print('📡 Response status: ${response.statusCode}');
      print('📦 Response body preview: ${response.body.length > 200 ? response.body.substring(0, 200) + "..." : response.body}');

      if (response.statusCode == 200) {
        final dynamic jsonData = json.decode(response.body);
        
        // Handle different response formats
        List<dynamic> dataList;
        
        if (jsonData is List) {
          // Direct array response: [{"id": 1, "name": "John"}, ...]
          dataList = jsonData;
        } else if (jsonData is Map<String, dynamic>) {
          if (jsonData.containsKey('data')) {
            // Wrapped response: {"data": [...], "success": true}
            dataList = jsonData['data'] as List<dynamic>? ?? [];
          } else if (jsonData.containsKey('users')) {
            // Named array: {"users": [...]}
            dataList = jsonData['users'] as List<dynamic>? ?? [];
          } else if (jsonData.containsKey('results')) {
            // Search results: {"results": [...]}
            dataList = jsonData['results'] as List<dynamic>? ?? [];
          } else {
            // Single object wrapped in map, treat as single item list
            dataList = [jsonData];
          }
        } else {
          throw FormatException('Invalid response format: expected List or Map');
        }

        final List<ProfileModel> profiles = dataList
            .where((item) => item is Map<String, dynamic>)
            .map((json) {
              try {
                return ProfileModel.fromJson(json as Map<String, dynamic>);
              } catch (e) {
                print('⚠️ Failed to parse profile: $json, error: $e');
                return null;
              }
            })
            .where((profile) => profile != null)
            .cast<ProfileModel>()
            .toList();
            
        print('✅ Successfully loaded ${profiles.length} profiles');
        return profiles;
        
      } else if (response.statusCode == 503) {
        final errorData = _tryParseJson(response.body);
        final errorMessage = errorData['details'] ?? errorData['error'] ?? 'Profile service is unavailable';
        throw Exception('Service Unavailable: $errorMessage');
        
      } else if (response.statusCode == 404) {
        print('⚠️ Endpoint not found (404) - returning empty list');
        return [];
        
      } else if (response.statusCode == 408) {
        throw Exception('Request Timeout: The server took too long to respond');
        
      } else {
        final errorData = _tryParseJson(response.body);
        final errorMessage = errorData['error'] ?? errorData['message'] ?? 'Unknown error';
        throw Exception('HTTP ${response.statusCode}: $errorMessage');
      }
      
    } on http.ClientException catch (e) {
      print('❌ Network error: $e');
      throw Exception('Network Error: Cannot connect to server. Please check your internet connection and server status.');
      
    } on FormatException catch (e) {
      print('❌ JSON parsing error: $e');
      throw Exception('Invalid Response: Server returned invalid data format');
      
    } catch (e) {
      print('❌ Unexpected error: $e');
      if (e.toString().contains('Connection refused')) {
        throw Exception('Connection Refused: API Gateway is not running on $_baseUrl');
      } else if (e.toString().contains('timeout')) {
        throw Exception('Timeout: Server took too long to respond');
      } else {
        throw Exception('Failed to load profiles: ${e.toString()}');
      }
    }
  }

  /// Test koneksi ke API Gateway
  static Future<bool> testConnection() async {
    try {
      print('🔍 Testing connection to: $_baseUrl/health');
      
      final response = await http.get(
        Uri.parse('$_baseUrl/health'),
        headers: _headers,
      ).timeout(const Duration(seconds: 10));

      print('📡 Health check status: ${response.statusCode}');
      return response.statusCode == 200;
    } catch (e) {
      print('❌ Connection test failed: $e');
      return false;
    }
  }

  /// Get detailed service status
  static Future<Map<String, ServiceStatus>> getServiceStatus() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/debug/services'),
        headers: _headers,
      ).timeout(_timeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final results = data['results'] as Map<String, dynamic>? ?? {};
        
        final Map<String, ServiceStatus> services = {};
        results.forEach((key, value) {
          services[key] = ServiceStatus.fromJson({
            'service_name': key,
            'status': value['status'] ?? 'unknown',
            'url': value['url'],
            'error': value['error'],
            'response_time': value['response_time'],
          });
        });
        
        return services;
      } else {
        throw Exception('Debug endpoint not available');
      }
    } catch (e) {
      print('❌ Service status check failed: $e');
      return {};
    }
  }

  /// Create a new profile (jika API mendukung)
  static Future<ProfileModel> createProfile(ProfileModel profile) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/users'),
        headers: _headers,
        body: json.encode(profile.toJson()),
      ).timeout(_timeout);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonData = json.decode(response.body);
        return ProfileModel.fromJson(jsonData);
      } else {
        final errorData = _tryParseJson(response.body);
        throw Exception('Failed to create profile: ${errorData['error'] ?? 'Unknown error'}');
      }
    } catch (e) {
      throw Exception('Failed to create profile: $e');
    }
  }

  /// Update existing profile (jika API mendukung)
  static Future<ProfileModel> updateProfile(int id, ProfileModel profile) async {
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/users/$id'),
        headers: _headers,
        body: json.encode(profile.toJson()),
      ).timeout(_timeout);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return ProfileModel.fromJson(jsonData);
      } else {
        final errorData = _tryParseJson(response.body);
        throw Exception('Failed to update profile: ${errorData['error'] ?? 'Unknown error'}');
      }
    } catch (e) {
      throw Exception('Failed to update profile: $e');
    }
  }

  /// Delete profile (jika API mendukung)
  static Future<bool> deleteProfile(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl/users/$id'),
        headers: _headers,
      ).timeout(_timeout);

      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      throw Exception('Failed to delete profile: $e');
    }
  }

  /// Helper method untuk parse JSON dengan error handling
  static Map<String, dynamic> _tryParseJson(String body) {
    try {
      final parsed = json.decode(body);
      if (parsed is Map<String, dynamic>) {
        return parsed;
      } else {
        return {'raw_response': body};
      }
    } catch (e) {
      return {'raw_response': body, 'parse_error': e.toString()};
    }
  }
}