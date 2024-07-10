import 'package:ambulancesewa/login_signup/phoneopt.dart';
import 'package:ambulancesewa/login_signup/signup_page.dart';
import 'package:ambulancesewa/userpage/user_page.dart';
import 'package:ambulancesewa/screens/choicepage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LoginScreen extends StatefulWidget {
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _obscureText = true;
  GoogleSignIn googleAuth = GoogleSignIn();
  late String email='';
  late String password='';

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
                        fit: BoxFit.cover)),
                child: Stack(
                  children: <Widget>[
                    Positioned(
                        left: 145,
                        top: 333,
                        child: Container(
                          margin: EdgeInsets.all(10),
                          child: Center(
                            child: Text(
                              "Login",
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
                                offset: Offset(0, 10))
                          ]),
                      child: Column(
                        children: <Widget>[
                          Container(
                            padding: EdgeInsets.all(8.0),
                          ),
                          Container(
                            padding: EdgeInsets.all(8.0),
                            decoration: BoxDecoration(
                              //border: Border(bottom: BorderSide(color: Colors.grey[400]))!
                            ),
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
                            height: 77,
                            padding: EdgeInsets.all(8.0),
                            child: TextField(
                              decoration: InputDecoration(
                                labelText: "Password",
                                prefixIcon: Icon(Icons.lock),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    // Based on passwordVisible state choose the icon
                                    _obscureText ? Icons.visibility : Icons.visibility_off,
                                    color: Theme.of(context).primaryColorDark,
                                  ),
                                  onPressed: () {
                                    // Update the state i.e. toogle the state of passwordVisible variable
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

                          //Forgot Password option

                          // SizedBox(height: 12),
                          // Align(
                          //   alignment: Alignment.centerRight,
                          //   child: TextButton(
                          //     onPressed: () {
                          //       // Handle forgot password
                          //       Navigator.push(
                          //         context,
                          //         MaterialPageRoute(builder: (context) => ForgotPassword()),
                          //       );
                          //     },
                          //     child: const Text(
                          //       "Forgot Password?",
                          //       style: TextStyle(
                          //         color: Colors.blue,
                          //         fontWeight: FontWeight.bold,
                          //       ),
                          //     ),
                          //   ),
                          // ),

                        ],
                      ),
                    ),
                    SizedBox(
                      height: 18,
                    ),
                    Container(
                      height: 50,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        gradient: LinearGradient(colors: [
                          Color.fromRGBO(143, 148, 251, 1),
                          Color.fromRGBO(143, 148, 251, .6),
                        ]),
                      ),
                      child: Center(
                        child: TextButton(
                          onPressed: () async {
                            // Add validation checks here
                            if (email == null ||
                                email.isEmpty ||
                                password == null ||
                                password.isEmpty) {
                              const snackdemo = SnackBar(
                                content:
                                Text("Please enter email and password"),
                                backgroundColor: Colors.red,
                                elevation: 10,
                                behavior: SnackBarBehavior.floating,
                                margin: EdgeInsets.all(5),
                              );
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(snackdemo);
                              return; // Return from the function if validation fails
                            }

                            String errorMessage = '';
                            try {
                              UserCredential userCredential = await FirebaseAuth
                                  .instance
                                  .signInWithEmailAndPassword(
                                email: email,
                                password: password,
                              );
                              // If the sign-in is successful, navigate to the homepage.
                              Navigator.pushNamed(context, '/user_page');
                            } on FirebaseAuthException catch (e) {
                              if (e.code == 'user-not-found') {
                              } else if (e.code == 'wrong-password') {}

                              final snackdemo = SnackBar(
                                content: Text("Email and Password may be wrong"),
                                // Display the error message
                                backgroundColor: Colors.red,
                                elevation: 10,
                                behavior: SnackBarBehavior.floating,
                                margin: EdgeInsets.all(5),
                              );
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(snackdemo);
                            } catch (e) {
                              print('Exception caught: $e');
                            }
                          },
                          child: Text(
                            "Login",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 22),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 23,
                    ),
                    //Phone Page
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          //MaterialPageRoute(builder: (context) => PhonePage()),
                         MaterialPageRoute(builder: (context) => PhoneOTP()),


                          //this
                        );
                      },
                      // child: const Text(
                      //       "Forgot Password?",
                      //       style: TextStyle(
                      //         color: Colors.blue,
                      //         fontWeight: FontWeight.bold,
                      //       ),
                      //     ),
                      child: Text(
                        "Phone OTP Verification",
                        style: TextStyle(
                            color:Colors.blue,fontWeight: FontWeight.bold,
                            // color: Color.fromRGBO(143, 148, 251, 1),
                            fontSize: 18),
                      ),
                    ),
                    SizedBox(
                        height:
                        19 // Add some space between the two text widgets
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          // admin page shouldn't be there
                          MaterialPageRoute(
                               builder: (context) =>
                                   SignUpPage()), // Replace with your SignupPage

                        );
                      },
                      child: Text(
                        "Create an Account",
                        style: TextStyle(
                          //color: Color.fromRGBO(143, 148, 251, 1),
                            color:Colors.blue,fontWeight: FontWeight.bold,fontSize: 16
                        ),
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        ));
  }
}
