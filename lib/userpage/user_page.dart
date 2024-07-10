import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/services.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:permission_handler/permission_handler.dart';

import 'messagedriver.dart';
import 'messagerequest.dart';

class UserPage extends StatefulWidget {
  @override
  _UserPageState createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  Completer<GoogleMapController> _controller = Completer();
  Set<Marker> _markers = {};
  String _tappedLocationAddress = '';
  late DatabaseReference _driverLocationRef;
  late LatLng _driverLocation;
  List<LatLng> _polylineCoordinates = [];
  bool _showDriverMarker = false; // Flag to control the visibility of driver's marker

  @override
  void initState() {
    super.initState();
    checkAndRequestLocationPermissions();
    _driverLocationRef = FirebaseDatabase.instance.reference().child('driver_location');
    _getDriverLocation();
    _getCurrentLocation();
    _listenForDriverAvailability();
  }



  void _listenForDriverAvailability() {
    DatabaseReference driversRef = FirebaseDatabase.instance.reference().child('drivers');
    driversRef.onValue.listen((event) {
      Map<dynamic, dynamic>? driversData = event.snapshot.value as Map<dynamic, dynamic>?;

      if (driversData != null) {
        bool isDriverWorking = false;

        driversData.forEach((key, value) {
          if (value['isAvailable'] == true && value['isWorking'] == true) {
            isDriverWorking = true;
          }
        });

        setState(() {
          _showDriverMarker = isDriverWorking;
        });
      }
    });
  }

  Future<void> checkAndRequestLocationPermissions() async {
    PermissionStatus status = await Permission.locationWhenInUse.status;
    if (status.isDenied || status.isRestricted) {
      await requestLocationPermissions();
    } else {
      _getCurrentLocation();
    }
  }

  Future<void> requestLocationPermissions() async {
    await Permission.locationWhenInUse.request();
    if (await Permission.locationWhenInUse.isGranted) {
      _getCurrentLocation();
    }
  }

  void _getCurrentLocation() async {
    Position position = await Geolocator.getCurrentPosition();
    GoogleMapController controller = await _controller.future;
    controller.animateCamera(
      CameraUpdate.newLatLngZoom(
        LatLng(position.latitude, position.longitude),
        15,
      ),
    );
    setState(() {
      _markers.add(Marker(
        markerId: MarkerId('userLocation'),
        position: LatLng(position.latitude, position.longitude),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
      ));
    });
  }


  void _getDriverLocation() {
    _driverLocationRef.onValue.listen((event) {
      Map<dynamic, dynamic>? locationData = event.snapshot.value as Map<dynamic, dynamic>?;

      if (locationData != null) {
        double? lat = locationData['latitude'] as double?;
        double? lng = locationData['longitude'] as double?;
        bool isWorking = locationData['working'] ?? false;
        bool isAvailable = locationData['available'] ?? false;

        if (lat != null && lng != null && isWorking && isAvailable) {
          setState(() {
            _driverLocation = LatLng(lat, lng);
            _showDriverMarker = true; // Set to true only if available and working
          });
          _updateDriverMarker();
        } else {
          setState(() {
            _showDriverMarker = false; // Set to false if not available or not working
          });
        }
      }
    });
  }

  void _updateDriverMarker() async {
    final Uint8List markerIcon = await getBytesFromAsset(
        'assets/images/ambulance.png', 200, 200);
    setState(() {
      _markers.removeWhere((marker) => marker.markerId.value == 'driverLocation');
      if (_showDriverMarker) {
        _markers.add(
          Marker(
            markerId: const MarkerId('driverLocation'),
            position: _driverLocation,
            icon: BitmapDescriptor.fromBytes(markerIcon),
            infoWindow: InfoWindow(title: "Driver's Location"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MessageRequest()),
              );
            },
          ),
        );
      }
    });
  }

  Future<Uint8List> getBytesFromAsset(
      String path, int width, int height) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetWidth: width, targetHeight: height);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!
        .buffer
        .asUint8List();
  }

  void _onMapTapped(LatLng location) {
    _getAddressFromLatLng(location);
  }

  void _getAddressFromLatLng(LatLng location) async {
    List<Placemark> placemarks = await placemarkFromCoordinates(
      location.latitude,
      location.longitude,
    );

    if (placemarks.isNotEmpty) {
      Placemark placemark = placemarks.first;
      String address = '';
      if (placemark.name != null) {
        address += '${placemark.name}, ';
      }
      if (placemark.subLocality != null) {
        address += '${placemark.subLocality} ';
      }
      if (placemark.locality != null) {
        address += '${placemark.locality}, ';
      }
      if (placemark.administrativeArea != null) {
        address += '${placemark.administrativeArea}, ';
      }
      if (placemark.country != null) {
        address += '${placemark.country}';
      }
      setState(() {
        _tappedLocationAddress = address;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Page'),
      ),
      body: Stack(
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
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
            },
            initialCameraPosition: CameraPosition(
              target: LatLng(28.3949, 84.124), // Initial map center (Nepal)
              zoom: 50,
            ),
            markers: _markers ?? Set<Marker>(),
            polylines: {
              Polyline(
                polylineId: PolylineId('userToDriver'),
                color: Colors.blue,
                width: 5,
                points: _polylineCoordinates,
              ),
            },
            onTap: _onMapTapped,
          ),
          if (_showDriverMarker)
            Center(
              // child: Image.asset(
              //   width: 50,
              //   height: 50,
              // ),
            ),
          Positioned(
            bottom: 23,
            left: 15,
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.black,
                  width: 5.0,
                ),
                borderRadius: BorderRadius.circular(18.0),
              ),
              child: IconButton(
                icon: Icon(Icons.location_on),
                onPressed: () {
                  _getCurrentLocation();
                  GoogleMapController controller = _controller.future as GoogleMapController;
                  controller.animateCamera(
                    CameraUpdate.newLatLngZoom(
                      _markers.first.position,
                      22,
                    ),
                  );
                },
              ),
            ),
          ),
          Positioned(
            top: 10,
            left: 10,
            right: 10,
            child: Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                _tappedLocationAddress,
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
