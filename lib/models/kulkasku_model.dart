class Ingredient {
  final String id;
  final String name;
  final int quantity;
  final String unit;
  final String userId;

  Ingredient({
    required this.id,
    required this.name,
    required this.quantity,
    required this.unit,
    required this.userId,
  });

  factory Ingredient.fromJson(Map<String, dynamic> json) {
    return Ingredient(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      quantity: json['quantity'] ?? 0,
      unit: json['unit'] ?? '',
      userId: json['user_id'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'quantity': quantity,
      'unit': unit,
      'user_id': userId,
    };
  }

  Ingredient copyWith({
    String? id,
    String? name,
    int? quantity,
    String? unit,
    String? userId,
  }) {
    return Ingredient(
      id: id ?? this.id,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      userId: userId ?? this.userId,
    );
  }
}
