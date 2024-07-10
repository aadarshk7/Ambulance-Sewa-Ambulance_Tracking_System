import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'admininsertuser.dart';

class GetUser extends StatefulWidget {
  @override
  _GetUserState createState() => _GetUserState();
}

class _GetUserState extends State<GetUser> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "User Details",
          style: TextStyle(
            color: Colors.lightBlue.shade900,
            fontSize: 30,
          ),
        ),
      ),

      body:
      Column(
          children: [
            Container(
              height: 200,
              width: 200,
              decoration: BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage('assets/images/background.png',),
                      fit: BoxFit.cover)),
            ),
            Center(
              child: Text(
                "AmbulanceSewa User list",
                style: TextStyle(
                  color: Colors.lightBlue.shade900,
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(child:
            StreamBuilder<QuerySnapshot>(
              stream: _firestore.collection('users').snapshots(),
              builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                return
                  ListView(
                    children: snapshot.data!.docs.map((DocumentSnapshot document) {
                      Map<String, dynamic> data = document.data() as Map<String, dynamic>;
                      return ListTile(
                        leading: Icon(Icons.person),
                        title: data['phoneNumber'] != null && data['phoneNumber'] != '' ? Text('Phone: ${data['phoneNumber']}', style: TextStyle(fontSize: 20)) : Text('Name: ${data['name']}', style: TextStyle(fontSize: 20)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (data['email'] != null && data['email'] != '') // Check if email exists and is not empty
                              Text('Email: ${data['email']}', style: TextStyle(fontSize: 20)),
                          ],
                        ),
                        onLongPress: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              final _formKey = GlobalKey<FormState>();
                              String newName = '';
                              String newEmail = '';

                              return AlertDialog(
                                title: Text('Options'),
                                content: Form(
                                  key: _formKey,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      TextFormField(
                                        decoration:
                                        InputDecoration(labelText: 'New Name'),
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Please enter a name';
                                          }
                                          return null;
                                        },
                                        onSaved: (value) {
                                          newName = value!;
                                        },
                                      ),
                                      TextFormField(
                                        decoration:
                                        InputDecoration(labelText: 'New Email'),
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Please enter an email';
                                          }
                                          return null;
                                        },
                                        onSaved: (value) {
                                          newEmail = value!;
                                        },
                                      ),
                                      OutlinedButton(
                                        child: Text('Change User'),
                                        onPressed: () {
                                          if (_formKey.currentState!.validate()) {
                                            _formKey.currentState!.save();
                                            void updateUser(String oldEmail,
                                                String newName, String newEmail) async {
                                              var snapshot = await _firestore
                                                  .collection('users')
                                                  .where('email', isEqualTo: oldEmail)
                                                  .get();
                                              snapshot.docs.forEach((document) {
                                                document.reference.update({
                                                  'name': newName,
                                                  'email': newEmail,
                                                });
                                              });
                                            }

                                            updateUser(
                                                data['email'], newName, newEmail);
                                            Navigator.of(context).pop();
                                          }
                                        },
                                      ),

                                      OutlinedButton(
                                        child: Text('Delete User'),
                                        onPressed: () async {
                                          void deleteUser(String email) async {
                                            try {
                                              var snapshot = await _firestore
                                                  .collection('users')
                                                  .where('email', isEqualTo: email)
                                                  .get();
                                              for (var document in snapshot.docs) {
                                                // Delete the user document and wait for it to complete
                                                await document.reference.delete();

                                                // Assuming the phone number is stored in a 'phoneNumbers' collection
                                                var phoneNumberSnapshot = await _firestore
                                                    .collection('phoneNumbers')
                                                    .where('userEmail', isEqualTo: email)
                                                    .get();
                                                for (var phoneNumberDocument in phoneNumberSnapshot.docs) {
                                                  // Delete the phone number document and wait for it to complete
                                                  await phoneNumberDocument.reference.delete();}}} catch (e) {print('Error deleting user: $e');}}
                                          deleteUser(data['email']);
                                          Navigator.of(context).pop();},),

                                      OutlinedButton(
                                        child: Text('Delete User Phone'),
                                        onPressed: () async {
                                          void deleteUserPhone() async {
                                            try {
                                              // Get the currently logged-in user
                                              User? user = FirebaseAuth.instance.currentUser;

                                              if (user != null) {
                                                // Get a reference to the Firestore Database
                                                final firestoreRef = FirebaseFirestore.instance;

                                                // Delete the user's document
                                                await firestoreRef.collection('users').doc(user.uid).delete();
                                              } else {
                                                print('No user is currently logged in');
                                              }
                                            } catch (e) {
                                              print('Error deleting user phone: $e');
                                            }
                                          }

                                          deleteUserPhone();
                                          Navigator.of(context).pop();
                                        },
                                      ),




                                      //       ],
                                      //     ),
                                      //   ),
                                      // );
                                      // return AlertDialog(
                                      //   title: Text('Options'),
                                      //   content: Form(
                                      //     key: _formKey,
                                      //     child: Column(
                                      //       mainAxisSize: MainAxisSize.min,
                                      //       children: <Widget>[
                                      //         // ... Your existing TextFormField widgets and 'Change User' button ...
                                      //
                                      //         OutlinedButton(
                                      //           child: Text('Delete User Email'),
                                      //           onPressed: () async {
                                      //             void deleteUserEmail(String email) async {
                                      //               try {
                                      //                 var snapshot = await _firestore
                                      //                     .collection('users')
                                      //                     .where('email', isEqualTo: email)
                                      //                     .get();
                                      //                 for (var document in snapshot.docs) {
                                      //                   // Delete the user document and wait for it to complete
                                      //                   await document.reference.delete();
                                      //                 }
                                      //               } catch (e) {
                                      //                 print('Error deleting user email: $e');
                                      //               }
                                      //             }
                                      //
                                      //             deleteUserEmail(data['email']);
                                      //             Navigator.of(context).pop();
                                      //           },
                                      //         ),


                                      // OutlinedButton(
                                      //   child: Text('Delete User Phone'),
                                      //   onPressed: () async {
                                      //     void deleteUserPhone(String userId) async {
                                      //       try {
                                      //         // Get a reference to the Realtime Database
                                      //         final dbRef = FirebaseDatabase.instance.reference();
                                      //
                                      //         // Assuming the phone number is stored under 'users/userId/phoneNumber'
                                      //         await dbRef.child('users').child(userId).child('phoneNumber').remove();
                                      //       } catch (e) {
                                      //         print('Error deleting user phone: $e');
                                      //       }
                                      //     }
                                      //
                                      //     deleteUserPhone(data['phoneNumber']); // Replace with the actual userId
                                      //     Navigator.of(context).pop();
                                      //   },
                                      // ),

                                    ],
                                  ),
                                ),
                              );




                            },
                          );
                        },
                      );
                    }).toList(),
                  );
              },
            ),
            ),
          ]),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => InsertUser()),
          );
        },
        child: Icon(Icons.add),
      ),

      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {
      //     showDialog(
      //       context: context,
      //       builder: (BuildContext context) {
      //         TextEditingController _emailController = TextEditingController();
      //         return AlertDialog(
      //           title: Text('Delete User'),
      //           content: Column(
      //             children: <Widget>[
      //               const Text('Enter the email of the user you want to delete.'),
      //               TextField(
      //                 controller: _emailController,
      //                 decoration: InputDecoration(labelText: 'Email'),
      //               ),
      //             ],
      //           ),
      //           actions: <Widget>[
      //             OutlinedButton(
      //               child: Text('Cancel'),
      //               onPressed: () {
      //                 Navigator.of(context).pop();
      //               },
      //             ),
      //             OutlinedButton(
      //               child: Text('Delete'),
      //               onPressed: () {
      //                 void deleteUser(String email) async {
      //                   var snapshot = await _firestore.collection('users').where('email', isEqualTo: email).get();
      //                   snapshot.docs.forEach((document) {
      //                     document.reference.delete();
      //                   });
      //                 }
      //
      //                 // Implement your method to delete the user from the database
      //                 deleteUser(_emailController.text);
      //                 Navigator.of(context).pop();
      //               },
      //             ),
      //           ],
      //         );
      //       },
      //     );
      //   },
      //   child: Icon(Icons.delete),
      // ),


    );
  }
}
