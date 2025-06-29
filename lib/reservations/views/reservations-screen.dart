import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smartparking_mobile_application/shared/components/navigator-bar.dart';
import '../components/reservation-list.dart';

class ReservationsScreen extends StatefulWidget {
  const ReservationsScreen({super.key});

  @override
  State<ReservationsScreen> createState() => _ReservationsScreenState();
}

class _ReservationsScreenState extends State<ReservationsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _statusTabs = [
    'PENDING',
    'CONFIRMED',
    'COMPLETED',
    'CANCELED',
  ];
  int? driverId;
  bool _isLoading = true;
  int _selectedIndex = 1;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _statusTabs.length, vsync: this);
    _loadDriverId();
  }

  Future<void> _loadDriverId() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      int? id = prefs.getInt('userId');

      setState(() {
        driverId = id;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      if (index == 0) {
        Navigator.pushReplacementNamed(context, '/home');
      } else if (index == 2) {
        Navigator.pushReplacementNamed(context, '/profile');
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Reservations'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: Theme.of(context).primaryColor,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Theme.of(context).primaryColor,
          tabs: [
            Tab(text: _statusTabs[0].toUpperCase()), // PENDING
            Tab(text: _statusTabs[1].toUpperCase()), // CONFIRMED
            Tab(text: _statusTabs[2].toUpperCase()), // COMPLETED
            Tab(text: 'CANCELED'), // CANCELED
          ],
        ),
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : driverId == null
              ? const Center(
                child: Text('No driver ID found. Please log in again.'),
              )
              : TabBarView(
                controller: _tabController,
                children:
                    _statusTabs.map((status) {
                      return ReservationList(
                        status: status,
                        driverId: driverId!,
                      );
                    }).toList(),
              ),
      bottomNavigationBar: NavigatorBar(
          selectedIndex: _selectedIndex,
          onItemSelected: _onItemTapped
      ),
    );
  }
}
