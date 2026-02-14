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
  LatLng _currentLocation = const LatLng(24.2200, 89.3809); 
  List<LatLng> _polylineCoordinates = [];

  Timer? _timer; 
  @override
  void initState() {
    super.initState();
    _checkPermissionAndSetup();
  }


  Future<void> _checkPermissionAndSetup() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.whileInUse || permission == LocationPermission.always) {

      _updateUserLocation();
      _timer = Timer.periodic(const Duration(seconds: 10), (timer) {
        _updateUserLocation();
      });
    }
  }

  Future<void> _updateUserLocation() async {
    
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        LatLng newLatLng = LatLng(position.latitude, position.longitude);
        _currentLocation = newLatLng;
        //_currentLocation = LatLng(position.latitude, position.longitude);
  
        _polylineCoordinates.add(newLatLng);
      });

      _googleMapController?.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(position.latitude, position.longitude),
            zoom: 15, 
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
          position: _currentLocation,//           //
          onTap: (){
            print('Tap on my home');
          },
            visible: true,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
            infoWindow: InfoWindow(title: 'My current location ',
                snippet: '${_currentLocation.latitude}, ${_currentLocation.longitude}', 
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
    _timer?.cancel(); 
    _googleMapController?.dispose(); 
     _googleMapController = null;
     super.dispose();

  }
}//Last brack
