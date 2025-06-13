import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/profile_viewmodel.dart';
import '../models/profile_model.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ProfileViewModel()..loadProfiles(),
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
                              'Service History',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 12),
                            Expanded(child: _buildServiceHistoryList()),
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

  Widget _buildServiceHistoryList() {
    final dummyHistory = List.generate(
      5,
      (index) => {
        'title': 'Service #${index + 1}',
        'description': 'Detail of service performed...',
        'date': '2025-06-${10 + index}'
      },
    );

    return ListView.builder(
      itemCount: dummyHistory.length,
      itemBuilder: (context, index) {
        final item = dummyHistory[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: const Icon(Icons.history, color: Colors.blue),
            title: Text(item['title']!),
            subtitle: Text(item['description']!),
            trailing:
                Text(item['date']!, style: const TextStyle(color: Colors.grey)),
          ),
        );
      },
    );
  }
}
