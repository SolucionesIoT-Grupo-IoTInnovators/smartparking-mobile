import 'package:flutter/material.dart';
import 'package:smartparking_mobile_application/parking-management/services/parking.service.dart';

import '../models/reservation.entity.dart';

class ReservationCard extends StatefulWidget {
  final Reservation reservation;

  const ReservationCard({Key? key, required this.reservation})
    : super(key: key);

  @override
  State<ReservationCard> createState() => _ReservationCardState();
}

class _ReservationCardState extends State<ReservationCard> {
  String parkingName = '';
  String parkingImageUrl = '';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadParkingDetails();
  }

  Future<void> _loadParkingDetails() async {
    try {
      final parkingService = ParkingService();
      final parking = await parkingService.getById(
        widget.reservation.parkingId,
      );

      setState(() {
        if (parking.containsKey('name')) {
          parkingName = parking['name'] ?? 'Unknown Parking';
        } else {
          parkingName = 'Unknown Parking';
        }
        if (parking.containsKey('imageUrl')) {
          parkingImageUrl = parking['imageUrl'] ?? '';
        } else {
          parkingImageUrl = '';
        }
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        parkingName = 'Unknown Parking';
        parkingImageUrl = '';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final reservation = widget.reservation;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          // Navigate to reservation detail screen
        },
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.blue.shade100,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.local_parking, color: Colors.blue.shade800, size: 24),
                  const SizedBox(width: 10),
                  Text(
                    'Reserved Spot: ${reservation.spotLabel}',
                    //'Reserved Spot: P1',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade800,
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Parking name and status
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          isLoading ? 'Loading...' : parkingName,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getStatusColor(reservation.status),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          reservation.status,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Date and time
                  Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 16, color: Colors.blue),
                      const SizedBox(width: 6),
                      Text(reservation.date, style: TextStyle(color: Colors.grey.shade700)),
                      const SizedBox(width: 16),
                      const Icon(Icons.access_time, size: 16, color: Colors.blue),
                      const SizedBox(width: 6),
                      Text(
                        '${reservation.startTime} - ${reservation.endTime}',
                        style: TextStyle(color: Colors.grey.shade700),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Total amount
                  Row(
                    children: [
                      const Text(
                        'Total: ',
                        style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
                      ),
                      Text(
                        'S/ ${reservation.totalPrice.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.only(left: 12, right: 12, bottom: 12),
              child: reservation.status.toLowerCase() == 'pending'
                ? Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: OutlinedButton(
                          onPressed: () {
                            // Cancel action
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.grey.shade700,
                            side: BorderSide(color: Colors.grey.shade400),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: const Text('Cancel'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
                          onPressed: () {
                            // I'm here action
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            elevation: 3,
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.location_on),
                              SizedBox(width: 8),
                              Text(
                                "I'm here",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  )
                : Container(), // No se muestra nada si el status no es "pending"
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.blue;
    }
  }
}
