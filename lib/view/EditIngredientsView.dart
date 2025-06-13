// views/edit_ingredient_view.dart
import 'package:flutter/material.dart';
import '../models/kulkasku_model.dart';
import '../services/ingredient_service.dart';

class EditIngredientView extends StatefulWidget {
  final Ingredient ingredient;
  final VoidCallback onIngredientUpdated;

  const EditIngredientView({
    Key? key,
    required this.ingredient,
    required this.onIngredientUpdated,
  }) : super(key: key);

  @override
  _EditIngredientViewState createState() => _EditIngredientViewState();
}

class _EditIngredientViewState extends State<EditIngredientView> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _quantityController;
  late String _selectedUnit;
  bool _isLoading = false;

  final List<String> _units = [
    'g',
    'kg',
    'ml',
    'l',
    'pcs',
    'cups',
    'tbsp',
    'tsp'
  ];

  final IngredientService _ingredientService = IngredientService();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.ingredient.name);
    _quantityController =
        TextEditingController(text: widget.ingredient.quantity.toString());
    _selectedUnit = widget.ingredient.unit;
  }

  Future<void> _updateIngredient() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final updatedIngredient = widget.ingredient.copyWith(
        name: _nameController.text.trim(),
        quantity: int.parse(_quantityController.text),
        unit: _selectedUnit,
      );

      final result = await _ingredientService.updateIngredient(
        widget.ingredient.id,
        updatedIngredient,
      );

      if (result != null) {
        widget.onIngredientUpdated();
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ingredient updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        _showErrorSnackBar('Failed to update ingredient');
      }
    } catch (e) {
      _showErrorSnackBar('Error: ${e.toString()}');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Ingredient'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Ingredient Name',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.restaurant),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter an ingredient name';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      controller: _quantityController,
                      decoration: InputDecoration(
                        labelText: 'Quantity',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.numbers),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter quantity';
                        }
                        if (int.tryParse(value) == null ||
                            int.parse(value) <= 0) {
                          return 'Please enter a valid positive number';
                        }
                        return null;
                      },
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedUnit,
                      decoration: InputDecoration(
                        labelText: 'Unit',
                        border: OutlineInputBorder(),
                      ),
                      items: _units.map((unit) {
                        return DropdownMenuItem(
                          value: unit,
                          child: Text(unit),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() => _selectedUnit = value!);
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _updateIngredient,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text('Update Ingredient', style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
