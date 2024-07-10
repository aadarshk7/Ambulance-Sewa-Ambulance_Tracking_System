import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:twilio_flutter/twilio_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(); // Load environment variables from .env file

  runApp(MaterialApp(
    home: MessageDriver(),
  ));
}

class MessageDriver extends StatefulWidget {
  @override
  _MessageDriverState createState() => _MessageDriverState();
}

class _MessageDriverState extends State<MessageDriver> {
  TextEditingController _nameController = TextEditingController();
  TextEditingController _ageController = TextEditingController();
  TextEditingController _addressController = TextEditingController();
  TextEditingController _phoneNumberController = TextEditingController();
  TextEditingController _reasonController = TextEditingController();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  late TwilioFlutter twilioFlutter;

  @override
  void initState() {
    super.initState();
    // Initialize TwilioFlutter with environment variables
    twilioFlutter = TwilioFlutter(
      accountSid: dotenv.env['TWILIO_ACCOUNT_SID']!,
      authToken: dotenv.env['TWILIO_AUTH_TOKEN']!,
      twilioNumber: dotenv.env['TWILIO_NUMBER']!,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Message Driver'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Patient Name'),
            ),
            TextField(
              controller: _ageController,
              decoration: InputDecoration(labelText: 'Patient Age'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _addressController,
              decoration: InputDecoration(labelText: 'Address'),
            ),
            TextField(
              controller: _phoneNumberController,
              decoration: InputDecoration(labelText: 'Phone Number'),
              keyboardType: TextInputType.phone,
            ),
            TextField(
              controller: _reasonController,
              decoration: InputDecoration(labelText: 'Reason (Disease or Accident)'),
            ),
            SizedBox(height: 16.0),
            OutlinedButton(
              onPressed: () {
                // Get the data from text controllers
                String name = _nameController.text;
                int age = int.tryParse(_ageController.text) ?? 0;
                String address = _addressController.text;
                String phoneNumber = _phoneNumberController.text;
                String reason = _reasonController.text;

                // Add data to Firestore
                _firestore.collection('patients').add({
                  'name': name,
                  'age': age,
                  'address': address,
                  'phoneNumber': phoneNumber,
                  'reason': reason,
                }).then((value) {
                  // Data added successfully
                  print('Data added to Firestore');

                  // Send SMS to the driver
                  twilioFlutter.sendSMS(
                    toNumber: '+9779706631613', // Example driver's number
                    messageBody: 'New patient:\nName: $name\nAge: $age\nAddress: $address\nPhone Number: $phoneNumber\nReason: $reason',
                  ).then((value) {
                    // Message sent successfully
                    print('Message sent to driver');

                    // Show a snackbar to notify the user
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Driver is on the way! Message sent to driver.'),
                        duration: Duration(seconds: 3),
                      ),
                    );
                  }).catchError((error) {
                    // Error handling
                    print('Failed to send message to driver: $error');
                  });

                }).catchError((error) {
                  // Error handling
                  print('Failed to add data: $error');
                });
              },
              child: Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}
