class UserObject {
  String uid;
  String name;
  String email;

  UserObject(
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
  factory UserObject.fromMap(Map<String, dynamic> map) {
    return UserObject(
      uid: map['uid'],
      name: map['name'],
      email: map['email'],
    );
  }

    factory UserObject.fromJson(Map<String, dynamic> json) {
    return UserObject(
      uid: json['uid'],
      name: json['name'],
      email: json['email'],
    );
  }
}