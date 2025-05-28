import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../parking-management/components/parking-spot-viewer.dart';
import '../../parking-management/models/parking.entity.dart';
import '../services/reservation.service.dart';

class ParkingReservationPage extends StatefulWidget {
  final Parking parking;

  const ParkingReservationPage({super.key, required this.parking});

  @override
  State<ParkingReservationPage> createState() => _ParkingReservationPageState();
}

class _ParkingReservationPageState extends State<ParkingReservationPage> {
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  String _vehiclePlate = '';
  double _totalHours = 0.0;
  Map<String, dynamic>? _selectedSpot;
  final ReservationService _reservationService = ReservationService();

  double _calculateTotal() {
    if (_startTime == null || _endTime == null || _selectedSpot == null) {
      return 0.0;
    }

    final startMinutes = _startTime!.hour * 60 + _startTime!.minute;
    final endMinutes = _endTime!.hour * 60 + _endTime!.minute;

    _totalHours = (endMinutes - startMinutes) / 60.0;

    return _totalHours > 0 ? _totalHours * widget.parking.ratePerHour : 0.0;
  }

  Future<void> _pickStartTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _startTime ?? TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _startTime = picked;
      });
    }
  }

  Future<void> _pickEndTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _endTime ?? TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _endTime = picked;
      });
    }
  }

  Future<String> _convertValueTimeTo24HourFormatAndString(value) async {
    if (value == null) return '';
    final now = DateTime.now();
    final dateTime = DateTime(
      now.year,
      now.month,
      now.day,
      value.hour,
      value.minute,
    );

    // Formatear hora y minuto con dos dígitos
    final String hour = dateTime.hour.toString().padLeft(2, '0');
    final String minute = dateTime.minute.toString().padLeft(2, '0');
    final formattedTime = '$hour:$minute';

    print('Converted time: $formattedTime');
    return formattedTime;
  }

  void _onSpotSelected(Map<String, dynamic>? spot) {
    setState(() {
      _selectedSpot = spot;
    });
  }

  void _reserveSpot() async {
    if (_selectedSpot == null || _startTime == null || _endTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please complete all fields before reserving.'),
        ),
      );
      return;
    }
    if (_startTime == _endTime) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Start time and end time cannot be the same.'),
        ),
      );
      return;
    }
    if (_endTime!.hour < _startTime!.hour ||
        (_endTime!.hour == _startTime!.hour &&
            _endTime!.minute <= _startTime!.minute)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('End time must be after start time.')),
      );
      return;
    }
    if (_vehiclePlate.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your vehicle plate.')),
      );
      return;
    }

    // Aquí se puede hacer la llamada al backend para reservar
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final driverId = prefs.getInt('userId');
    final parkingId = widget.parking.id;
    final spotId = _selectedSpot!['id'];
    final reservationData = {
      'driverId': driverId,
      'vehiclePlate': _vehiclePlate,
      'parkingId': parkingId,
      'parkingSpotId': spotId.toString(),
      'date': DateTime.now().toIso8601String(),
      'startTime': await _convertValueTimeTo24HourFormatAndString(_startTime),
      'endTime': await _convertValueTimeTo24HourFormatAndString(_endTime),
    };
    try {
      print(reservationData);
      await _reservationService.post(reservationData);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error reserving spot: $e')),
      );
      return;
    }


    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Reservation successful!')));
  }

  @override
  Widget build(BuildContext context) {
    final total = _calculateTotal();

    return Scaffold(
      appBar: AppBar(title: Text(widget.parking.name)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Time and plate inputs
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Vehicle Plate',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.directions_car),
                    hintText: 'ABC-123',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _vehiclePlate = value;
                    });
                  },
                ),
                const SizedBox(height: 24),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Start Time',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.access_time),
                          onPressed: _pickStartTime,
                          label: Text(
                            _startTime == null
                                ? 'Select start time'
                                : _startTime!.format(context),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'End Time',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.access_time),
                          onPressed: _pickEndTime,
                          label: Text(
                            _endTime == null
                                ? 'Select end time'
                                : _endTime!.format(context),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
            const SizedBox(height: 1),

            // Parking spot viewer
            Expanded(
              child: ParkingSpotViewer(
                parking: widget.parking,
                onSpotSelected: _onSpotSelected,
              ),
            ),

            const SizedBox(height: 40),

            // Selected spot
            Text(
              _selectedSpot != null
                  ? 'Selected Spot: ${_selectedSpot!['label']}'
                  : 'No spot selected',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 20),

            // Total
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      '\$${_calculateTotal().toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 20, color: Colors.black),
                    ),
                    Text(
                      ' / ${_totalHours.toStringAsFixed(2)} hours',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.lightBlue,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Reserve button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _reserveSpot,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: const Color(0xFF3B82F6),
                  textStyle: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                child: const Text(
                  'Reserve',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
