// pages/recipe_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/chat_viewmodel.dart';
import '../models/chat_model.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({Key? key}) : super(key: key);

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> with TickerProviderStateMixin {
  late TabController _tabController;

  // Form keys
  final _createFormKey = GlobalKey<FormState>();
  final _aiFormKey = GlobalKey<FormState>();

  // Controllers for adding ingredients and steps
  final _ingredientNameController = TextEditingController();
  final _ingredientQuantityController = TextEditingController();
  final _ingredientUnitController = TextEditingController();
  final _ingredientNotesController = TextEditingController();
  final _stepController = TextEditingController();
  final _aiIngredientController = TextEditingController();
  final _getRecipeIdController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _ingredientNameController.dispose();
    _ingredientQuantityController.dispose();
    _ingredientUnitController.dispose();
    _ingredientNotesController.dispose();
    _stepController.dispose();
    _aiIngredientController.dispose();
    _getRecipeIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => RecipeViewModel(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Recipe Manager'),
          backgroundColor: Colors.orange,
          foregroundColor: Colors.white,
          bottom: TabBar(
            controller: _tabController,
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: const [
              Tab(text: 'Create Recipe', icon: Icon(Icons.create)),
              Tab(text: 'AI Generate', icon: Icon(Icons.auto_awesome)),
              Tab(text: 'View Recipe', icon: Icon(Icons.visibility)),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildCreateRecipeTab(),
            _buildAIGenerateTab(),
            _buildViewRecipeTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildCreateRecipeTab() {
    return Consumer<RecipeViewModel>(
      builder: (context, viewModel, child) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _createFormKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Recipe Name
                TextFormField(
                  controller: viewModel.nameController,
                  decoration: const InputDecoration(
                    labelText: 'Recipe Name *',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => value?.trim().isEmpty == true
                      ? 'Recipe name is required'
                      : null,
                ),
                const SizedBox(height: 16),

                // Cooking Time
                TextFormField(
                  controller: viewModel.cookingTimeController,
                  decoration: const InputDecoration(
                    labelText: 'Cooking Time *',
                    border: OutlineInputBorder(),
                    hintText: 'e.g., 30 minutes',
                  ),
                  validator: (value) => value?.trim().isEmpty == true
                      ? 'Cooking time is required'
                      : null,
                ),
                const SizedBox(height: 16),

                // Optional fields
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: viewModel.cuisineController,
                        decoration: const InputDecoration(
                          labelText: 'Cuisine (Optional)',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextFormField(
                        controller: viewModel.dietController,
                        decoration: const InputDecoration(
                          labelText: 'Diet (Optional)',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Ingredients Section
                _buildIngredientsSection(viewModel),
                const SizedBox(height: 24),

                // Steps Section
                _buildStepsSection(viewModel),
                const SizedBox(height: 24),

                // Error message
                if (viewModel.error != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      border: Border.all(color: Colors.red.shade200),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      viewModel.error!,
                      style: TextStyle(color: Colors.red.shade700),
                    ),
                  ),

                // Create Recipe Button
                ElevatedButton(
                  onPressed: viewModel.isLoading
                      ? null
                      : () async {
                          if (_createFormKey.currentState!.validate()) {
                            final success = await viewModel.createRecipe();
                            if (success && mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Recipe created successfully!'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            }
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: viewModel.isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Create Recipe',
                          style: TextStyle(fontSize: 16)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildIngredientsSection(RecipeViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Ingredients *',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),

        // Add ingredient form
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: TextFormField(
                        controller: _ingredientNameController,
                        decoration: const InputDecoration(
                          labelText: 'Name',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextFormField(
                        controller: _ingredientQuantityController,
                        decoration: const InputDecoration(
                          labelText: 'Quantity',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _ingredientUnitController,
                        decoration: const InputDecoration(
                          labelText: 'Unit (Optional)',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextFormField(
                        controller: _ingredientNotesController,
                        decoration: const InputDecoration(
                          labelText: 'Notes (Optional)',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () {
                    viewModel.addIngredient(
                      _ingredientNameController.text,
                      _ingredientQuantityController.text,
                      _ingredientUnitController.text,
                      _ingredientNotesController.text,
                    );
                    _ingredientNameController.clear();
                    _ingredientQuantityController.clear();
                    _ingredientUnitController.clear();
                    _ingredientNotesController.clear();
                  },
                  child: const Text('Add Ingredient'),
                ),
              ],
            ),
          ),
        ),

        // Ingredients list
        if (viewModel.ingredients.isNotEmpty)
          Card(
            child: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'Added Ingredients',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: viewModel.ingredients.length,
                  itemBuilder: (context, index) {
                    final ingredient = viewModel.ingredients[index];
                    return ListTile(
                      title: Text(ingredient.name),
                      subtitle: Text(
                        '${ingredient.quantity}${ingredient.unit != null ? ' ${ingredient.unit}' : ''}${ingredient.notes != null ? ' - ${ingredient.notes}' : ''}',
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => viewModel.removeIngredient(index),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildStepsSection(RecipeViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Cooking Steps *',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),

        // Add step form
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextFormField(
                  controller: _stepController,
                  decoration: const InputDecoration(
                    labelText: 'Step Description',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () {
                    viewModel.addStep(_stepController.text);
                    _stepController.clear();
                  },
                  child: const Text('Add Step'),
                ),
              ],
            ),
          ),
        ),

        // Steps list
        if (viewModel.steps.isNotEmpty)
          Card(
            child: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'Cooking Steps',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: viewModel.steps.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      leading: CircleAvatar(
                        child: Text('${index + 1}'),
                      ),
                      title: Text(viewModel.steps[index]),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => viewModel.removeStep(index),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildAIGenerateTab() {
    return Consumer<RecipeViewModel>(
      builder: (context, viewModel, child) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _aiFormKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Generate Recipe with AI',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),

                // Add ingredients
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Ingredients *',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _aiIngredientController,
                                decoration: const InputDecoration(
                                  labelText: 'Add ingredient',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: () {
                                viewModel.addAIIngredient(
                                    _aiIngredientController.text);
                                _aiIngredientController.clear();
                              },
                              child: const Icon(Icons.add),
                            ),
                          ],
                        ),
                        if (viewModel.aiIngredients.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          Wrap(
                            spacing: 8,
                            children: viewModel.aiIngredients
                                .asMap()
                                .entries
                                .map((entry) {
                              return Chip(
                                label: Text(entry.value),
                                deleteIcon: const Icon(Icons.close),
                                onDeleted: () =>
                                    viewModel.removeAIIngredient(entry.key),
                              );
                            }).toList(),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Optional preferences
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: viewModel.cuisineController,
                        decoration: const InputDecoration(
                          labelText: 'Cuisine (Optional)',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextFormField(
                        controller: viewModel.dietController,
                        decoration: const InputDecoration(
                          labelText: 'Diet (Optional)',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Error message
                if (viewModel.error != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      border: Border.all(color: Colors.red.shade200),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      viewModel.error!,
                      style: TextStyle(color: Colors.red.shade700),
                    ),
                  ),

                // Generate button
                ElevatedButton(
                  onPressed: viewModel.isLoading
                      ? null
                      : () async {
                          final success = await viewModel.generateRecipe();
                          if (success && mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Recipe generated successfully!'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: viewModel.isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Generate Recipe',
                          style: TextStyle(fontSize: 16)),
                ),
                const SizedBox(height: 16),

                // Clear AI form button
                TextButton(
                  onPressed: () {
                    viewModel.clearAIForm();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Form cleared')),
                    );
                  },
                  child: const Text('Clear Form'),
                ),

                // Generated recipe display
                if (viewModel.generatedRecipe != null)
                  _buildGeneratedRecipeCard(viewModel.generatedRecipe!),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildGeneratedRecipeCard(Recipe recipe) {
    return Card(
      margin: const EdgeInsets.only(top: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.auto_awesome, color: Colors.orange),
                const SizedBox(width: 8),
                const Text(
                  'Generated Recipe',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Recipe name
            Text(
              recipe.name,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            // Cooking time
            Row(
              children: [
                const Icon(Icons.access_time, size: 16),
                const SizedBox(width: 4),
                Text('Cooking Time: ${recipe.cookingTime}'),
              ],
            ),
            const SizedBox(height: 16),

            // Ingredients
            const Text(
              'Ingredients:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...recipe.ingredients.map((ingredient) => Padding(
                  padding: const EdgeInsets.only(left: 16, bottom: 4),
                  child: Text(
                    '• ${ingredient.quantity}${ingredient.unit != null ? ' ${ingredient.unit}' : ''} ${ingredient.name}${ingredient.notes != null ? ' (${ingredient.notes})' : ''}',
                  ),
                )),
            const SizedBox(height: 16),

            // Steps
            const Text(
              'Instructions:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...recipe.steps.asMap().entries.map((entry) => Padding(
                  padding: const EdgeInsets.only(left: 16, bottom: 8),
                  child: Text('${entry.key + 1}. ${entry.value}'),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildViewRecipeTab() {
    return Consumer<RecipeViewModel>(
      builder: (context, viewModel, child) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'View Recipe',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              // Recipe ID input
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _getRecipeIdController,
                      decoration: const InputDecoration(
                        labelText: 'Recipe ID',
                        border: OutlineInputBorder(),
                        hintText: 'Enter recipe ID to view',
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: viewModel.isLoading
                        ? null
                        : () async {
                            if (_getRecipeIdController.text.trim().isNotEmpty) {
                              await viewModel.getRecipe(
                                  _getRecipeIdController.text.trim());
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                    ),
                    child: viewModel.isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text('Get Recipe'),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Error message
              if (viewModel.error != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    border: Border.all(color: Colors.red.shade200),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    viewModel.error!,
                    style: TextStyle(color: Colors.red.shade700),
                  ),
                ),

              // Recipe display
              Expanded(
                child: viewModel.currentRecipe != null
                    ? _buildRecipeDisplay(viewModel.currentRecipe!)
                    : const Center(
                        child: Text(
                          'Enter a recipe ID to view the recipe',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRecipeDisplay(Recipe recipe) {
    return SingleChildScrollView(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Recipe header
              Row(
                children: [
                  Icon(
                    recipe.generatedByAI
                        ? Icons.auto_awesome
                        : Icons.restaurant,
                    color: Colors.orange,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      recipe.name,
                      style: const TextStyle(
                          fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              if (recipe.generatedByAI)
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'AI Generated',
                    style: TextStyle(
                      color: Colors.orange.shade800,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              const SizedBox(height: 16),

              // Recipe details
              Row(
                children: [
                  const Icon(Icons.access_time, size: 16),
                  const SizedBox(width: 4),
                  Text('Cooking Time: ${recipe.cookingTime}'),
                ],
              ),
              if (recipe.cuisine != null) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.restaurant_menu, size: 16),
                    const SizedBox(width: 4),
                    Text('Cuisine: ${recipe.cuisine}'),
                  ],
                ),
              ],
              if (recipe.dietaryInfo != null) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.local_dining, size: 16),
                    const SizedBox(width: 4),
                    Text('Diet: ${recipe.dietaryInfo}'),
                  ],
                ),
              ],
              const SizedBox(height: 24),

              // Ingredients
              const Text(
                'Ingredients',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Card(
                color: Colors.grey.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: recipe.ingredients
                        .map((ingredient) => Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('• ',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  Expanded(
                                    child: Text(
                                      '${ingredient.quantity}${ingredient.unit != null ? ' ${ingredient.unit}' : ''} ${ingredient.name}${ingredient.notes != null ? ' (${ingredient.notes})' : ''}',
                                    ),
                                  ),
                                ],
                              ),
                            ))
                        .toList(),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Steps
              const Text(
                'Instructions',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Card(
                color: Colors.grey.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: recipe.steps
                        .asMap()
                        .entries
                        .map((entry) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CircleAvatar(
                                    radius: 12,
                                    backgroundColor: Colors.orange,
                                    child: Text(
                                      '${entry.key + 1}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(entry.value),
                                  ),
                                ],
                              ),
                            ))
                        .toList(),
                  ),
                ),
              ),

              // Recipe metadata
              if (recipe.createdAt != null) ...[
                const SizedBox(height: 16),
                Text(
                  'Created: ${_formatDate(recipe.createdAt!)}',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
