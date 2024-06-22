import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_moneymanager/Profile/data_user.dart';
import 'package:flutter_moneymanager/home.dart';
import 'package:flutter_moneymanager/main.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'register.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _signUserIn(BuildContext context) async {
    _showLoadingDialog(context);

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
      //buat ambil documentID
      String? documentId = await checkEmailInDatabase(emailController.text.trim());

      // Access UserData instance and update documentId
      Provider.of<UserData>(context, listen: false).setDocumentID(documentId);

      Navigator.of(context).pop(); // Close the loading indicator dialog
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login successful')),
      );
      await Future.delayed(Duration(seconds: 2));
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => Main(documentID: documentId,)),
      );
    } catch (e) {
      Navigator.of(context).pop();
      _showErrorDialog(context, e.toString());
    }
  }

  //function untuk cek email ada atau tidak di database
  Future<String?> checkEmailInDatabase(String email) async {
  final url = Uri.https(
    'ambw-auth-171bb-default-rtdb.asia-southeast1.firebasedatabase.app',
    'users.json',
  );
  final response = await http.get(url);
  final responseData = jsonDecode(response.body);

  for (var key in responseData.keys) {
    if (responseData[key]['email'] == email) {
      return key; // Return the document ID if email is found
    }
  }
  return null; // Return null if email is not found
}

  void _showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }

  void _showErrorDialog(BuildContext context, String error) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Login Failed'),
          content: Text('Error: $error'),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 60.0),
              Icon(
                Icons.attach_money,
                size: 100,
                color: Color.fromARGB(255, 112, 69, 222),
              ),
              SizedBox(height: 10.0),
              Text(
                'Welcome Back',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10.0),
              Text(
                'Please login to your account',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16.0,
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(height: 40.0),
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  prefixIcon: Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              SizedBox(height: 16.0),
              TextField(
                controller: passwordController,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  prefixIcon: Icon(Icons.lock),
                ),
                obscureText: true,
              ),
              SizedBox(height: 32.0),
              MaterialButton(
                minWidth: double.infinity,
                height: 60,
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => Register()),
                  );
                },
                child: Text(
                  'Sign Up',
                  style: TextStyle(fontWeight: FontWeight.w600,fontSize: 18.0),
                ),
                color: Color.fromARGB(255, 112, 69, 222), 
                textColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 12.0),
                shape: RoundedRectangleBorder(
                  side: BorderSide(color: Colors.black),
                  borderRadius: BorderRadius.circular(15.0),
                ),
              ),
              SizedBox(height: 16.0),
              MaterialButton(
                minWidth: double.infinity,
                height: 60,
                onPressed: () => _signUserIn(context),
                child: Text(
                  'Login',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 18.0,
                  ),
                ),
                color: Colors.white, 
                textColor: Colors.black,
                padding: EdgeInsets.symmetric(vertical: 12.0),
                shape: RoundedRectangleBorder(
                  side: BorderSide(color: Colors.black),
                  borderRadius: BorderRadius.circular(15.0),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
