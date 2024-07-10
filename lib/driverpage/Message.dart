import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Message extends StatelessWidget {
  final String name;
  final int age;
  final String address;
  final String phoneNumber;
  final String reason;

  Message({
    required this.name,
    required this.age,
    required this.address,
    required this.phoneNumber,
    required this.reason,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Message Details'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Name: $name'),
            Text('Age: $age'),
            Text('Address: $address'),
            Text('Phone Number: $phoneNumber'),
            Text('Reason: $reason'),
            // You can display other message details as needed
          ],
        ),
      ),
    );
  }
}