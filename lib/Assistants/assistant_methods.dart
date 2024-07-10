// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_database/firebase_database.dart';
//
// class AssistantMethods{
//   static void readCurrentOnLineUserInfo() async{
//     // currentUser = firebaseAuth.currentUser();
//     FirebaseAuth.instance.authStateChanges().listen((User? user) {
//       if (user == null) {
//         print('User is currently signed out!');
//       } else {
//         print('User is signed in!');
//       }
//     });
//
//     DatabaseReference userRef = FirebaseDatabase.instance
//     .ref()
//     .child("users")
//     .child(currentUser!.Uid);
//
//     userRef.once().then((snap){
//       if(snap.snapshot.value!= null){
//         userModeCurrentInfo = UserModel.fromSnapshor(snap.snapshot);
//       }
//     });
//
//   }
// }
//

// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_database/firebase_database.dart';
//
// class AssistantMethods{
//   static User? currentUser;
//
//   static void readCurrentOnLineUserInfo() async{
//     FirebaseAuth.instance.authStateChanges().listen((User? user) {
//       if (user == null) {
//         print('User is currently signed out!');
//       } else {
//         print('User is signed in!');
//         currentUser = user; // Update currentUser when the user is signed in
//       }
//     });
//
//     // Make sure currentUser is not null before using it
//     if(currentUser != null) {
//       DatabaseReference userRef = FirebaseDatabase.instance
//           .ref()
//           .child("users")
//           .child(currentUser!.uid);
//
//       userRef.once().then((snap){
//         if(snap.snapshot.value!= null){
//           userModeCurrentInfo=UserModel.fromSnapshot(snap.snapshot);
//         }
//       });
//     }
//   }
// }

// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_database/firebase_database.dart';
// class AssistantMethods{
//   static User? currentUser;
//   static UserModel? userModeCurrentInfo; // Add this line
//
//   static void readCurrentOnLineUserInfo() async{
//     FirebaseAuth.instance.authStateChanges().listen((User? user) {
//       if (user == null) {
//         print('User is currently signed out!');
//       } else {
//         print('User is signed in!');
//         currentUser = user; // Update currentUser when the user is signed in
//       }
//     });
//
//     // Make sure currentUser is not null before using it
//     if(currentUser != null) {
//       DatabaseReference userRef = FirebaseDatabase.instance
//           .ref()
//           .child("users")
//           .child(currentUser!.uid);
//
//       userRef.once().then((snap){
//         if(snap.snapshot.value!= null){
//           userModeCurrentInfo = UserModel.fromSnapshot(snap.snapshot); // Update userModeCurrentInfo here
//         }
//       });
//     }
//   }
// }

// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_database/firebase_database.dart';
// import '../models/usermodel.dart';
//
// import '../global/global.dart';
//
// class AssistantMethods{
//   static void readCurrentOnLineUserInfo() async{
//     currentUser = firebaseAuth.currentUser;
//     DatabaseReference userRef = FirebaseDatabase.instance
//     .ref()
//     .child("users")
//     .child(currentUser!.uid);
//
//     userRef.once().then((snap){
//       if(snap.snapshot.value!= null){
//         userModeCurrentInfo = UserModel.fromSnapshot(snap.snapshot);
//       }
//     });
//
//   }
// }

//
// import 'package:firebase_database/firebase_database.dart';
//
// import '../global/global.dart';
// import '../models/usermodel.dart';
//
// class AssistantMethods {
//   static Future<void> readCurrentOnlineUserInfo() async {
//     try {
//       final currentUser = firebaseAuth.currentUser;
//       if (currentUser == null) {
//         // Handle the case when the user is not authenticated
//         return;
//       }
//
//       final userRef = FirebaseDatabase.instance
//           .ref()
//           .child("users")
//           .child(currentUser.uid);
//
//       final snapshot = await userRef.once();
//       if (snapshot.value != null) {
//         userModeCurrentInfo = UserModel.fromSnapshot(snapshot as DataSnapshot);
//       } else {
//         // Handle the case when user data is not found
//       }
//     } catch (e) {
//       // Handle any exceptions (e.g., network errors, database errors)
//       print("Error reading user info: $e");
//     }
//   }
// }

import '../Assistants/request_assistant.dart';
import '../global/global.dart';
import '../global/map_key.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';

import '../infoHandler/app_info.dart';
import '../models/directions.dart';
import '../models/usermodel.dart';

class AssistantMethods {
  static void readCurrentOnlineUserInfo() async {
    currentUser = firebaseAuth.currentUser;
    /*FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user == null) {
        print('User is currently signed out!');
      } else {
        print('User is signed in!');
      }
    });*/

    DatabaseReference userRef =
        FirebaseDatabase.instance.ref().child("users").child(currentUser!.uid);

    userRef.once().then((snap) {
      if (snap.snapshot.value != null) {
        userModelCurrentInfo = UserModel.fromSnapshot(snap.snapshot);
      }
    });
  }

  static Future<String> searchAddressForGeographicCoordinates(
      Position position, context) async {
    String apiUrl =
        "https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude},${position.longitude}&key=$mapKey";
    String humanReadableAddress = "";

    // You need to implement the RequestAssistant.request method
    var requestResponse = await RequestAssistant.receiveRequest(apiUrl);

    if (requestResponse != "Error Occured. Failed. No Response.") {
      humanReadableAddress = requestResponse["results"][0]["formatted_address"];

      Directions userPickUpAddress = Directions();
      userPickUpAddress.locationLatitude = position.latitude;
      userPickUpAddress.locationLongitude = position.longitude;
      userPickUpAddress.locationName = humanReadableAddress;

      Provider.of<AppInfo>(context, listen: false).updatePickUpLocationAddress(userPickUpAddress);
      // Process the requestResponse to get the humanReadableAddress
    }
    return humanReadableAddress;
  }
}

//
// import 'package:ambulancesewa/Assistants/request_assistant.dart';
// import 'package:geolocator/geolocator.dart';
//
// import '../global/map_key.dart';
// import '../models/directions.dart';
//
// class AssistantMethods {
//   static Future<String> searchAddressForGeographicCoordinates(
//       Position position, context) async {
//     String apiUrl = "https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude},${position.longitude}&key=$mapKey";
//     String humanReadableAddress = "";
//
//     try {
//       var requestResponse = await RequestAssistant.receiveRequest(apiUrl);
//
//       if (requestResponse["status"] == "OK") {
//         humanReadableAddress = requestResponse["results"][0]["formatted_address"];
//
//         Directions userPickUpAddress = Directions();
//         userPickUpAddress.locationLatitude = position.latitude;
//         userPickUpAddress.locationLongitude = position.longitude;
//         userPickUpAddress.locationName = humanReadableAddress;
//       } else {
//         print('Error from Google Maps API: ${requestResponse["status"]}');
//       }
//     } catch (e) {
//       print('Exception occurred while getting location: $e');
//     }
//
//     return humanReadableAddress;
//   }
// }

//
// import 'package:ambulancesewa/Assistants/request_assistant.dart';
// import 'package:geolocator/geolocator.dart';
//
// import '../global/map_key.dart';
// import '../models/directions.dart';

// class AssistantMethods {
//   static Future<String> searchAddressForGeographicCoordinates(
//       Position position, context) async {
//     String apiUrl = "https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude},${position.longitude}&key=$mapKey";
//     String humanReadableAddress = "";
//
//     try {
//       // You need to implement the RequestAssistant.request method
//       var requestResponse = await RequestAssistant.receiveRequest(apiUrl);
//       if (requestResponse != "Error Occurred. Failed. No Response.") {
//         // Check if "results" array is not empty before accessing its first element
//         if (requestResponse["results"] != null && requestResponse["results"].isNotEmpty) {
//           humanReadableAddress = requestResponse["results"][0]["formatted_address"];
//
//           Directions userPickUpAddress = Directions();
//           userPickUpAddress.locationLatitude = position.latitude;
//           userPickUpAddress.locationLongitude = position.longitude;
//           userPickUpAddress.locationName = humanReadableAddress;
//         }
//       } else {
//         print("Error occurred while fetching address: No valid response");
//       }
//     } catch (e) {
//       print("Error occurred while fetching address: $e");
//     }
//
//     // Provider.of<AppInfo>(context, listen: false).updatePickUpLocationAddress(userPickUpAddress);
//     // Process the requestResponse to get the humanReadableAddress
//
//     return humanReadableAddress;
//   }
// }

// class AssistantMethods {
//   static Future<String> searchAddressForGeographicCoordinates(Position position,
//       context) async {
//     String apiUrl =
//         "https://maps.googleapis.com/maps/api/geocode/json?latlng=${position
//         .latitude},${position.longitude}&key=$mapKey";
//     String humanReadableAddress = "";
//
//     try {
//       print('Sending request to: $apiUrl');
//       var requestResponse = await RequestAssistant.receiveRequest(apiUrl);
//       print('Received response: $requestResponse');
//       if (requestResponse != "Error Occurred. Failed. No Response.") {
//         if (requestResponse["results"] != null &&
//             requestResponse["results"].isNotEmpty) {
//           humanReadableAddress =
//           requestResponse["results"][0]["formatted_address"];
//         }
//       } else {
//         print("Error occurred while fetching address: No valid response");
//       }
//     } catch (e) {
//       print("Error occurred while fetching address: $e");
//     }
//
//     return humanReadableAddress;
//   }
// }
//
