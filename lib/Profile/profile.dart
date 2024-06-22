import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_moneymanager/Profile/data_user.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'data_user.dart';
import 'user.dart'; // Assuming this contains your User class definition

class ProfilePage extends StatefulWidget {
  @override
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundImage: NetworkImage(
                              'https://static.vecteezy.com/system/resources/previews/009/749/643/original/woman-profile-mascot-illustration-female-avatar-character-icon-cartoon-girl-head-face-business-user-logo-free-vector.jpg'),
                          backgroundColor: Colors.grey,
                        ),
                        SizedBox(height: 16.0),
                        Text(
                          _user.name,
                          style: TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 8.0),
                        Text(
                          _user.email,
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
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
                    onTap: () {},
                  ),
                ],
              ),
            ),
    );
  }
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
      throw Exception('Failed to load data. Status code: ${response.statusCode}');
    }
  } catch (error) {
    print('Error fetching user data: $error');
    throw Exception('Error fetching user data');
  }
}