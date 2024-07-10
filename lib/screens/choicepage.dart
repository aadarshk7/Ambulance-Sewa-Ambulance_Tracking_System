import 'dart:async';

import 'package:ambulancesewa/adminpage/adminoptionpage.dart';
import 'package:ambulancesewa/driverpage/DriverRegister.dart';
import 'package:ambulancesewa/login_signup/login_page.dart';
import 'package:ambulancesewa/userpage/user_page.dart';
import 'package:flutter/material.dart';

import '../adminpage/admin_page.dart';
import '../adminpage/adminotp.dart';
import '../driverpage/driver_page.dart';

class ChoicePage extends StatefulWidget {
  @override
  State<ChoicePage> createState() => _ChoicePageState();
}

class _ChoicePageState extends State<ChoicePage>
    with TickerProviderStateMixin {
  AnimationController? _controller;

  bool _emergencyVisible = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 400),
    );

    // Start blinking animation for emergency
    Timer.periodic(Duration(milliseconds: 350), (timer) {
      setState(() {
        _emergencyVisible = !_emergencyVisible;
      });
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: Container(
            child: Column(
              children: <Widget>[
                Container(
                  height: 420,
                  decoration: BoxDecoration(
                      image: DecorationImage(
                          image: AssetImage('assets/images/background.png'),
                          fit: BoxFit.fill)),
                  child: Stack(
                    children: <Widget>[
                      Positioned(
                          left: 12,
                          width: 70,
                          height: 180,
                          child: Container(
                            decoration: BoxDecoration(
                                image: DecorationImage(
                                    image: AssetImage(
                                        'assets/images/light-1.png'))),
                          )),
                      Positioned(
                          right: 40,
                          top: 40,
                          width: 80,
                          height: 150,
                          child: Container(
                            decoration: BoxDecoration(
                                image: DecorationImage(
                                    image:
                                        AssetImage('assets/images/clock.png'))),
                          )),
                      Positioned(
                          left: 75,
                          top: 370,
                          child: Container(
                            margin: EdgeInsets.all(10),
                            child: Center(
                              child: Text(
                                "Ambulance Sewa",
                                style: TextStyle(
                                  color: Colors.lightBlue.shade900,
                                  fontSize: 30,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          )),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(20.0),
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
                                  offset: Offset(0, 10))
                            ]),
                      ),
                      SizedBox(
                        height: 30,
                      ),
                      Container(
                        height: 50,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            gradient: LinearGradient(colors: [
                              Color.fromRGBO(143, 148, 251, 1),
                              Color.fromRGBO(143, 148, 251, .6),
                            ])),
                        child: Center(
                          child: TextButton(
                              onPressed: () {
                                Navigator.of(context).push(MaterialPageRoute(
                                    // builder: (BuildContext context) =>
                                    //     LoginScreen()));
                                    builder: (BuildContext context) =>
                                        LoginScreen()));
                              },
                              child: Text(
                                "User",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              )),
                        ),
                      ),
                      SizedBox(
                        height: 30,
                      ),
                      Container(
                        height: 50,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            gradient: LinearGradient(colors: [
                              Color.fromRGBO(143, 148, 251, 1),
                              Color.fromRGBO(143, 148, 251, .6),
                            ])),
                        child: Center(
                          child: TextButton(
                              onPressed: () {
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (BuildContext context) => AdminPhoneOTP()));
                                   // builder: (BuildContext context) =>
                                   //      AdminDriver()));
                                //  builder: (BuildContext context) =>
                                //      AdminPage(collectionName: 'users')));
                              },
                              child: Text(
                                "Admin",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              )),
                        ),
                      ),
                      SizedBox(
                        height: 30,
                      ),
                      Container(
                        height: 50,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            gradient: LinearGradient(colors: [
                              Color.fromRGBO(143, 148, 251, 1),
                              Color.fromRGBO(143, 148, 251, .6),
                            ])),
                        child: Center(
                          child: TextButton(
                              onPressed: () {
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (BuildContext context) =>
                                        DriverLogin()));
                              },
                              child: Text(
                                "Driver",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              )),
                        ),
                      ),
                      SizedBox(
                        height: 70,
                      ),
            // Emergency button with left-right animation
                      // Emergency button with left-right animation
                      // AnimatedContainer(
                      //   duration: Duration(milliseconds: 500),
                      //   width: _emergencyVisible ? 100 : 0,
                      //   height: 50,
                      //   decoration: BoxDecoration(
                      //     color: _emergencyVisible
                      //         ? Colors.red
                      //         : Colors.transparent,
                      //     borderRadius: BorderRadius.circular(15),
                      //   ),
                      //   margin: EdgeInsets.symmetric(horizontal: 0, vertical: 30),
                      //   child: Center(
                      //     child: TextButton(
                      //       onPressed: () {
                      //         // Add emergency action here
                      //         // For example, navigate to user's phone
                      //         // Replace 'UserMobilePhonePage' with the actual page
                      //         Navigator.push(
                      //           context,
                      //           MaterialPageRoute(
                      //             builder: (context) => LoginScreen(),
                      //           ),
                      //         );
                      //       },
                      //       child: Text(
                      //         "102",
                      //         style: TextStyle(
                      //           color: Colors.white,
                      //           fontSize: 18,
                      //           fontWeight: FontWeight.bold,
                      //         ),
                      //       ),
                      //     ),
                      //   ),
                      // ),





                    ],
                  ),
                )
              ],
            ),
          ),
        ));
  }
}
