import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:smartparking_mobile_application/parking-management/components/parking-map.component.dart';
import 'package:smartparking_mobile_application/reservations/views/reservation-payment.dart';
import 'package:smartparking_mobile_application/reservations/views/reservations-screen.dart';
import 'iam/views/log-in.view.dart';

// Configura instancia de notificaciones locales
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();

// Inicializa notificaciones locales
void setupFlutterNotifications() async {
  const AndroidInitializationSettings initializationSettingsAndroid =
  AndroidInitializationSettings('@mipmap/ic_launcher');

  const InitializationSettings initializationSettings =
  InitializationSettings(android: initializationSettingsAndroid);

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);
}

// Muestra notificación local al recibir push en primer plano
void showFlutterNotification(RemoteMessage message) {
  RemoteNotification? notification = message.notification;
  AndroidNotification? android = message.notification?.android;
  if (notification != null && android != null) {
    flutterLocalNotificationsPlugin.show(
      notification.hashCode,
      notification.title,
      notification.body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'default_channel',
          'SmartParking Notifications',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
    );
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Requerido para async
  await dotenv.load(fileName: ".env");
  await Firebase.initializeApp();

  // 🔔 Inicializa notificaciones locales
  setupFlutterNotifications();

  // 🔓 Solicita permiso de notificaciones
  NotificationSettings settings = await FirebaseMessaging.instance.requestPermission();
  print('🔔 Permiso de notificación: ${settings.authorizationStatus}');

  // 🔐 Obtén token de notificación
  String? token = await FirebaseMessaging.instance.getToken();
  print('✅ FCM Token: $token');

  // 🔔 Escucha mensajes en primer plano
  FirebaseMessaging.onMessage.listen(showFlutterNotification);

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
      home: LogInView(),
    );
  }
}
