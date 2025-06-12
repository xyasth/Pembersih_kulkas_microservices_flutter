// models/profile_model.dart
class Profile {
  final int? id;
  final String name;
  final String email;

  Profile({
    this.id,
    required this.name,
    required this.email,
  });

  // Factory constructor from JSON
  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      id: json['id'],
      name: json['name'] ?? '',
      email: json['email'] ?? '',
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'email': email,
    };
  }

  // Create a copy with updated fields
  Profile copyWith({
    int? id,
    String? name,
    String? email,
  }) {
    return Profile(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
    );
  }

  @override
  String toString() {
    return 'Profile{id: $id, name: $name, email: $email}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Profile &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          email == other.email;

  @override
  int get hashCode => id.hashCode ^ name.hashCode ^ email.hashCode;
}