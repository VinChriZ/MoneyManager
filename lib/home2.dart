import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:charts_flutter/flutter.dart' as charts;

void main() {
  runApp(HomeScreen2());
}

class HomeScreen2 extends StatelessWidget {
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
                  SizedBox(width: 16.0), // Add some space between the cards
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

  Widget _buildSummaryCard(
      String title, String amount, Color color, IconData icon) {
    return Card(
      color: color.withOpacity(0.4), // Adjusted opacity for more vibrant colors
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
    // Placeholder for the graph widget. You can replace it with an actual graph implementation.
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