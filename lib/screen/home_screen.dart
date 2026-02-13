import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

//AIzaSyBpD1p4hQ3su-aayuiQ226ZDXQRqK1cIok
// Google maps API key

class HomeScreen extends StatefulWidget {
   HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();

}

class _HomeScreenState extends State<HomeScreen> {
  //late  GoogleMapController _googleMapController;

  GoogleMapController? _googleMapController;
  LatLng _currentLocation = const LatLng(24.2200, 89.3809); // শুরুতে একটি ডিফল্ট ভ্যালু
  // এটি সব লোকেশন জমা রাখবে
  List<LatLng> _polylineCoordinates = [];


  Timer? _timer; // টাইমার ভেরিয়েবল
  @override
  void initState() {
    super.initState();
    // প্রথমে পারমিশন চেক হবে, তারপর টাইমার শুরু হবে
    _checkPermissionAndSetup();
  }

// পারমিশন চেক করার আলাদা ফাংশন
  Future<void> _checkPermissionAndSetup() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.whileInUse || permission == LocationPermission.always) {
      // পারমিশন থাকলে প্রথমবার লোকেশন আপডেট করি
      _updateUserLocation();

      // তারপর ১০ সেকেন্ডের টাইমার সেট করি
      _timer = Timer.periodic(const Duration(seconds: 10), (timer) {
        _updateUserLocation();
      });
    }
  }
  // ১. ইউজারের কারেন্ট লোকেশন পাওয়ার এবং ম্যাপ অ্যানিমেট করার ফাংশন
  Future<void> _updateUserLocation() async {
    // লোকেশন পারমিশন চেক করা
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // মার্কারের পজিশন আপডেট করার জন্য setState লাগবে
      setState(() {
        LatLng newLatLng = LatLng(position.latitude, position.longitude);
        _currentLocation = newLatLng;
        //_currentLocation = LatLng(position.latitude, position.longitude);
        // নতুন লোকেশনটি লিস্টে যোগ করছি যাতে আগেরটির সাথে কানেক্ট হয়
        _polylineCoordinates.add(newLatLng);
      });

      //  ক্যামেরা অ্যানিমেট করা
      _googleMapController?.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(position.latitude, position.longitude),
            zoom: 15, // একটু জুম করে দেখালে সুন্দর লাগে
          ),
        ),
      );
      print("Location updated: ${position.latitude}, ${position.longitude}");

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Home'),),
      body: GoogleMap(
        mapType: MapType.normal,
        zoomControlsEnabled: true,
        zoomGesturesEnabled: true,
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
        initialCameraPosition: CameraPosition(
          target: LatLng(24.2200, 89.3809),
        zoom: 14),
        onMapCreated: (GoogleMapController controller){
          _googleMapController = controller;
          _updateUserLocation();
        },

        markers: <Marker>{
          //Marker START

          Marker(markerId: const MarkerId('CurrentLocation'),
          position: _currentLocation,// এটি প্রতি ১০ সেকেন্ডে পরিবর্তন হবে
          //
          onTap: (){
            print('Tap on my home');
          },
            visible: true,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
            infoWindow: InfoWindow(title: 'My current location ',
                snippet: '${_currentLocation.latitude}, ${_currentLocation.longitude}', // এখানে Lat এবং Lng দেখাবে
                onTap: (){
                  print('Info window tapped!');
                }
            ),
          ),//Marker end
           //Marker START
          Marker(markerId: MarkerId('My Collage'),            position: LatLng(24.2203, 89.3805),
            onTap: (){
              print('Haji');
            },
            visible: true,
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
            infoWindow: InfoWindow(title: 'Haji Jamaluddin Collage ',
                onTap: (){}
            ),
          ),//Marker end

          //Marker START
          Marker(markerId: MarkerId('Boral Bridge Station'),
            position: LatLng(24.3333, 89.1000),
            onTap: (){
              print('Tap on my home');
            },
            visible: true,
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
            infoWindow: InfoWindow(title: 'Boral Bridge Station ',
                onTap: (){}
            ),
          )//Marker end
        },//Marker Map

        polylines: <Polyline>{
          Polyline(
            polylineId: const PolylineId('tracking_line'),
            points: _polylineCoordinates,
            visible: true,
            color: Colors.green,
            width: 4,
            endCap: Cap.roundCap,
            startCap: Cap.buttCap,
            jointType: JointType.round,
            onTap: (){},
          ),
        },

      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FloatingActionButton(onPressed: (){
            _googleMapController?.animateCamera(
                CameraUpdate.newCameraPosition(
                    CameraPosition(
                      target: LatLng(24.3333, 89.1000),
                      zoom: 14,
                    )
                )
            );
          },
            child: Icon(Icons.my_location),

          ),
        ],
      ),
    );
  }

  @override
  void dispose(){
    _timer?.cancel(); // টাইমার বন্ধ করুন
    _googleMapController?.dispose(); // কন্ট্রোলার মেমোরি থেকে মুছে দিন
    _googleMapController = null; // কন্ট্রোলারটিকে নাল করে দিন
    super.dispose();

  }
}//Last brack
