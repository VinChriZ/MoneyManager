import 'package:flutter/material.dart';
import 'package:flutter_moneymanager/home.dart';
import 'package:flutter_moneymanager/login.dart';
import 'package:flutter_moneymanager/profile.dart';
import 'package:flutter_moneymanager/income.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

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
    ProfilePage(),
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
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Color.fromARGB(255, 41, 152, 0),
        unselectedItemColor: Colors.black,
        onTap: _onTap,
      ),
      floatingActionButton: SpeedDial(
        icon: Icons.add,
        activeIcon: Icons.close,
        backgroundColor: Color.fromARGB(255, 41, 152, 0),
        overlayColor: Colors.black,
        overlayOpacity: 0.5,
        children: [
          SpeedDialChild(
            child: Icon(Icons.compare_arrows, color: Colors.white),
            backgroundColor: Colors.blue,
            label: 'Transfer',
            onTap: () {
              // Handle transfer action
            },
          ),
          SpeedDialChild(
            child: Icon(Icons.arrow_downward, color: Colors.white),
            backgroundColor: Colors.green,
            label: 'Income',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => IncomePage()),
              );
            },
          ),
          SpeedDialChild(
            child: Icon(Icons.arrow_upward, color: Colors.white),
            backgroundColor: Colors.red,
            label: 'Expense',
            onTap: () {
              // Handle expense action
            },
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
