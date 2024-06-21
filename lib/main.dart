import 'package:flutter/material.dart';
import 'package:flutter_moneymanager/auth_page.dart';
import 'package:flutter_moneymanager/home.dart';
import 'package:flutter_moneymanager/login.dart';
import 'package:flutter_moneymanager/profile.dart';
import 'package:flutter_moneymanager/income.dart';
import 'package:flutter_moneymanager/expense.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'data_user.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => UserData(), // Provide UserData instance
      child: MaterialApp(
        home: AuthPage(),
      ),
    );
  }
}

class Main extends StatefulWidget {
  final String? documentID;
  Main({Key? mykey, this.documentID}) : super(key: mykey);

  @override
  _MainState createState() => _MainState();
}

class _MainState extends State<Main> {
  int _selectedIndex = 0;
  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      HomeScreen(documentID: widget.documentID),
      ProfilePage(),
    ];
  }

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
            child: Icon(Icons.arrow_downward, color: Colors.white),
            backgroundColor: Colors.green,
            label: 'Income',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      IncomePage(documentId: widget.documentID),
                ),
              );
            },
          ),
          SpeedDialChild(
            child: Icon(Icons.arrow_upward, color: Colors.white),
            backgroundColor: Colors.red,
            label: 'Expense',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ExpensePage()),
              );
            },
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
