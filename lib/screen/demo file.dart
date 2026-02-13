import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../../data/location_service.dart';
import '../widgets/map_view_widget.dart';

class MapHomeScreen extends StatefulWidget {
  const MapHomeScreen({super.key});

  @override
  State<MapHomeScreen> createState() => _MapHomeScreenState();
}

class _MapHomeScreenState extends State<MapHomeScreen> {
  final Completer<GoogleMapController> _mapController = Completer();
  final LocationService _locationService = LocationService();

  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  List<LatLng> _polylinePoints = [];
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTracking();
  }

  void _startTracking() async {
    bool hasPermission = await _locationService.checkAndRequestPermission();
    if (hasPermission) {
      _fetchAndUpdateLocation(); // প্রথমবার সাথে সাথে আপডেট
      // প্রতি ১০ সেকেন্ডে আপডেট করার জন্য টাইমার
      _timer = Timer.periodic(const Duration(seconds: 10), (t) => _fetchAndUpdateLocation());
    }
  }

  Future<void> _fetchAndUpdateLocation() async {
    Position position = await _locationService.getCurrentLocation();
    LatLng currentLatLng = LatLng(position.latitude, position.longitude);

    // ১. ম্যাপ অ্যানিমেশন
    final controller = await _mapController.future;
    controller.animateCamera(CameraUpdate.newLatLngZoom(currentLatLng, 15));

    // ২. পলিলাইন ডাটা আপডেট
    _polylinePoints.add(currentLatLng);

    setState(() {
      // ৩. মার্কার এবং ইনফো উইন্ডো
      _markers = {
        Marker(
          markerId: const MarkerId('current_location'),
          position: currentLatLng,
          infoWindow: InfoWindow(
            title: "My current location",
            snippet: "Lat: ${position.latitude}, Lng: ${position.longitude}",
          ),
        ),
      };

      // ৪. পলিলাইন ড্রয়িং
      _polylines = {
        Polyline(
          polylineId: const PolylineId('route'),
          points: _polylinePoints,
          color: Colors.blue,
          width: 5,
        ),
      };
    });
  }

  @override
  void dispose() {
    _timer?.cancel(); // অ্যাপ বন্ধ হলে টাইমার বন্ধ করা জরুরি (Memory Leak রোধে)
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Live Tracker")),
      body: MapViewWidget(
        markers: _markers,
        polylines: _polylines,
        initialPosition: const CameraPosition(target: LatLng(23.8103, 90.4125), zoom: 12),
        onMapCreated: (controller) => _mapController.complete(controller),
      ),
    );
  }
}
