import 'package:http/http.dart' as http;
import 'dart:convert';

class UserObject {
  final String email;
  final int expenses;
  final int income;
  final String money;
  final String name;
  final String uid;

  UserObject({
    required this.email,
    required this.expenses,
    required this.income,
    required this.money,
    required this.name,
    required this.uid,
  });

  factory UserObject.fromJson(Map<String, dynamic> json) {
    return UserObject(
      email: json['email'],
      expenses: json['expenses'],
      income: json['income'],
      money: json['money'],
      name: json['name'],
      uid: json['uid'],
    );
  }

  void fetchUsers() async {
    const url =
        "https://ambw-auth-171bb-default-rtdb.asia-southeast1.firebasedatabase.app/users.json";
    final uri = Uri.parse(url);
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      final List<UserObject> loadedUsers = [];

      data.forEach((key, value) {
        if (value != null) {
          final user = UserObject.fromJson(value);
          loadedUsers.add(user);
        } else {
          print("Value Empty");
        }
      });

      print("fetchUsers completed");
    } else {
      print("Failed to load data from Firebase");
    }
  }

}
