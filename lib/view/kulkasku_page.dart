// views/ingredients_list_view.dart
import 'package:flutter/material.dart';
import '../models/kulkasku_model.dart';
import '../services/ingredient_service.dart';
import '../services/kulkasku_service.dart';
import 'addIngredientsview.dart';
import 'EditIngredientsView.dart';

class Kulkaskuview extends StatefulWidget {
  final int userId;
  const Kulkaskuview({super.key, required this.userId});
  @override
  _KulkaskuviewState createState() => _KulkaskuviewState();
}

class _KulkaskuviewState extends State<Kulkaskuview> {
  late final IngredientService _ingredientService;
  List<Ingredient> _ingredients = [];
  bool _isLoading = false;

  @override
void initState() {
  super.initState();

  final apiService = ApiService(
    userId: widget.userId,
  );

  _ingredientService = IngredientService(apiService: apiService);

  _loadIngredients();
}

  Future<void> _loadIngredients() async {
    setState(() => _isLoading = true);
    try {
      final ingredients = await _ingredientService.getAllIngredients();
      setState(() => _ingredients = ingredients);
    } catch (e) {
      _showErrorSnackBar('Failed to load ingredients');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteIngredient(String id) async {
    final confirmed = await _showDeleteConfirmation();
    if (confirmed == true) {
      final success = await _ingredientService.deleteIngredient(id);
      if (success) {
        _showSuccessSnackBar('Ingredient deleted successfully');
        _loadIngredients();
      } else {
        _showErrorSnackBar('Failed to delete ingredient');
      }
    }
  }

  Future<bool?> _showDeleteConfirmation() {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Ingredient'),
        content: Text('Are you sure you want to delete this ingredient?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Delete'),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
          ),
        ],
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Ingredients'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _ingredients.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.kitchen, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'No ingredients found',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Add some ingredients to get started!',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadIngredients,
                  child: ListView.builder(
                    itemCount: _ingredients.length,
                    itemBuilder: (context, index) {
                      final ingredient = _ingredients[index];
                      return Card(
                        margin:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.blue,
                            child: Text(
                              ingredient.name.isNotEmpty
                                  ? ingredient.name[0].toUpperCase()
                                  : '?',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          title: Text(
                            ingredient.name,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            '${ingredient.quantity} ${ingredient.unit}',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                          trailing: PopupMenuButton(
                            onSelected: (value) {
                              if (value == 'edit') {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => EditIngredientView(
                                      ingredient: ingredient,
                                      ingredientService: _ingredientService,
                                      onIngredientUpdated: _loadIngredients,
                                    ),
                                  ),
                                );
                              } else if (value == 'delete') {
                                _deleteIngredient(ingredient.id);
                              }
                            },
                            itemBuilder: (context) => [
                              PopupMenuItem(
                                value: 'edit',
                                child: Row(
                                  children: [
                                    Icon(Icons.edit, color: Colors.blue),
                                    SizedBox(width: 8),
                                    Text('Edit'),
                                  ],
                                ),
                              ),
                              PopupMenuItem(
                                value: 'delete',
                                child: Row(
                                  children: [
                                    Icon(Icons.delete, color: Colors.red),
                                    SizedBox(width: 8),
                                    Text('Delete'),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddIngredientView(
                ingredientService: _ingredientService,
                onIngredientAdded: _loadIngredients,
              ),
            ),
          );
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
    );
  }
}
