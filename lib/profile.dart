// ignore_for_file: prefer_const_constructors, avoid_print

import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';

import 'login.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() => runApp(MaterialApp(
      home: ProfilePage(documentID: 'example_document_id'),
    ));

class ProfilePage extends StatefulWidget {
  final String? documentID;

  const ProfilePage({super.key, this.documentID});

  @override
  // ignore: library_private_types_in_public_api
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late User _user;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    String docId = widget.documentID ??
        '-O-voEROrG8MYsjOAFGF'; // Default document ID if not provided
    try {
      final userData = await fetchUserDataAsObject(docId);
      setState(() {
        _user = userData;
        _isLoading = false;
      });
    } catch (error) {
      // ignore: avoid_print
      print('Error fetching user data: $error');
      setState(() {
        _isLoading = false;
      });
      // Handle error as needed
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Scaffold(
        appBar: AppBar(
          title: Text('Profile'),
        ),
        body: _isLoading
            ? Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Container(
                            child: CircleAvatar(
                              radius: 50,
                              backgroundImage: NetworkImage(
                                  'https://static.vecteezy.com/system/resources/previews/009/749/643/original/woman-profile-mascot-illustration-female-avatar-character-icon-cartoon-girl-head-face-business-user-logo-free-vector.jpg'),
                              backgroundColor: Colors
                                  .grey, // Optional background color while loading/error
                              // Handle errors with errorBuilder
                              // errorBuilder: (context, error, stackTrace) {
                              //   return Text('Image not found');
                              // },
                            ),
                          ),
                          SizedBox(width: 24.0),
                          Container(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _user.name,
                                  style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold),
                                ),
                                SizedBox(height: 8.0),
                                Text(
                                  _user.email,
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.grey),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                    Divider(),
                    ListTile(
                      leading: Icon(Icons.person),
                      title: Text('Edit Profile'),
                      onTap: () {},
                    ),
                    ListTile(
                      leading: Icon(Icons.lock),
                      title: Text('Change Password'),
                      onTap: () {},
                    ),
                    ListTile(
                      leading: Icon(Icons.notifications),
                      title: Text('Notification Settings'),
                      onTap: () {},
                    ),
                    ListTile(
                      leading: Icon(Icons.language),
                      title: Text('Language'),
                      onTap: () {},
                    ),
                    ListTile(
                      leading: Icon(Icons.color_lens),
                      title: Text('Theme'),
                      onTap: () {},
                    ),
                    ListTile(
                      leading: Icon(Icons.exit_to_app),
                      title: Text('Logout'),
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text('Confirm Logout'),
                              content: Text('Are you sure you want to logout?'),
                              actions: <Widget>[
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () async {
                                    await FirebaseAuth.instance.signOut();
                                    Navigator.of(context).pushReplacement(
                                      MaterialPageRoute(
                                          builder: (context) => Login()),
                                    );
                                  },
                                  child: Text('Logout'),
                                ),
                              ],
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

class User {
  final String name;
  final String email;
  final String uid;

  User({
    required this.name,
    required this.email,
    required this.uid,
  });
}

Future<User> fetchUserDataAsObject(String docId) async {
  final url = Uri.https(
    'ambw-auth-171bb-default-rtdb.asia-southeast1.firebasedatabase.app',
    'users/$docId.json',
  );

  try {
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data != null) {
        return User(
          name: data['name'],
          email: data['email'],
          uid: data['uid'],
        );
      } else {
        throw Exception('No data found for the given document ID');
      }
    } else {
      throw Exception(
          'Failed to load data. Status code: ${response.statusCode}');
    }
  } catch (error) {
    print('Error fetching data: $error');
    throw Exception('Error fetching user data');
  }
}
