import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth.service.dart';
import '../../shared/components/success-dialog.component.dart';

class SignUpDriverView extends StatefulWidget {
  const SignUpDriverView({super.key});

  @override
  State<SignUpDriverView> createState() => _SignUpDriverViewState();
}

class _SignUpDriverViewState extends State<SignUpDriverView> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _dniController = TextEditingController();

  final AuthService _authService = AuthService();
  bool _isLoading = false;
  String _responseMessage = '';
  bool _passwordVisible = false;
  bool _confirmPasswordVisible = false;
  final _formKey = GlobalKey<FormState>();

  Future<void> _signUp(BuildContext context) async {
    if (_formKey.currentState?.validate() != true) {
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      setState(() {
        _responseMessage = 'Passwords do not match.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _responseMessage = 'Registering user, please wait...';
    });

    try {
      final userData = {
        'email': _emailController.text,
        'password': _passwordController.text,
        'fullName': _fullNameController.text,
        'city': _cityController.text,
        'country': _countryController.text,
        'phone': _phoneController.text,
        'dni': _dniController.text
      };

      final response = await _authService.singUp(userData);

      if (response.containsKey('id')) {

        setState(() {
          _isLoading = false;
          _responseMessage = 'Successfully registered as a driver!';
        });

        SuccessDialog.show(
          context: context,
          icon: Icons.check_circle,
          message: 'Successfully registered as a driver!',
          buttonLabel: 'Go to Login',
          routeToNavigate: '/login',
        );

      } else {
        throw Exception('Invalid response from server');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _responseMessage = 'Error registering user: ${e.toString()}';
      });
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    IconData? prefixIcon,
    bool obscureText = false,
    bool isPassword = false,
    bool isVisible = false,
    bool isEmail = false,
    bool isPhone = false,
    bool isDNI = false,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword && !isVisible,
      keyboardType: isEmail
          ? TextInputType.emailAddress
          : isPhone
              ? TextInputType.phone
              : isDNI
                  ? TextInputType.number
                  : TextInputType.text,
      validator: validator ?? (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter $labelText';
        }
        if (isEmail && !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
          return 'Enter a valid email address';
        }
        if (isPassword && value.length < 6) {
          return 'Password must be at least 6 characters long';
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: const TextStyle(color: Color(0xFF1D4ED8)),
        prefixIcon: prefixIcon != null ? Icon(prefixIcon, color: const Color(0xFF3B82F6)) : null,
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  isVisible ? Icons.visibility : Icons.visibility_off,
                  color: const Color(0xFF3B82F6),
                ),
                onPressed: () {
                  setState(() {
                    if (controller == _passwordController) {
                      _passwordVisible = !_passwordVisible;
                    } else if (controller == _confirmPasswordController) {
                      _confirmPasswordVisible = !_confirmPasswordVisible;
                    }
                  });
                },
              )
            : null,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF3B82F6)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF1D4ED8), width: 2.0),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.red, width: 2.0),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          vertical: 16.0,
          horizontal: 12.0,
        ),
      ),
      style: const TextStyle(color: Colors.black87),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF3B82F6),
      appBar: AppBar(
        title: const Text('Driver Sign Up'),
        backgroundColor: const Color(0xFF3B82F6),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Container(
              padding: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    spreadRadius: 2,
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildTextField(
                      controller: _fullNameController,
                      labelText: 'Full Name',
                      prefixIcon: Icons.person,
                    ),
                    const SizedBox(height: 15),
                    _buildTextField(
                      controller: _emailController,
                      labelText: 'Email',
                      prefixIcon: Icons.email,
                      isEmail: true,
                    ),
                    const SizedBox(height: 15),
                    _buildTextField(
                      controller: _passwordController,
                      labelText: 'Password',
                      prefixIcon: Icons.lock,
                      isPassword: true,
                      isVisible: _passwordVisible,
                    ),
                    const SizedBox(height: 15),
                    _buildTextField(
                      controller: _confirmPasswordController,
                      labelText: 'Confirm Password',
                      prefixIcon: Icons.lock_outline,
                      isPassword: true,
                      isVisible: _confirmPasswordVisible,
                    ),
                    const SizedBox(height: 15),
                    _buildTextField(
                      controller: _phoneController,
                      labelText: 'Phone',
                      prefixIcon: Icons.phone,
                      isPhone: true,
                    ),
                    const SizedBox(height: 15),
                    _buildTextField(
                      controller: _dniController,
                      labelText: 'DNI',
                      prefixIcon: Icons.assignment_ind,
                      isDNI: true,
                    ),
                    const SizedBox(height: 15),
                    _buildTextField(
                      controller: _cityController,
                      labelText: 'City',
                      prefixIcon: Icons.location_city,
                    ),
                    const SizedBox(height: 15),
                    _buildTextField(
                      controller: _countryController,
                      labelText: 'Country',
                      prefixIcon: Icons.flag,
                    ),
                    const SizedBox(height: 25),
                    _isLoading
                        ? const Center(child: CircularProgressIndicator(color: Colors.white))
                        : ElevatedButton(
                            onPressed: () => _signUp(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1D4ED8),
                              padding: const EdgeInsets.symmetric(
                                vertical: 15,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30.0),
                              ),
                              elevation: 4,
                              shadowColor: Colors.black.withOpacity(0.3),
                            ),
                            child: const Text(
                              'Register',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                    const SizedBox(height: 15),
                    if (_responseMessage.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: _responseMessage.contains('Error')
                              ? Colors.red.withOpacity(0.2)
                              : Colors.green.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          _responseMessage,
                          style: TextStyle(
                            color: _responseMessage.contains('Error') ? Colors.red[200] : Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    const SizedBox(height: 15),
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacementNamed(context, '/login');
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white,
                      ),
                      child: const Text(
                        'Already have an account? Sign In',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
