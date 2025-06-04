import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:smartparking_mobile_application/parking-management/components/parking-map.component.dart';
import 'package:smartparking_mobile_application/reservations/views/reservation-payment.dart';
import 'package:smartparking_mobile_application/reservations/views/reservations-screen.dart';
import 'iam/views/log-in.view.dart';

void main() async {
  await dotenv.load(fileName: ".env");

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/login',
      routes: {
        '/login': (context) => LogInView(),
        '/home': (context) => ParkingMap(),
        '/reservation-payment': (context) {
          final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
          return ReservationPayment(
            userId: args['userId'],
            reservationId: args['reservationId'],
            amount: args['amount'],
          );
        },
        '/reservations': (context) => ReservationsScreen(),
      },
      title: 'SmartParking App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),
      home: LogInView()
    );
  }
}
