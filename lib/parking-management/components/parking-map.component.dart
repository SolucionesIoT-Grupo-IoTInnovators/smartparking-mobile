import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geolocator/geolocator.dart' as gl;
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' as mp;
import 'package:smartparking_mobile_application/parking-management/components/parking-card.component.dart';
import 'package:smartparking_mobile_application/parking-management/services/parking.service.dart';
import '../models/parking.entity.dart';

class ParkingMap extends StatefulWidget {
  const ParkingMap({super.key});

  @override
  State<ParkingMap> createState() => _ParkingMapState();
}

class _ParkingMapState extends State<ParkingMap> {
  late mp.MapboxMap mapboxMap;
  mp.PointAnnotationManager? pointAnnotationManager;
  StreamSubscription<gl.Position>? userLocationStream;
  final ParkingService _parkingService = ParkingService();
  final List<Parking> _parkingList = [];
  final Map<String, Parking> _annotationIdToParking = {};

  bool _isMapReady = false;
  bool _isParkingDataReady = false;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  @override
  void dispose() {
    userLocationStream?.cancel();
    super.dispose();
  }

  Future<void> _initialize() async {
    mp.MapboxOptions.setAccessToken(dotenv.env['MAPBOX_ACCESS_TOKEN'] ?? '');
    await _fetchParkingData();
    await _startLocationTracking();
  }

  Future<void> _fetchParkingData() async {
    try {
      final data = await _parkingService.get();
      final parkings = data.map<Parking>((item) => Parking.fromJson(item)).toList();
      setState(() {
        _parkingList.addAll(parkings);
        _isParkingDataReady = true;
      });

      if (_isMapReady) {
        _createParkingMarkers();
      }
    } catch (e) {
      debugPrint('Error fetching parking data: $e');
    }
  }

  Future<void> _startLocationTracking() async {
    bool serviceEnabled = await gl.Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled.');
    }

    gl.LocationPermission permission = await gl.Geolocator.checkPermission();
    if (permission == gl.LocationPermission.denied) {
      permission = await gl.Geolocator.requestPermission();
      if (permission == gl.LocationPermission.denied) {
        throw Exception('Location permissions are denied.');
      }
    }

    if (permission == gl.LocationPermission.deniedForever) {
      throw Exception('Location permissions are permanently denied.');
    }

    const locationSettings = gl.LocationSettings(
      accuracy: gl.LocationAccuracy.high,
      distanceFilter: 100,
    );

    userLocationStream?.cancel();
    userLocationStream = gl.Geolocator.getPositionStream(
      locationSettings: locationSettings,
    ).listen((gl.Position position) {
      mapboxMap.setCamera(
        mp.CameraOptions(
          center: mp.Point(
            coordinates: mp.Position(position.longitude, position.latitude),
          ),
          zoom: 15,
        ),
      );
    });
  }

  Future<void> _onMapCreated(mp.MapboxMap mapboxMap) async {
    this.mapboxMap = mapboxMap;

    await mapboxMap.location.updateSettings(
      mp.LocationComponentSettings(enabled: true, pulsingEnabled: true),
    );

    pointAnnotationManager = await mapboxMap.annotations.createPointAnnotationManager();

    // Add tap listener
    pointAnnotationManager?.addOnPointAnnotationClickListener(
      _ParkingAnnotationClickListener(this),
    );

    setState(() {
      _isMapReady = true;
    });

    if (_isParkingDataReady) {
      _createParkingMarkers();
    }
  }

  Future<void> _createParkingMarkers() async {
    if (pointAnnotationManager == null) return;

    final Uint8List? icon = await _loadMarkerIcon('assets/icons/parking_icon.png');
    if (icon == null) return;

    for (var parking in _parkingList) {
      final marker = mp.PointAnnotationOptions(
        geometry: mp.Point(coordinates: mp.Position(parking.lng, parking.lat)),
        image: icon,
        iconSize: 2.0,
      );
      var createdAnnotation = await pointAnnotationManager!.create(marker);
      _annotationIdToParking[createdAnnotation.id!] = parking;
    }
  }

  Future<Uint8List?> _loadMarkerIcon(String path) async {
    try {
      final ByteData bytes = await rootBundle.load(path);
      return bytes.buffer.asUint8List();
    } catch (e) {
      debugPrint('Failed to load icon: $e');
      return null;
    }
  }

  Future<void> _goToUserLocation() async {
    try {
      final gl.Position position = await gl.Geolocator.getCurrentPosition();
      mapboxMap.setCamera(
        mp.CameraOptions(
          center: mp.Point(
            coordinates: mp.Position(position.longitude, position.latitude),
          ),
          zoom: 16,
        ),
      );
    } catch (e) {
      debugPrint('Failed to get user location: $e');
    }
  }

  void _showParkingDetails(Parking parking) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return ParkingCard(parking: parking);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            mp.MapWidget(
              onMapCreated: _onMapCreated,
              styleUri: mp.MapboxStyles.MAPBOX_STREETS,
            ),
            Positioned(
              bottom: 20,
              right: 20,
              child: FloatingActionButton(
                onPressed: _goToUserLocation,
                child: const Icon(Icons.my_location),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ParkingAnnotationClickListener extends mp.OnPointAnnotationClickListener {
  final _ParkingMapState mapState;

  _ParkingAnnotationClickListener(this.mapState);

  @override
  void onPointAnnotationClick(mp.PointAnnotation annotation) {
    final parking = mapState._annotationIdToParking[annotation.id!];
    if (parking != null) {
      mapState._showParkingDetails(parking);
    }
  }
}
