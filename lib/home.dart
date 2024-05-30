import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:charts_flutter/flutter.dart' as charts;

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Money Manager')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            FinancialSummaryWidget(),
            NotificationsWidget(),
            AddFinancialReportButton(),
            FinancialChartsWidget(),
            FinancialReportsWidget(),
            ProfileSettingsWidget(),
          ],
        ),
      ),
    );
  }
}

class FinancialSummaryWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.0),
      margin: EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Balance: \$1000',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8.0),
          Text(
            'Income: \$2000',
            style: TextStyle(fontSize: 18, color: Colors.green),
          ),
          Text(
            'Expenses: \$1000',
            style: TextStyle(fontSize: 18, color: Colors.red),
          ),
        ],
      ),
    );
  }
}

class NotificationsWidget extends StatelessWidget {
  final List<String> notifications = [
    'New Transaction: \$100',
    'Bill Reminder: \$50 due tomorrow',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.0),
      margin: EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: notifications.map((notification) {
          return Slidable(
            key: ValueKey(notification),
            startActionPane: ActionPane(
              motion: DrawerMotion(),
              children: [
                SlidableAction(
                  onPressed: (context) {
                    // Handle delete action
                  },
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  icon: Icons.delete,
                  label: 'Delete',
                ),
              ],
            ),
            child: Container(
              margin: EdgeInsets.symmetric(vertical: 8.0),
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
              child: Text(
                notification,
                style: TextStyle(fontSize: 16),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class AddFinancialReportButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.0),
      margin: EdgeInsets.all(8.0),
      child: ElevatedButton(
        onPressed: () {
          // Handle adding financial report
        },
        child: Text('Add Financial Report'),
      ),
    );
  }
}

class FinancialChartsWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Placeholder for chart data
    var data = [
      charts.Series<int, int>(
        id: 'Expenses',
        data: [100, 200, 300],
        domainFn: (int value, int? index) => index ?? 0,
        measureFn: (int value, int? index) => value,
      ),
      charts.Series<int, int>(
        id: 'Income',
        data: [400, 500, 600],
        domainFn: (int value, int? index) => index ?? 0,
        measureFn: (int value, int? index) => value,
      ),
    ];

    return Container(
      padding: EdgeInsets.all(16.0),
      margin: EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Financial Charts',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8.0),
          SizedBox(
            height: 200.0,
            child: charts.LineChart(data),
          ),
        ],
      ),
    );
  }
}

class FinancialReportsWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.0),
      margin: EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Financial Reports',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8.0),
          Text(
            'Monthly Report: January',
            style: TextStyle(fontSize: 16),
          ),
          Text(
            'Income: \$2000, Expenses: \$1500, Balance: \$500',
            style: TextStyle(fontSize: 16),
          ),
          SizedBox(height: 8.0),
          Text(
            'Annual Report: 2023',
            style: TextStyle(fontSize: 16),
          ),
          Text(
            'Total Income: \$24000, Total Expenses: \$18000, Final Balance: \$6000',
            style: TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
}

class ProfileSettingsWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.0),
      margin: EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Profile Settings',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8.0),
          Text(
            'Name: John Doe',
            style: TextStyle(fontSize: 16),
          ),
          Text(
            'Email: johndoe@example.com',
            style: TextStyle(fontSize: 16),
          ),
          SizedBox(height: 8.0),
          ElevatedButton(
            onPressed: () {
              // Handle account settings
            },
            child: Text('Edit Profile'),
          ),
        ],
      ),
    );
  }
}

void main() => runApp(MaterialApp(
      home: HomeScreen(),
    ));
