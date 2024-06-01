import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'login.dart';

void main() {
  runApp(Home());
}

class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage('https://via.placeholder.com/150'),
            ),
            DropdownButton<String>(
              value: 'October',
              icon: Icon(Icons.keyboard_arrow_down),
              items: <String>['October', 'September', 'August']
                  .map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (_) {},
            ),
            Icon(Icons.notifications, color: Colors.purple),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              _signOut(context);
            },
            color: Colors.red,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Account Balance', style: TextStyle(color: Colors.grey)),
              Text('\$9400',
                  style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold)),
              SizedBox(height: 16.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: _buildSummaryCard('Income', '\$5000', Colors.green,
                        FontAwesomeIcons.arrowDown),
                  ),
                  SizedBox(width: 16.0),
                  Expanded(
                    child: _buildSummaryCard('Expenses', '\$1200', Colors.red,
                        FontAwesomeIcons.arrowUp),
                  ),
                ],
              ),
              SizedBox(height: 16.0),
              Text('Spend Frequency',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 16.0),
              _buildSpendFrequencyGraph(),
              SizedBox(height: 16.0),
              _buildTimeFilter(),
              SizedBox(height: 16.0),
              _buildRecentTransactions(),
            ],
          ),
        ),
      ),
    );
  }

  void _signOut(BuildContext context) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Logout'),
          content: Text('Are you sure you want to logout?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => Login()),
                );
              },
              child: Text('Logout'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSummaryCard(
      String title, String amount, Color color, IconData icon) {
    return Card(
      color: color.withOpacity(0.4),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            FaIcon(icon, color: color),
            SizedBox(height: 8.0),
            Text(amount,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text(title, style: TextStyle(color: Colors.black)),
          ],
        ),
      ),
    );
  }

  Widget _buildSpendFrequencyGraph() {
    var data = [
      charts.Series<int, int>(
        id: 'Spending',
        colorFn: (_, __) => charts.MaterialPalette.purple.shadeDefault,
        domainFn: (int sales, _) => sales,
        measureFn: (int sales, _) => sales,
        data: [5, 25, 100, 75],
      ),
    ];

    return Container(
      height: 200.0,
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: charts.LineChart(
        data,
        animate: true,
      ),
    );
  }

  Widget _buildTimeFilter() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildTimeFilterButton('Today'),
        _buildTimeFilterButton('Week'),
        _buildTimeFilterButton('Month'),
        _buildTimeFilterButton('Year'),
      ],
    );
  }

  Widget _buildTimeFilterButton(String text) {
    return ElevatedButton(
      onPressed: () {},
      child: Text(text),
      style: ElevatedButton.styleFrom(
        backgroundColor: text == 'Today' ? Colors.yellow : Colors.white,
        foregroundColor: text == 'Today' ? Colors.black : Colors.grey,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
      ),
    );
  }

  Widget _buildRecentTransactions() {
    final transactions = [
      {
        'category': 'Shopping',
        'amount': '-\$120',
        'time': '10:00 AM',
        'icon': Icons.shopping_bag,
        'color': Colors.orange
      },
      {
        'category': 'Subscription',
        'amount': '-\$80',
        'time': '03:30 PM',
        'icon': Icons.subscriptions,
        'color': Colors.purple
      },
      {
        'category': 'Food',
        'amount': '-\$32',
        'time': '07:30 PM',
        'icon': Icons.restaurant,
        'color': Colors.red
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Recent Transactions',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            TextButton(onPressed: () {}, child: Text('See All')),
          ],
        ),
        ...transactions.map((transaction) {
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: transaction['color'] as Color,
              child: Icon(transaction['icon'] as IconData, color: Colors.white),
            ),
            title: Text(transaction['category'] as String),
            subtitle: Text(transaction['time'] as String),
            trailing: Text(transaction['amount'] as String,
                style: TextStyle(color: Colors.red)),
          );
        }).toList(),
      ],
    );
  }
}
