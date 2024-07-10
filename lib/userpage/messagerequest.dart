import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class MessageRequest extends StatefulWidget {
  @override
  _MessageRequestState createState() => _MessageRequestState();
}

class _MessageRequestState extends State<MessageRequest> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _reasonController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  late String _selectedReason = 'Disease';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Message Driver",
          style: TextStyle(
            color: Colors.lightBlue.shade900,
            fontSize: 30,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
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
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _phoneNumberController,
                          decoration: InputDecoration(
                            labelText: 'Phone Number',
                            prefixText: '+977 ',
                          ),
                          keyboardType: TextInputType.phone,
                          maxLength: 10,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _selectedReason,
                          onChanged: (value) {
                            setState(() {
                              _selectedReason = value!;
                              _reasonController.text = value;
                            });
                          },
                          items: [
                            DropdownMenuItem(
                              value: 'Disease',
                              child: Text('Disease'),
                            ),
                            DropdownMenuItem(
                              value: 'Accident',
                              child: Text('Accident'),
                            ),
                            DropdownMenuItem(
                              value: 'Asthma',
                              child: Text('Asthma'),
                            ),
                            DropdownMenuItem(
                              value: 'Mental Disorders',
                              child: Text('Mental Disorders'),
                            ),
                            DropdownMenuItem(
                              value: 'Others',
                              child: Text('Others'),
                            ),
                          ],
                          decoration: InputDecoration(labelText: 'Reason'),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.add),
                        onPressed: () {
                          // Implement logic for custom reason
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 16.0),
                  OutlinedButton(
                    onPressed: () {
                      if (_nameController.text.isEmpty || _ageController.text.isEmpty || _addressController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Please fill all required fields.'),
                            duration: Duration(seconds: 3),
                          ),
                        );
                        return;
                      }
                      if (_reasonController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Please enter a reason.'),
                            duration: Duration(seconds: 3),
                          ),
                        );
                        return;
                      }
                      if (_phoneNumberController.text.length != 10) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Please enter a valid phone number.'),
                            duration: Duration(seconds: 3),
                          ),
                        );
                        return;
                      }
                      // Get the data from text controllers
                      String name = _nameController.text;
                      int age = int.tryParse(_ageController.text) ?? 0;
                      String address = _addressController.text;
                      String phoneNumber = '+977${_phoneNumberController.text}';
                      String reason = _reasonController.text;

                      // Add data to Firestore
                      _firestore.collection('patients').add({
                        'name': name,
                        'age': age,
                        'address': address,
                        'phoneNumber': phoneNumber,
                        'reason': reason,
                      }).then((value) {
                        print('Data added to Firestore');
                      }).catchError((error) {
                        print('Failed to add data: $error');
                      });
                    },
                    child: Text('Submit'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
