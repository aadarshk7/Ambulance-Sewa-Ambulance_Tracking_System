import 'dart:typed_data';
import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:sliding_switch/sliding_switch.dart';

import 'Message.dart';

class DriverPage extends StatefulWidget {
  @override
  _DriverPageState createState() => _DriverPageState();
}

class _DriverPageState extends State<DriverPage> {
  final TextEditingController _nameController = TextEditingController(); // Declaration
  final TextEditingController _ageController = TextEditingController(); // Declaration
  final TextEditingController _addressController = TextEditingController(); // Declaration
  final TextEditingController _reasonController = TextEditingController(); // Declaration
  final TextEditingController _phoneNumberController = TextEditingController(); // Declaration

  Completer<GoogleMapController> _controller = Completer();
  Set<Marker> _markers = {};
  LatLng _currentLocation = LatLng(37.7749, -122.4194);
  bool _isWorking = false;
  bool _isAvailable = false;
  late DatabaseReference _driverLocationRef;
  void _updateDriverAvailability(bool isAvailable, bool isWorking) {
    _driverLocationRef.update({
      'isAvailable': isAvailable,
      'isWorking': isWorking,
    });
  }


  @override
  void initState() {
    super.initState();
    _initFirebase();
    _getCurrentLocation();
  }

  void _initFirebase() {
    FirebaseDatabase database = FirebaseDatabase.instance;
    _driverLocationRef = database.reference().child('driver_location');
  }

  void _getCurrentLocation() async {
    Position position = await Geolocator.getCurrentPosition();
    setState(() {
      _currentLocation = LatLng(position.latitude, position.longitude);
    });
    _updateMap();
  }

  void _updateMap() {
    if (_isWorking && _isAvailable) {
      _updateDriverMarker(_currentLocation);
      _updateDriverLocationInFirebase(_currentLocation);
    } else {
      setState(() {
        _markers.clear();
      });
      _driverLocationRef.remove(); // Remove location from Firebase when not working/available
    }
  }


  Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(), targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!.buffer.asUint8List();
  }

  void _updateDriverMarker(LatLng location) async {
    final Uint8List markerIcon = await getBytesFromAsset('assets/images/ambulance.png', 200);
    setState(() {
      _markers.add(
        Marker(
          markerId: MarkerId('driverLocation'),
          position: location,
          icon: BitmapDescriptor.fromBytes(markerIcon),
          infoWindow: InfoWindow(title: "Driver's Location"),
        ),
      );
    });
  }

  void _updateDriverLocationInFirebase(LatLng location) {
    _driverLocationRef.set({
      'latitude': location.latitude,
      'longitude': location.longitude,
      'working': _isWorking,
      'available': _isAvailable,
    });
  }

  void _onMapCreated(GoogleMapController controller) {
    _controller.complete(controller);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Driver Page'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text("Available: ", style: TextStyle(fontSize: 22)),
                SlidingSwitch(
                    value: _isAvailable,
                    width: 170,
                    onChanged: (bool value) {
                      setState(() {
                        _isAvailable = value;
                      });
                      _updateMap();

                    },
                    onTap: () {
                      // Empty implementation for onTap
                    },
                    onDoubleTap: () {
                      // Empty implementation for onDoubleTap
                    },
                    onSwipe: () {
                      // Empty implementation for onSwipe
                    }
                ),
                SizedBox(width: 20),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Message(
                          name: _nameController.text,
                          age: int.tryParse(_ageController.text) ?? 0,
                          address: _addressController.text,
                          phoneNumber: '+977${_phoneNumberController.text}',
                          reason: _reasonController.text,
                        ),
                      ),
                    );
                  },
                  child: Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(color: Colors.blue, shape: BoxShape.circle),
                    child: Icon(Icons.message, color: Colors.white),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text("Working: ", style: TextStyle(fontSize: 28)),
                SlidingSwitch(
                  value: _isWorking,
                  width: 222,
                  onChanged: (bool value) {
                    setState(() {
                      _isWorking = value;
                    });
                    _updateMap();
                  },
                  onTap: () {
                    // Empty implementation for onTap
                  },
                  onDoubleTap: () {
                    // Empty implementation for onDoubleTap
                  },
                  onSwipe: () {
                    // Empty implementation for onSwipe
                  },
                ),
              ],
            ),
            Expanded(
              child: Stack(
                children: [
                  GoogleMap(
                    mapType: MapType.normal,
                    myLocationEnabled: true,
                    zoomGesturesEnabled: true,
                    zoomControlsEnabled: true,
                    // zoomGesturesEnabled: true,
                    scrollGesturesEnabled: true,
                    rotateGesturesEnabled: true,
                    tiltGesturesEnabled: true,
                    myLocationButtonEnabled: true,
                    compassEnabled: true,
                    mapToolbarEnabled: true,
                    indoorViewEnabled: true,
                    trafficEnabled: false,
                    onMapCreated: _onMapCreated,
                    initialCameraPosition: CameraPosition(target: _currentLocation, zoom: 17),
                    markers: _markers,
                  ),
                  if (!_isWorking && !_isAvailable)
                    Center(
                      child: Image.asset("assets/images/sleeping.png", height: 580, fit: BoxFit.cover),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
