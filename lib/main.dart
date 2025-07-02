import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'package:smartparking_mobile_application/parking-management/components/parking-map.component.dart';
import 'package:smartparking_mobile_application/reservations/views/reservation-payment.dart';
import 'package:smartparking_mobile_application/reservations/views/reservations-screen.dart';
import 'iam/views/log-in.view.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await Firebase.initializeApp();

  NotificationSettings settings = await FirebaseMessaging.instance.requestPermission();
  print('Permiso de notificación: ${settings.authorizationStatus}');

  String? token = await FirebaseMessaging.instance.getToken();
  print('FCM Token: $token');

  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    final title = message.notification?.title ?? 'Sin título';
    final body = message.notification?.body ?? 'Sin contenido';


    if (navigatorKey.currentState?.overlay?.context != null) {
      ScaffoldMessenger.of(navigatorKey.currentState!.overlay!.context).showSnackBar(
        SnackBar(
          content: Text("$title\n$body"),
          duration: Duration(seconds: 3),
        ),
      );
    }
  });

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
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
      home: LogInView(),
    );
  }
}
