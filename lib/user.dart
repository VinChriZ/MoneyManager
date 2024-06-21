import 'package:firebase_database/firebase_database.dart';

class User {
  String uid;
  String name;
  String email;
  double money;
  double income;
  double expenses;

  User(
    {
      required this.uid, 
      required this.name, 
      required this.email, 
      required this.money,
      this.income = 0,
      this.expenses = 0
    }
  );

    // Convert a User object into a map object
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'money': money,
      'income': income,
      'expenses': expenses
    };
  }

    // Create a User object from a map object
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      uid: map['uid'],
      name: map['name'],
      email: map['email'],
      money: map['money'],
      income: map['income'],
      expenses: map['expenses']
    );
  }

  // Fetch user data  from Firebase Realtime Database
  static Future<User?> fetchUserDataFromFirebase(String email) async {
    DatabaseReference userRef = FirebaseDatabase.instance.reference().child('users').child(email);

    // Fetch data
    DataSnapshot snapshot = (await userRef.once()) as DataSnapshot;

    // Handle null case
    if (snapshot.value == null) {
      return null;
    }

     // Handle non-null case
    Map<String, dynamic> userData = Map<String, dynamic>.from(snapshot.value as Map<dynamic, dynamic>);
    return User.fromMap(userData);
  }
}