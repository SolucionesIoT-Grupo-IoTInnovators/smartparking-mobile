import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smartparking_mobile_application/parking-management/components/parking-map.component.dart';
import '../services/auth.service.dart';

class LogInView extends StatefulWidget {
  const LogInView({super.key});

  @override
  State<LogInView> createState() => _LogInViewState();
}

class _LogInViewState extends State<LogInView> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  String _responseMessage = '';

  Future<void> _logIn(BuildContext context) async {
    setState(() {
      _responseMessage = 'Attempting to sign in...';
    });
    print("Login attempt with email: ${_emailController.text}");

    try {
      print("Making API call to sign in...");
      final user = await _authService.logIn(
        _emailController.text,
        _passwordController.text,
      );

      print("Sign in response received: $user");

      // Check if token exists
      final token = user['token'];
      if (token == null) {
        setState(() {
          _responseMessage = 'Error: Authentication token not found.';
        });
        return;
      }

      // Check if userId exists
      final userId = user['id'];
      if (userId == null) {
        setState(() {
          _responseMessage = 'Error: User ID not found.';
        });
        return;
      }

      // Save authentication data
      print("Saving authentication data to SharedPreferences");
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('authToken', token);
      await prefs.setInt('userId', userId);

      setState(() {
        _responseMessage = 'Sign in successful. Welcome!';
      });
      print("Sign in successful for user ID: $userId");

      // Navigate to ParkingCard screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const ParkingMap()),
      );
    } catch (e) {
      print("Sign in error: $e");

      // More descriptive error messages based on exception
      String errorMessage = 'Error signing in. Please check your credentials.';
      if (e.toString().contains('SocketException') ||
          e.toString().contains('Connection refused')) {
        errorMessage = 'Network error. Please check your connection.';
      } else if (e.toString().contains('401')) {
        errorMessage = 'Invalid email or password.';
      } else if (e.toString().contains('timeout')) {
        errorMessage =
            'Server is taking too long to respond. Please try again.';
      }

      setState(() {
        _responseMessage = errorMessage;
      });
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    IconData? prefixIcon,
    bool obscureText = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: const TextStyle(color: Colors.black),
        prefixIcon:
            prefixIcon != null ? Icon(prefixIcon, color: Colors.black) : null,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.black),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.blueGrey, width: 2.0),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          vertical: 16.0,
          horizontal: 12.0,
        ),
      ),
      style: const TextStyle(color: Colors.black),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF60A5FA),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: 120,
                width: 180,
                decoration: BoxDecoration(
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.circular(12.0),
                  color: Colors.white,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12.0),
                  child: /*Icon(Icons.person, size: 80, color: Colors.blue[900]),*/
                  Image.asset(
                    'assets/images/smartparking_logo.jpeg',
                    fit: BoxFit.cover,
                  ),
                  /*child: Padding(
                    padding: const EdgeInsets.all(8.0),
                  ),*/
                ),
              ),
              const SizedBox(height: 30),
              _buildTextField(
                controller: _emailController,
                labelText: 'Email',
                prefixIcon: Icons.email,
              ),
              const SizedBox(height: 20),
              _buildTextField(
                controller: _passwordController,
                labelText: 'Password',
                prefixIcon: Icons.lock,
                obscureText: true,
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () => _logIn(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1D4ED8),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 70,
                    vertical: 15,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                ),
                child: const Text(
                  'Sign In',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                _responseMessage,
                style: const TextStyle(color: Colors.white),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () {},
                child: const Text(
                  'Forgot Password?',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
