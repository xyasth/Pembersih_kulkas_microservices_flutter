import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import '../models/recipe_detail_model.dart';
import '../services/recipe_detail_service.dart';

class RecipeDetailPage extends StatefulWidget {
  final int recipeId;
  final String recipeTitle;

  const RecipeDetailPage({
    super.key,
    required this.recipeId,
    required this.recipeTitle,
  });

  @override
  State<RecipeDetailPage> createState() => _RecipeDetailPageState();
}

class _RecipeDetailPageState extends State<RecipeDetailPage> {
  late Future<RecipeDetail> _recipeDetail;

  @override
  void initState() {
    super.initState();
    _recipeDetail = RecipeDetailService().fetchRecipeDetail(widget.recipeId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.recipeTitle,
          style: const TextStyle(fontSize: 16),
        ),
        backgroundColor: Colors.blue,
        centerTitle: true,
      ),
      body: FutureBuilder<RecipeDetail>(
        future: _recipeDetail,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Gagal memuat detail resep:\n${snapshot.error}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _recipeDetail = RecipeDetailService()
                            .fetchRecipeDetail(widget.recipeId);
                      });
                    },
                    child: const Text('Coba Lagi'),
                  ),
                ],
              ),
            );
          }

          final recipe = snapshot.data!;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Image
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    recipe.image,
                    height: 250,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    headers: {'User-Agent': 'mozilla'},
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return const SizedBox(
                        height: 250,
                        child: Center(child: CircularProgressIndicator()),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 250,
                        color: Colors.grey[300],
                        child: const Center(
                          child: Icon(Icons.broken_image,
                              size: 64, color: Colors.grey),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 16),

                // Title
                Text(
                  recipe.title,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 12),

                // Recipe Info Cards
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoCard(
                        Icons.timer,
                        '${recipe.readyInMinutes} min',
                        'Waktu',
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildInfoCard(
                        Icons.people,
                        '${recipe.servings}',
                        'Porsi',
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildInfoCard(
                        Icons.star,
                        '${recipe.spoonacularScore.toInt()}',
                        'Score',
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Diet Tags
                if (recipe.vegetarian || recipe.vegan || recipe.glutenFree || recipe.dairyFree)
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      if (recipe.vegetarian) _buildTag('Vegetarian', Colors.green),
                      if (recipe.vegan) _buildTag('Vegan', Colors.lightGreen),
                      if (recipe.glutenFree) _buildTag('Gluten Free', Colors.blue),
                      if (recipe.dairyFree) _buildTag('Dairy Free', Colors.blue),
                      if (recipe.veryHealthy) _buildTag('Very Healthy', Colors.teal),
                    ],
                  ),

                const SizedBox(height: 20),

                // Summary
                const Text(
                  'Ringkasan',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Html(
                  data: recipe.summary,
                  style: {
                    "body": Style(fontSize: FontSize(14)),
                  },
                ),

                const SizedBox(height: 20),

                // Ingredients
                const Text(
                  'Bahan-bahan',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                ...recipe.extendedIngredients.map((ingredient) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        if (ingredient.image.isNotEmpty)
                          Image.network(
                            'https://spoonacular.com/cdn/ingredients_100x100/${ingredient.image}',
                            width: 40,
                            height: 40,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(Icons.fastfood, size: 40);
                            },
                          ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            ingredient.original,
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),

                const SizedBox(height: 20),

                // Instructions
                const Text(
                  'Cara Membuat',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                
                if (recipe.analyzedInstructions.isNotEmpty)
                  ...recipe.analyzedInstructions.first.steps.map((step) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue[200]!),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              color: Colors.blue,
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Center(
                              child: Text(
                                '${step.number}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              step.step,
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList()
                else
                  Html(
                    data: recipe.instructions,
                    style: {
                      "body": Style(fontSize: FontSize(14)),
                    },
                  ),

                const SizedBox(height: 20),

                // Source URL
                if (recipe.sourceUrl.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue[200]!),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.link, color: Colors.blue),
                        const SizedBox(width: 8),
                        const Text('Sumber: '),
                        Expanded(
                          child: Text(
                            recipe.sourceUrl,
                            style: const TextStyle(
                              color: Colors.blue,
                              decoration: TextDecoration.underline,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoCard(IconData icon, String value, String label) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.blue),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        text,
        style: TextStyle(
          // color: color.shade700,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}