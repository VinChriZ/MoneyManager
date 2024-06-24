import 'dart:convert';
import 'package:flutter_moneymanager/Profile/change_password.dart';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../login.dart';
import 'edit_profile.dart';
import 'user.dart';
import 'data_user.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: ProfileCard(),
        ),
      ),
    );
  }
}

class ProfileCard extends StatefulWidget {
  @override
  _ProfileCardState createState() => _ProfileCardState();
}

class _ProfileCardState extends State<ProfileCard> {
  late UserObject _user = UserObject(uid: "", name: "Admin", email: "admin@gmail.com");
  bool _isLoading = true;

  @override
  void initState() {
    _fetchUserData();
    super.initState();
    _isLoading = false;
  }

  Future<void> _fetchUserData() async {
    String docId = Provider.of<UserData>(context, listen: false).documentId;
    if (docId.isEmpty) {
      print('Document ID is empty');
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      final userData = await fetchUserDataAsObject(docId);
      Provider.of<UserData>(context, listen: false).setName(userData.name);
      Provider.of<UserData>(context, listen: false).setBio(userData.bio);
      setState(() {
        _user = userData;
        _isLoading = false;
      });
    } catch (error) {
      print('Error fetching user data: $error');
      setState(() {
        _isLoading = false;
      });
      // Handle error as needed
    }
  }

  Future<UserObject> fetchUserDataAsObject(String docId) async {
  final url = Uri.https(
    'ambw-auth-171bb-default-rtdb.asia-southeast1.firebasedatabase.app',
    'users/$docId.json',
  );

  try {
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data != null) {
        return UserObject(
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
    print('Error fetching user data: $error');
    throw Exception('Error fetching user data');
  }
}







 @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: const Color.fromARGB(255, 109, 152, 217),
      child: Center(
        child: _isLoading
            ? const CircularProgressIndicator() // Show loading indicator
            : _user == null
                ? const Text('No user data available') // Handle no user data case
                : Stack(
                    alignment: Alignment.topCenter,
                    children: <Widget>[
                      Container(
                        width: MediaQuery.of(context).size.width * 0.9,
                        height: MediaQuery.of(context).size.height * 0.85,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Column(
                          children: <Widget>[
                            ClipRRect(
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(15),
                                topRight: Radius.circular(15),
                              ),
                              child: Image.asset(
                                'lib/assets/sea_background.jpg',
                                width: double.infinity,
                                height: 200,
                                fit: BoxFit.cover,
                              ),
                            ),
                            const Padding(
                              padding: EdgeInsets.all(40.0),
                              child: SizedBox(height: 20),
                            ), // Adjusted for spacing
                            Text(
                              _user.name, // Display user name dynamically
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.none
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              _user.email, // Display user email dynamically
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                                decoration: TextDecoration.none
                              ),
                            ),
                            const SizedBox(height: 20), // Adjusted for spacing
                            Container(
                              margin: const EdgeInsets.only(top: 20, left: 20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  ProfileRow(
                                    iconData: Icons.edit,
                                    title: 'Edit Profile',
                                    onPressed: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) => EditProfile(),
                                        ),
                                      );
                                    },
                                  ),
                                  const Divider(),
                                  ProfileRow(
                                    iconData: Icons.lock,
                                    title: 'Change Password',
                                    onPressed: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) => ChangePassword(),
                                        ),
                                      );
                                    },
                                  ),
                                  const Divider(),
                                  ProfileRow(
                                    iconData: Icons.logout,
                                    title: 'Logout',
                                    onPressed: () {
                                      FirebaseAuth.instance.signOut().then(
                                            (_) => Navigator.of(context).pushReplacement(
                                              MaterialPageRoute(
                                                builder: (context) => Login(),
                                              ),
                                            ),
                                          );
                                    },
                                  ),
                                  const Divider(),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Positioned(
                        top: 120, // Adjust this value to position the avatar as needed
                        child: CircleAvatar(
                          radius: 85,
                          backgroundImage: AssetImage('lib/assets/profile_man.jpeg'),
                          backgroundColor: Colors.transparent,
                        ),
                      ),
                    ],
                  ),
      ),
    );
  }
}

class ProfileRow extends StatelessWidget {
  final IconData iconData;
  final String title;
  final VoidCallback onPressed;

  const ProfileRow({
    required this.iconData,
    required this.title,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Icon(
            iconData,
            color: const Color.fromARGB(255, 33, 36, 66),
          ),
        ),
        ProfileButton(title: title, onPressed: onPressed),
      ],
    );
  }
}

class ProfileButton extends StatelessWidget {
  final String title;
  final VoidCallback onPressed;

  const ProfileButton({
    required this.title,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      child: Text(
        title,
        style: const TextStyle(
          color: Color.fromARGB(255, 58, 58, 58),
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
