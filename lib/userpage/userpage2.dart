// import 'dart:async';
// import 'dart:convert';
//
// import 'package:firebase_database/firebase_database.dart';
// import 'package:flutter/material.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:geocoding/geocoding.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:http/http.dart' as http;
// import 'package:flutter_polyline_points/flutter_polyline_points.dart';
//
// class UserPage extends StatefulWidget {
//   @override
//   _UserPageState createState() => _UserPageState();
// }
//
// class _UserPageState extends State<UserPage> {
//   Completer<GoogleMapController> _controller = Completer();
//   Set<Marker> _markers = {};
//   TextEditingController _searchController = TextEditingController();
//   String _tappedLocationAddress = '';
//   LatLng _driverLocation = LatLng(37.7749, -122.4194); // Default driver location
//   PolylinePoints _polylinePoints = PolylinePoints();
//   List<LatLng> _polylineCoordinates = [];
//
//   @override
//   void initState() {
//     super.initState();
//     _getCurrentLocation();
//   }
//
//   void _getCurrentLocation() async {
//     bool serviceEnabled;
//     LocationPermission permission;
//
//     serviceEnabled = await Geolocator.isLocationServiceEnabled();
//     if (!serviceEnabled) {
//       return;
//     }
//
//     permission = await Geolocator.checkPermission();
//     if (permission == LocationPermission.denied) {
//       permission = await Geolocator.requestPermission();
//       if (permission == LocationPermission.denied) {
//         return;
//       }
//     }
//
//     if (permission == LocationPermission.deniedForever) {
//       return;
//     }
//
//     Position position = await Geolocator.getCurrentPosition();
//     GoogleMapController controller = await _controller.future;
//     controller.animateCamera(
//       CameraUpdate.newLatLngZoom(
//         LatLng(position.latitude, position.longitude),
//         15,
//       ),
//     );
//     setState(() {
//       _markers.add(Marker(
//         markerId: MarkerId('userLocation'),
//         position: LatLng(position.latitude, position.longitude),
//         icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
//       ));
//     });
//     _getDriverLocation();
//   }
//
//   // Inside the _getDriverLocation() method
//
//   void _getDriverLocation() {
//     // Reference to the driver's location node in the Firebase Realtime Database
//     DatabaseReference driverLocationRef = FirebaseDatabase.instance.reference().child('driver_location');
//
//     // Listening for changes in the driver's location
//     driverLocationRef.onValue.listen((event) {
//       // Explicitly cast event.snapshot.value to Map<dynamic, dynamic>
//       Map<dynamic, dynamic>? locationData = event.snapshot.value as Map<dynamic, dynamic>?;
//
//       // Check if locationData is not null
//       if (locationData != null) {
//         double? lat = locationData['latitude'] as double?;
//         double? lng = locationData['longitude'] as double?;
//
//         // Check if lat and lng are not null
//         if (lat != null && lng != null) {
//           // Update the driver's location
//           setState(() {
//             _driverLocation = LatLng(lat, lng);
//           });
//
//           // Redraw the polyline and update the marker
//           _drawPolyline();
//
//           // Add the driver's marker with a vehicle icon
//           setState(() {
//             _markers.add(
//               Marker(
//                 markerId: MarkerId('driverLocation'),
//                 position: _driverLocation,
//                 icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
//               ),
//             );
//           });
//         }
//       }
//     });
//   }
//
//
//   void _drawPolyline() async {
//     PolylineResult result = await _polylinePoints.getRouteBetweenCoordinates(
//       "YOUR_API_KEY", // Replace with your Google Maps API key
//       PointLatLng(_markers.first.position.latitude, _markers.first.position.longitude),
//       PointLatLng(_driverLocation.latitude, _driverLocation.longitude),
//     );
//
//     if (result.points.isNotEmpty) {
//       result.points.forEach((PointLatLng point) {
//         _polylineCoordinates.add(LatLng(point.latitude, point.longitude));
//       });
//     }
//
//     setState(() {
//       _markers.add(
//         Marker(
//           markerId: MarkerId('driverLocation'),
//           position: _driverLocation,
//           icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
//         ),
//       );
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('User Page'),
//       ),
//       body: Stack(
//         children: [
//           GoogleMap(
//             onMapCreated: (GoogleMapController controller) {
//               _controller.complete(controller);
//             },
//             initialCameraPosition: CameraPosition(
//               target: LatLng(28.3949, 84.124), // Initial map center (Nepal)
//               zoom: 6,
//             ),
//             markers: _markers,
//             polylines: {
//               Polyline(
//                 polylineId: PolylineId('userToDriver'),
//                 color: Colors.blue,
//                 width: 5,
//                 points: _polylineCoordinates,
//               ),
//             },
//           ),
//           Positioned(
//             top: 10,
//             left: 10,
//             right: 10,
//             child: Container(
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(10),
//               ),
//               child: Row(
//                 children: [
//                   IconButton(
//                     icon: Icon(Icons.my_location),
//                     onPressed: _getCurrentLocation,
//                   ),
//                   Expanded(
//                     child: TextField(
//                       controller: _searchController,
//                       decoration: InputDecoration(
//                         hintText: 'Search for nearby hospitals...',
//                         contentPadding: EdgeInsets.symmetric(horizontal: 20),
//                         border: InputBorder.none,
//                       ),
//                       onChanged: (String query) {
//                         // Handle search
//                       },
//                     ),
//                   ),
//                   IconButton(
//                     icon: Icon(Icons.search),
//                     onPressed: () {
//                       // Perform search
//                     },
//                   ),
//                 ],
//               ),
//             ),
//           ),
//           Positioned(
//             bottom: 10,
//             left: 10,
//             right: 10,
//             child: Container(
//               padding: EdgeInsets.all(10),
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(10),
//               ),
//               child: Text(
//                 _tappedLocationAddress,
//                 style: TextStyle(fontSize: 16),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
