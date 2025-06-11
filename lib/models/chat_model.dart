class Ingredient {
  final String name;
  final String quantity;
  final String? unit;
  final String? notes;

  Ingredient({
    required this.name,
    required this.quantity,
    this.unit,
    this.notes,
  });

  factory Ingredient.fromJson(Map<String, dynamic> json) {
    return Ingredient(
      name: json['name'] ?? '',
      quantity: json['quantity'] ?? '',
      unit: json['unit'],
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'quantity': quantity,
      if (unit != null) 'unit': unit,
      if (notes != null) 'notes': notes,
    };
  }
}

class Recipe {
  final String? id;
  final String name;
  final List<Ingredient> ingredients;
  final List<String> steps;
  final String cookingTime;
  final String? cuisine;
  final String? dietaryInfo;
  final String? imageUrl;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final bool generatedByAI;

  Recipe({
    this.id,
    required this.name,
    required this.ingredients,
    required this.steps,
    required this.cookingTime,
    this.cuisine,
    this.dietaryInfo,
    this.imageUrl,
    this.createdAt,
    this.updatedAt,
    this.generatedByAI = false,
  });

  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      id: json['id'],
      name: json['name'] ?? '',
      ingredients: (json['ingredients'] as List?)
              ?.map((e) => Ingredient.fromJson(e))
              .toList() ??
          [],
      steps: List<String>.from(json['steps'] ?? []),
      cookingTime: json['cooking_time'] ?? '',
      cuisine: json['cuisine'],
      dietaryInfo: json['dietary_info'],
      imageUrl: json['image_url'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
      generatedByAI: json['generated_by_ai'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'ingredients': ingredients.map((e) => e.toJson()).toList(),
      'steps': steps,
      'cooking_time': cookingTime,
      if (cuisine != null) 'cuisine': cuisine,
      if (dietaryInfo != null) 'dietary_info': dietaryInfo,
      if (imageUrl != null) 'image_url': imageUrl,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
      'generated_by_ai': generatedByAI,
    };
  }
}
