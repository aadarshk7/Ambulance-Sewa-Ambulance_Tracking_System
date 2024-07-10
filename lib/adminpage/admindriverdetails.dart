import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'admininsertuser.dart';
import 'admin_driverinsert.dart';

class AdminDriverDetails extends StatefulWidget {
  @override
  _AdminDriverDetailsState createState() => _AdminDriverDetailsState();
}

class _AdminDriverDetailsState extends State<AdminDriverDetails> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Driver Details",
          style: TextStyle(
            color: Colors.lightBlue.shade900,
            fontSize: 30,
          ),
        ),
      ),
      body: Column(
        children: [
          Container(
            height: 200,
            width: 200,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/background.png',),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Center(
            child: Text(
              "AmbulanceSewa Driver's list",
              style: TextStyle(
                color: Colors.lightBlue.shade900,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore.collection('driver').snapshots(),
              builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                return ListView(
                  children: snapshot.data!.docs.map((DocumentSnapshot document) {
                    Map<String, dynamic> data = document.data() as Map<String, dynamic>;
                    return ListTile(
                      leading: Icon(Icons.person),
                      title: Text('Name: ${data['name']}'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Email: ${data['email']}'),
                          Text('Phone Number: ${data['phoneNumber']}'),
                          Text('License Number: ${data['licenseNumber']}'),
                        ],
                      ),
                      onLongPress: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            final _formKey = GlobalKey<FormState>();
                            String newName = '';
                            String newEmail = '';
                            String newLicenseNumber = '';
                            String newPhoneNumber = '';

                            return AlertDialog(
                              title: Text('Options'),
                              content: SingleChildScrollView(
                                child: Form(
                                  key: _formKey,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      TextFormField(
                                        decoration: InputDecoration(labelText: 'New Name'),
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
                                        decoration: InputDecoration(labelText: 'New Email'),
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
                                      TextFormField(
                                        decoration: InputDecoration(labelText: 'New License Number (XX-XX-XXXXXXX)'),
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Please enter a license number';
                                          } else if (!RegExp(r'^\d{2}-\d{2}-\d{7}$').hasMatch(value)) {
                                            return 'Invalid license number format';
                                          }
                                          return null;
                                        },
                                        onSaved: (value) {
                                          newLicenseNumber = value!;
                                        },
                                      ),
                                      TextFormField(
                                        decoration: InputDecoration(labelText: 'Add Phone Number (10 digits)'),
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Please enter a phone number';
                                          } else if (!RegExp(r'^\d{10}$').hasMatch(value)) {
                                            return 'Phone number should be 10 digits';
                                          }
                                          return null;
                                        },
                                        onSaved: (value) {
                                          newPhoneNumber = value!;
                                        },
                                      ),
                                      OutlinedButton(
                                        child: Text('Change Driver'),
                                        onPressed: () {
                                          if (_formKey.currentState!.validate()) {
                                            _formKey.currentState!.save();
                                            void updateDriver(
                                                String oldEmail,
                                                String newName,
                                                String newEmail,
                                                String newLicenseNumber,
                                                String newPhoneNumber,
                                                ) async {
                                              var snapshot = await _firestore
                                                  .collection('driver')
                                                  .where('email', isEqualTo: oldEmail)
                                                  .get();
                                              snapshot.docs.forEach((document) {
                                                document.reference.update({
                                                  'name': newName,
                                                  'email': newEmail,
                                                  'licenseNumber': newLicenseNumber,
                                                });
                                              });
                                              // Store the new phone number in the 'phoneNumber' collection
                                              _firestore.collection('phoneNumber').add({
                                                'driverEmail': newEmail,
                                                'phoneNumber': newPhoneNumber,
                                              });
                                            }

                                            updateDriver(
                                              data['email'],
                                              newName,
                                              newEmail,
                                              newLicenseNumber,
                                              newPhoneNumber,
                                            );
                                            Navigator.of(context).pop();
                                          }
                                        },
                                      ),
                                      OutlinedButton(
                                        child: Text('Delete Driver'),
                                        onPressed: () async {
                                          void deleteDriver(String email) async {
                                            try {
                                              var snapshot = await _firestore
                                                  .collection('driver')
                                                  .where('email', isEqualTo: email)
                                                  .get();
                                              for (var document in snapshot.docs) {
                                                // Delete the driver document and wait for it to complete
                                                await document.reference.delete();
                                              }
                                              // Delete the phone number from the 'phoneNumber' collection
                                              var phoneNumberSnapshot = await _firestore
                                                  .collection('phoneNumber')
                                                  .where('driverEmail', isEqualTo: email)
                                                  .get();
                                              for (var phoneNumberDocument in phoneNumberSnapshot.docs) {
                                                // Delete the phone number document and wait for it to complete
                                                await phoneNumberDocument.reference.delete();
                                              }
                                            } catch (e) {
                                              print('Error deleting driver: $e');
                                            }
                                          }

                                          deleteDriver(data['email']);
                                          Navigator.of(context).pop();
                                        },
                                      ),
                                    ],
                                  ),
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
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => DriverInsertPage()),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
