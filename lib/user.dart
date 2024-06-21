class User {
  String uid;
  String name;
  String email;

  User(
    {
      required this.uid, 
      required this.name, 
      required this.email, 
    }
  );

    // Convert a User object into a map object
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email
    };
  }

    // Create a User object from a map object
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      uid: map['uid'],
      name: map['name'],
      email: map['email'],
    );
  }

    factory User.fromJson(Map<String, dynamic> json) {
    return User(
      uid: json['uid'],
      name: json['name'],
      email: json['email'],
    );
  }
}