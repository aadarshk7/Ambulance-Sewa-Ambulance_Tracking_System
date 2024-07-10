import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../utils/validators.dart';
import 'admindriverdetails.dart';
class DriverInsertPage extends StatefulWidget {
  @override
  State<DriverInsertPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<DriverInsertPage> {
  bool _obscureText = true;
  final _firestore = FirebaseFirestore.instance;
  final auth = FirebaseAuth.instance;

  late String email = '';
  late String name;
  late String password = '';
  late String licenseNumber = '';
  late String phoneNumber = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Container(
          child: Column(
            children: <Widget>[
              Container(
                height: 280,
                width :300,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/background.png'),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Stack(
                  children: <Widget>[
                    Positioned(
                      left: 40,
                      top: 230,
                      child: Container(
                        margin: EdgeInsets.all(10),
                        child: Center(
                          child: Text(
                            "Driver Register",
                            style: TextStyle(
                              color: Colors.lightBlue.shade900,
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.all(30.0),
                child: Column(
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Color.fromRGBO(143, 148, 251, .2),
                            blurRadius: 20.0,
                            offset: Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        children: <Widget>[
                          Container(
                            padding: EdgeInsets.all(8.0),
                          ),
                          Container(
                            padding: EdgeInsets.all(8.0),
                            child: TextField(
                              decoration: InputDecoration(
                                labelText: "Name",
                                prefixIcon: Icon(Icons.person),
                              ),
                              onChanged: (value) {
                                setState(() {
                                  name = value;
                                });
                              },
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.all(8.0),
                            child: TextField(
                              decoration: InputDecoration(
                                labelText: "Email",
                                prefixIcon: Icon(Icons.email),
                              ),
                              onChanged: (value) {
                                setState(() {
                                  email = value;
                                });
                              },
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.all(8.0),
                            child: TextField(
                              decoration: InputDecoration(
                                labelText: "Password",
                                prefixIcon: Icon(Icons.lock),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscureText
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                    color: Theme.of(context).primaryColorDark,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscureText = !_obscureText;
                                    });
                                  },
                                ),
                              ),
                              onChanged: (value) {
                                setState(() {
                                  password = value;
                                });
                              },
                              obscureText: _obscureText,
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.all(8.0),
                            child: TextFormField(
                              decoration: InputDecoration(
                                labelText: "Lic. No",
                                prefixIcon: Icon(Icons.credit_card),
                              ),
                              onChanged: (value) {
                                setState(() {
                                  licenseNumber = value;
                                });
                              },
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return 'Please enter your license number';
                                }
                                // Regular expression to match Nepali license number format (##-##-#######)
                                RegExp regex = RegExp(r'^\d{2}-\d{2}-\d{7}$');
                                if (!regex.hasMatch(value)) {
                                  return 'Please enter a valid Nepali license number in the format XX-XX-XXXXXXX';
                                }
                                return null; // Return null if the entered license number is valid
                              },
                              onSaved: (value) {
                                licenseNumber = value!;
                              },
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.all(8.0),
                            child: TextField(
                              decoration: InputDecoration(
                                labelText: "Phone Number",
                                prefixIcon: Icon(Icons.phone),
                              ),
                              keyboardType: TextInputType.phone,
                              onChanged: (value) {
                                setState(() {
                                  phoneNumber = value;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 22,
                    ),
                    Container(
                      height: 50,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        gradient: LinearGradient(
                          colors: [
                            Color.fromRGBO(143, 148, 251, 1),
                            Color.fromRGBO(143, 148, 251, .6),
                          ],
                        ),
                      ),
                      child: Center(
                        child: TextButton(
                          child: Text(
                            "Add",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 22,
                            ),
                          ),
                          onPressed: () async {
                            // Check if phone number is valid
                            if (phoneNumber.length != 10) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text("Please enter a valid phone number."),
                                  backgroundColor: Colors.red,
                                  elevation: 10,
                                  behavior: SnackBarBehavior.floating,
                                  margin: EdgeInsets.all(5),
                                ),
                              );
                              return; // Return from the function if validation fails
                            }

                            // Check if license number is valid
                            if (licenseNumber == null ||
                                !Validators.isValidLicenseNumber(licenseNumber!)) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                      "Please enter a valid license number in the format XX-XX-XXXXXXX"),
                                  backgroundColor: Colors.red,
                                  elevation: 10,
                                  behavior: SnackBarBehavior.floating,
                                  margin: EdgeInsets.all(5),
                                ),
                              );
                              return; // Return from the function if validation fails
                            }

                            // Check if the driver's name is entered
                            if (name == null || name.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text("Please enter your name"),
                                  backgroundColor: Colors.red,
                                  elevation: 10,
                                  behavior: SnackBarBehavior.floating,
                                  margin: EdgeInsets.all(5),
                                ),
                              );
                              return; // Return from the function if validation fails
                            }

                            // Proceed with user registration
                            if (email == null ||
                                email.isEmpty ||
                                password == null ||
                                password.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text("Please enter email and password"),
                                  backgroundColor: Colors.red,
                                  elevation: 10,
                                  behavior: SnackBarBehavior.floating,
                                  margin: EdgeInsets.all(5),
                                ),
                              );
                              return; // Return from the function if validation fails
                            }

                            // Check if the email already exists in the database
                            var querySnapshot = await _firestore
                                .collection('driver')
                                .where('email', isEqualTo: email)
                                .get();
                            if (querySnapshot.docs.isNotEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text("The email address is already exists."),
                                  backgroundColor: Colors.red,
                                  elevation: 10,
                                  behavior: SnackBarBehavior.floating,
                                  margin: EdgeInsets.all(5),
                                ),
                              );
                              return; // Return from the function if email already exists
                            }

                            // Check if the license number already exists in the database
                            querySnapshot = await _firestore
                                .collection('driver')
                                .where('licenseNumber', isEqualTo: licenseNumber)
                                .get();
                            if (querySnapshot.docs.isNotEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text("The license number already exists."),
                                  backgroundColor: Colors.red,
                                  elevation: 10,
                                  behavior: SnackBarBehavior.floating,
                                  margin: EdgeInsets.all(5),
                                ),
                              );
                              return; // Return from the function if license number already exists
                            }

                            // Proceed with user registration
                            FirebaseAuth.instance
                                .createUserWithEmailAndPassword(
                              email: email,
                              password: password,
                            )
                                .then(
                                  (UserCredential userCredential) {
                                User? user = userCredential.user;
                                user?.updateDisplayName(name);
                                _firestore.collection('driver').add({
                                  'name': name,
                                  'email': email,
                                  'password': password, // Store password (not recommended)
                                  'licenseNumber': licenseNumber,
                                  'phoneNumber': phoneNumber,
                                  // Including email and password here
                                }).then(
                                      (value) {
                                    if (user != null) {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => AdminDriverDetails(),
                                        ),
                                      );
                                    }
                                  },
                                ).catchError(
                                      (e) {
                                    print(e.toString());
                                  },
                                );
                              },
                            ).catchError(
                                  (e) {
                                print(e.toString());
                              },
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
