import 'package:flutter/material.dart';
import 'package:pembersih_kulkas_microservice_flutter/models/chat_model.dart';
import 'package:provider/provider.dart';
import '../viewmodels/profile_viewmodel.dart';
import '../models/profile_model.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) {
        final vm = ProfileViewModel();
        vm.loadProfiles();
        vm.loadRecipes(); // Panggil load resep di sini
        return vm;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('User Profile'),
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
        ),
        body: Consumer<ProfileViewModel>(
          builder: (context, viewModel, child) {
            final profile = viewModel.currentProfile;
            final error = viewModel.error;

            if (error != null) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(error),
                    backgroundColor: Colors.red,
                  ),
                );
                viewModel.clearError();
              });
            }

            return viewModel.isLoading
                ? const Center(child: CircularProgressIndicator())
                : profile == null
                    ? const Center(child: Text('No profile found.'))
                    : Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildProfileSection(profile),
                            const SizedBox(height: 24),
                            const Text(
                              'Recipe List',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 12),
                            Expanded(
                              child: _buildRecipeList(viewModel.recipes),
                            ),
                          ],
                        ),
                      );
          },
        ),
      ),
    );
  }

  Widget _buildProfileSection(Profile profile) {
    return Card(
      elevation: 2,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue,
          child: Text(
            profile.name.isNotEmpty ? profile.name[0].toUpperCase() : '?',
            style: const TextStyle(color: Colors.white),
          ),
        ),
        title: Text(profile.name,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(profile.email),
      ),
    );
  }

  Widget _buildRecipeList(List<Recipe> recipes) {
    if (recipes.isEmpty) {
      return const Center(child: Text('No recipes found.'));
    }

    return ListView.builder(
      itemCount: recipes.length,
      itemBuilder: (context, index) {
        final recipe = recipes[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: const Icon(Icons.restaurant_menu, color: Colors.green),
            title: Text(recipe.name),
            subtitle: Text('Waktu memasak: ${recipe.cookingTime}'),
            trailing: recipe.imageUrl != null
                ? Image.network(recipe.imageUrl!,
                    width: 50, height: 50, fit: BoxFit.cover)
                : null,
          ),
        );
      },
    );
  }
}
