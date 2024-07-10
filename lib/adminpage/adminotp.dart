import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ambulancesewa/adminpage/admin_page.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'adminoptionpage.dart';

class AdminPhoneOTP extends StatefulWidget {
  @override
  State<AdminPhoneOTP> createState() => _PhoneOTP();
}

class _PhoneOTP extends State<AdminPhoneOTP> {
  bool showOtpField = false;
  final _formKey = GlobalKey<FormState>();
  final _auth = FirebaseAuth.instance;
  late String phoneNo, verificationId;
  late String smsCode = '';
  String errorMessage = '';
  bool isCodeSent = false;
  final String specialNumber = '+9779706631613'; // Special admin number

  Future<void> verifyPhone() async {
    await _auth.verifyPhoneNumber(
      phoneNumber: this.phoneNo,
      timeout: const Duration(seconds: 60),
      verificationCompleted: (AuthCredential authCredential) {
        _auth.signInWithCredential(authCredential).then((UserCredential result) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => AdminPage(),
            ),
          );
        }).catchError((e) {
          print(e);
        });
      },
      verificationFailed: (FirebaseAuthException authException) {
        setState(() {
          errorMessage = authException.message!;
        });
        print(errorMessage);
      },
      codeSent: (String verId, [int? forceCodeResend]) {
        this.verificationId = verId;
        setState(() {
          this.isCodeSent = true;
        });
      },
      codeAutoRetrievalTimeout: (String verId) {
        this.verificationId = verId;
      },
    );
  }

  void signInWithOTP(smsCode, verId) {
    PhoneAuthCredential phoneAuthCredential =
    PhoneAuthProvider.credential(verificationId: verId, smsCode: smsCode);
    _auth.signInWithCredential(phoneAuthCredential).then((UserCredential result) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => AdminDriver(),
        ),
      );
    }).catchError((e) {
      if (e is FirebaseAuthException && e.code == 'invalid-verification-code') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('The provided verification code is invalid.'),
            backgroundColor: Colors.red,
            elevation: 10,
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.all(5),
          ),
        );
      } else {
        print(e);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Container(
              height: 400,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/background.png'),
                  fit: BoxFit.cover,
                ),
              ),
              child: Stack(
                children: <Widget>[
                  Positioned(
                    left: 70,
                    top: 333,
                    child: Container(
                      margin: EdgeInsets.all(10),
                      child: Center(
                        child: Text(
                          "Admin Verification",
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
              child: Form(
                key: _formKey,
                child: Column(
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.all(8.0),
                      child: TextFormField(
                        decoration: InputDecoration(
                          hintText: "+977 XXXXXXXXXX",
                          labelText: "Phone Number",
                          prefixIcon: Icon(Icons.phone),
                        ),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please enter your phone number';
                          }
                          return null;
                        },
                        onChanged: (value) {
                          this.phoneNo = value;
                        },
                      ),
                    ),
                    Visibility(
                      visible: showOtpField,
                      child: Container(
                        height: 77,
                        padding: EdgeInsets.all(8.0),
                        child: TextField(
                          decoration: InputDecoration(
                            labelText: "Enter OTP",
                            prefixIcon: Icon(Icons.chat),
                          ),
                          onChanged: (value) {
                            this.smsCode = value;
                          },
                        ),
                      ),
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
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              if (phoneNo == specialNumber) {
                                setState(() {
                                  showOtpField = true;
                                });
                                isCodeSent
                                    ? signInWithOTP(smsCode, verificationId)
                                    : verifyPhone();
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Only the Admin Number is allowed for verification.',style: TextStyle(color: Colors.white),
                                    ),    backgroundColor:Colors.red,
                                  ),
                                  // SnackBar(
                                  //   content: Text(
                                  //     'Only the Admin Number $specialNumber is allowed for admin verification.',style: TextStyle(color: Colors.red),
                                  //   ),
                                );
                              }
                            }
                          },
                          child: Text(
                            isCodeSent ? 'Login' : 'Verify',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 22,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
