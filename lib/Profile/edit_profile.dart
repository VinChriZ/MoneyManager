import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'data_user.dart';

class EditProfile extends StatefulWidget {
  EditProfile({Key? key}) : super(key: key);

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    String docId = Provider.of<UserData>(context, listen: false).documentId;
    final url = Uri.https(
      'ambw-auth-171bb-default-rtdb.asia-southeast1.firebasedatabase.app',
      'users/$docId.json',
    );
    final response = await http.get(url);
    final userData = json.decode(response.body);
    setState(() {
      nameController.text = userData['name'];
    });
  }

  Future<void> _saveProfile(BuildContext context) async {
    try {
      String docId = Provider.of<UserData>(context, listen: false).documentId;
      final url = Uri.https(
        'ambw-auth-171bb-default-rtdb.asia-southeast1.firebasedatabase.app',
        'users/$docId.json',
      );
      await http.patch(
        url,
        body: json.encode({
          'name': nameController.text,
        }),
      );

      // Update name in the UserData provider
      Provider.of<UserData>(context, listen: false).setName(nameController.text);

      // Show success dialog
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Success'),
            content: Text('Profile updated successfully'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    } catch (e) {
      // Show error dialog
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text('Failed to update profile: ${e.toString()}'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Profile'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20.0),
            const Icon(
              Icons.person,
              size: 100,
              color: Colors.blue,
            ),
            const SizedBox(height: 20.0),
            const Text(
              'Edit Profile',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10.0),
            const Text(
              'Please update your details',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16.0,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 40.0),

            // Name TextField
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'Name',
                prefixIcon: Icon(Icons.person),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
            ),
            const SizedBox(height: 16.0),

            // Save Button
            MaterialButton(
              minWidth: double.infinity,
              height: 60,
              onPressed: () {
                _saveProfile(context);
              },
              color: Color.fromARGB(255, 112, 69, 222),
              textColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 12.0),
              shape: RoundedRectangleBorder(
                side: BorderSide(color: Colors.black),
                borderRadius: BorderRadius.circular(15.0),
              ),
              child: const Text(
                'Save',
                style: TextStyle(fontSize: 18.0),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
