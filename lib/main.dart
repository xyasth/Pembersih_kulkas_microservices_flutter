import 'package:flutter/material.dart';
import 'services/api_service.dart';
import 'view/homePage.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: RecipeListPage(),
    );
  }
}

class RecipeListPage extends StatefulWidget {
  const RecipeListPage({super.key});

  @override
  State<RecipeListPage> createState() => _RecipeListPageState();
}

class _RecipeListPageState extends State<RecipeListPage> {
  final ApiService apiService = ApiService();

  late Future<List<dynamic>> _recipes;

  @override
  void initState() {
    super.initState();
    _recipes = apiService.fetchRecipes(query: 'pasta');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Resep Masakan')),
      body: FutureBuilder<List<dynamic>>(
        future: _recipes,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            final recipes = snapshot.data!;
            return ListView.builder(
              itemCount: recipes.length,
              itemBuilder: (context, index) {
                final recipe = recipes[index];
                return ListTile(
                  leading: Image.network(recipe['image'], width: 60),
                  title: Text(recipe['title']),
                );
              },
            );
          }
        },
      ),
    );
  }
}
