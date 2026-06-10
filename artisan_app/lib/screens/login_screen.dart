import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'home_screen.dart'; // We'll keep this as Artisan Dashboard for now
import 'customer_dashboard.dart';
import '../services/api_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final ApiService _apiService = ApiService();
  final TextEditingController _usernameController = TextEditingController(text: 'Sahil');
  String _selectedRole = 'artisan';

  void _handleLogin() async {
    final user = await _apiService.login(_usernameController.text, _selectedRole);
    if (user != null) {
      if (_selectedRole == 'artisan') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const CustomerDashboard()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('🧵', style: TextStyle(fontSize: 80)),
              const SizedBox(height: 24),
              Text('Artisan Intelligence', 
                style: Theme.of(context).textTheme.displayMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text('Bridging Tradition & Technology', 
                style: TextStyle(color: AppTheme.textMuted, fontSize: 16)),
              const SizedBox(height: 60),
              
              TextField(
                controller: _usernameController,
                style: const TextStyle(color: Colors.white),
                decoration: AppDecorations.inputDecoration('Username', Icons.person),
              ),
              const SizedBox(height: 24),
              
              Row(
                children: [
                  Expanded(
                    child: _roleOption('artisan', '👨‍🎨 Artisan'),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _roleOption('customer', '🛍️ Customer'),
                  ),
                ],
              ),
              const SizedBox(height: 48),
              
              ElevatedButton(
                onPressed: _handleLogin,
                style: AppDecorations.primaryButton,
                child: const SizedBox(
                  width: double.infinity,
                  child: Center(child: Text('Login')),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _roleOption(String role, String label) {
    bool isSelected = _selectedRole == role;
    return GestureDetector(
      onTap: () => setState(() => _selectedRole = role),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryColor.withOpacity(0.2) : AppTheme.bgCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppTheme.primaryColor : Colors.white.withOpacity(0.1),
            width: 2,
          ),
        ),
        child: Center(
          child: Text(label, style: TextStyle(
            color: isSelected ? Colors.white : AppTheme.textMuted,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          )),
        ),
      ),
    );
  }
}
