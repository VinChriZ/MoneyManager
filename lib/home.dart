import 'package:flutter/material.dart';

class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
      ),
      body: ListView(
        children: <Widget>[
          Card(
            child: ListTile(
              title: Text('Total Balance'),
              subtitle: Text('\$5000'),
            ),
          ),
          Card(
            child: ListTile(
              title: Text('Recent Transactions'),
              subtitle: Text('Grocery: \$50'),
            ),
          ),
          Card(
            child: ListTile(
              title: Text('Bill Reminder'),
              subtitle: Text('Rent due in 3 days'),
            ),
          ),
        ],
      ),
    );
  }
}
