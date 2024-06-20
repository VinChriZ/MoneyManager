import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'user.dart';

class FetchData extends StatefulWidget {
  const FetchData({super.key});

  @override
  State<FetchData> createState() => _FetchDataState();
}

class _FetchDataState extends State<FetchData> {
  List<UserObject> users = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rest API Call'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: users.length,
              itemBuilder: (context, index) {
                final user = users[index];
                return ListTile(
                  title: Text(user.name),
                  subtitle: Text(user.email),
                );
              },
            ),
          ),
          ElevatedButton(
            onPressed: fetchUsers,
            child: Container(
              margin: const EdgeInsets.all(20),
              child: const Text(
                'Fetch Data from Firebase',
                style: TextStyle(
                    // Additional text styles can be added here if needed
                    ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void fetchUsers() async {
    debugPrint('fetchUsers called');
    const url =
        "https://ambw-auth-171bb-default-rtdb.asia-southeast1.firebasedatabase.app/users.json";
    final uri = Uri.parse(url);
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      debugPrint('Check response status');
      final Map<String, dynamic> data = jsonDecode(response.body);
      final List<UserObject> loadedUsers = [];

      debugPrint('json decode done');
      data.forEach((key, value) {
        if (value != null) {
          debugPrint("UserObject not Null");
          final user = UserObject.fromJson(value);
          loadedUsers.add(user);
        } else {
          debugPrint("User Null");
        }
      });
      debugPrint('User loaded');

      setState(() {
        users = loadedUsers;
      });
      debugPrint("fetchUsers completed");
    } else {
      debugPrint("Failed to load data from Firebase");
    }
  }
}
