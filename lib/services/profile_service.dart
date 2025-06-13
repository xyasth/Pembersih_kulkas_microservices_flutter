// services/profile_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/profile_model.dart';

class ProfileService {
  static const String baseUrl = 'http://localhost:8000'; // Your API Gateway URL

  // Get all users/profiles
  Future<List<Profile>> getAllProfiles() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/users'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Profile.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load profiles: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Get user by ID
  Future<Profile> getProfile(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/users/$id'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Profile.fromJson(data);
      } else if (response.statusCode == 404) {
        throw Exception('Profile not found');
      } else {
        throw Exception('Failed to load profile: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Create new user
  Future<Profile> createProfile(Profile profile) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/users'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(profile.toJson()),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        return Profile.fromJson(data);
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['error'] ?? 'Failed to create profile');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Update user
  Future<Profile> updateProfile(Profile profile) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/users/${profile.id}'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(profile.toJson()),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Profile.fromJson(data);
      } else if (response.statusCode == 404) {
        throw Exception('Profile not found');
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['error'] ?? 'Failed to update profile');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Delete user
  Future<bool> deleteProfile(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/users/$id'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        return true;
      } else if (response.statusCode == 404) {
        throw Exception('Profile not found');
      } else {
        throw Exception('Failed to delete profile: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Search users by name or email
  Future<List<Profile>> searchProfiles(String query) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/users/search?q=$query'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Profile.fromJson(json)).toList();
      } else {
        throw Exception('Failed to search profiles: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Login
  Future<Profile> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Profile.fromJson(data['user']);
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['error'] ?? 'Login failed');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

// Register
  Future<Profile> register(Profile profile, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/users'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'name': profile.name,
          'email': profile.email,
          'password': password,
        }),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        return Profile.fromJson(data);
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['error'] ?? 'Registration failed');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
}
