import 'package:flutter/material.dart';
import 'package:flutter_moneymanager/home.dart';
import 'package:flutter_moneymanager/login.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Login(),
    );
  }
}

class Main extends StatefulWidget {
  @override
  _MainState createState() => _MainState();
}

class _MainState extends State<Main> {
  int _selectedIndex = 0;
  final List<Widget> _pages = [
    Home(),
  ];

  void _onTap(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.explore),
            label: '2',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bookmark),
            label: '3',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.star),
            label: '4',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: '5',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Color.fromARGB(255, 41, 152, 0),
        unselectedItemColor: Colors.black,
        onTap: _onTap,
      ),
    );
  }
}
