class RecipeDetail {
  final int id;
  final String title;
  final String image;
  final int readyInMinutes;
  final int servings;
  final String sourceUrl;
  final bool vegetarian;
  final bool vegan;
  final bool glutenFree;
  final bool dairyFree;
  final bool veryHealthy;
  final double pricePerServing;
  final String summary;
  final List<String> cuisines;
  final List<String> dishTypes;
  final List<ExtendedIngredient> extendedIngredients;
  final String instructions;
  final List<AnalyzedInstruction> analyzedInstructions;
  final double spoonacularScore;

  RecipeDetail({
    required this.id,
    required this.title,
    required this.image,
    required this.readyInMinutes,
    required this.servings,
    required this.sourceUrl,
    required this.vegetarian,
    required this.vegan,
    required this.glutenFree,
    required this.dairyFree,
    required this.veryHealthy,
    required this.pricePerServing,
    required this.summary,
    required this.cuisines,
    required this.dishTypes,
    required this.extendedIngredients,
    required this.instructions,
    required this.analyzedInstructions,
    required this.spoonacularScore,
  });

  factory RecipeDetail.fromJson(Map<String, dynamic> json) {
    return RecipeDetail(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      image: json['image'] ?? '',
      readyInMinutes: json['readyInMinutes'] ?? 0,
      servings: json['servings'] ?? 0,
      sourceUrl: json['sourceUrl'] ?? '',
      vegetarian: json['vegetarian'] ?? false,
      vegan: json['vegan'] ?? false,
      glutenFree: json['glutenFree'] ?? false,
      dairyFree: json['dairyFree'] ?? false,
      veryHealthy: json['veryHealthy'] ?? false,
      pricePerServing: (json['pricePerServing'] ?? 0).toDouble(),
      summary: json['summary'] ?? '',
      cuisines: List<String>.from(json['cuisines'] ?? []),
      dishTypes: List<String>.from(json['dishTypes'] ?? []),
      extendedIngredients: (json['extendedIngredients'] as List? ?? [])
          .map((item) => ExtendedIngredient.fromJson(item))
          .toList(),
      instructions: json['instructions'] ?? '',
      analyzedInstructions: (json['analyzedInstructions'] as List? ?? [])
          .map((item) => AnalyzedInstruction.fromJson(item))
          .toList(),
      spoonacularScore: (json['spoonacularScore'] ?? 0).toDouble(),
    );
  }
}

class ExtendedIngredient {
  final int id;
  final String name;
  final String image;
  final double amount;
  final String unit;
  final String original;

  ExtendedIngredient({
    required this.id,
    required this.name,
    required this.image,
    required this.amount,
    required this.unit,
    required this.original,
  });

  factory ExtendedIngredient.fromJson(Map<String, dynamic> json) {
    return ExtendedIngredient(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      image: json['image'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      unit: json['unit'] ?? '',
      original: json['original'] ?? '',
    );
  }
}

class AnalyzedInstruction {
  final String name;
  final List<InstructionStep> steps;

  AnalyzedInstruction({
    required this.name,
    required this.steps,
  });

  factory AnalyzedInstruction.fromJson(Map<String, dynamic> json) {
    return AnalyzedInstruction(
      name: json['name'] ?? '',
      steps: (json['steps'] as List? ?? [])
          .map((item) => InstructionStep.fromJson(item))
          .toList(),
    );
  }
}

class InstructionStep {
  final int number;
  final String step;

  InstructionStep({
    required this.number,
    required this.step,
  });

  factory InstructionStep.fromJson(Map<String, dynamic> json) {
    return InstructionStep(
      number: json['number'] ?? 0,
      step: json['step'] ?? '',
    );
  }
}