import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


import 'package:flutter/widgets.dart';
import 'package:flutter_moneymanager/get_started/get_started_page.dart';
import 'package:flutter_moneymanager/home.dart';
import 'package:flutter_moneymanager/login.dart';
import 'package:flutter_moneymanager/main.dart';class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin{

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

    Future.delayed(const Duration(seconds: 2), (){
      Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (_) => GetStartedPage(),
      ));
    });
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,overlays: SystemUiOverlay.values);
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue,Colors.purple],
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const[
            Text(
              'Money Managers',
              style: TextStyle(
                fontStyle: FontStyle.normal,
                color: Colors.white,
                fontSize: 30,
                fontWeight: FontWeight.bold
                ),
              )
            ],
          ),
      ),
      ),
    );
  }
}