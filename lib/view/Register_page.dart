import 'package:flutter/material.dart';
import '../../models/profile_model.dart';
import '../../services/profile_service.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;
  String? _errorMessage;

  Future<void> _register() async {
    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    try {
      final profile = Profile(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
      );

      await ProfileService().register(profile, _passwordController.text);
      Navigator.pop(context); // back to login
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Register")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: "Name")),
            TextField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: "Email")),
            TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: "Password")),
            const SizedBox(height: 20),
            if (_errorMessage != null)
              Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
            _loading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _register, child: const Text("Register")),
          ],
        ),
      ),
    );
  }
}
