import 'package:flutter/material.dart';
import 'package:flutter_moneymanager/main.dart';

class Login extends StatelessWidget {
  const Login({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => Main()),
            );
          },
          child: Text('Main'),
        ),
      ),
    );
  }
}
