import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../components/driver_details.dart';
import '../models/driver.model.dart';
import '../services/driver.service.dart';
import '../../shared/components/navigator-bar.dart';

class DriverDetailsPage extends StatefulWidget {
  const DriverDetailsPage({Key? key}) : super(key: key);

  @override
  State<DriverDetailsPage> createState() => _DriverDetailsPageState();
}

class _DriverDetailsPageState extends State<DriverDetailsPage> {
  final DriverService _driverService = DriverService();
  Driver? _driver;
  bool _isLoading = true;
  String _errorMessage = '';
  int _selectedIndex = 3;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      if (index == 0) {
        Navigator.pushReplacementNamed(context, '/home');
      } else if (index == 1) {
        Navigator.pushReplacementNamed(context, '/reservations');
      } else if (index == 2) {
        Navigator.pushReplacementNamed(context, '/reviews');
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _loadDriverDetails();
  }

  Future<void> _loadDriverDetails() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('userId');

      if (userId == null) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'User ID not found. Please log in again.';
        });
        return;
      }

      final driverData = await _driverService.getById(userId);
      
      setState(() {
        _driver = Driver.fromJson(driverData);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error loading driver details: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Driver Profile'),
        backgroundColor: Colors.blue,
      ),
      body: RefreshIndicator(
        onRefresh: _loadDriverDetails,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                if (_isLoading)
                  const Center(
                    child: CircularProgressIndicator(),
                  )
                else if (_errorMessage.isNotEmpty)
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          color: Colors.red,
                          size: 60,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _errorMessage,
                          style: const TextStyle(color: Colors.red),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loadDriverDetails,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  )
                else if (_driver == null)
                  const Center(
                    child: Text(
                      'Driver details not available.',
                      style: TextStyle(fontSize: 18),
                    ),
                  )
                else
                  Column(
                    children: [
                      const Center(
                        child: CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.blue,
                          child: Icon(
                            Icons.person,
                            size: 60,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      DriverDetails(driver: _driver!),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/login');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                          ),
                          child: const Text(
                            'Log Out',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: NavigatorBar(
        selectedIndex: _selectedIndex,
        onItemSelected: _onItemTapped,
      ),
    );
  }
}
