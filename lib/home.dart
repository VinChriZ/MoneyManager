import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:fl_chart/fl_chart.dart';
import 'login.dart';

class HomeScreen extends StatefulWidget {
  final String? documentID;
  HomeScreen({this.documentID});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  double totalIncome = 0.0;
  double totalExpenses = 0.0;
  List<Map<String, dynamic>> transactions = [];
  bool isLoading = true;
  String selectedTimeFilter = 'Day';

  // Define your categories map here
  final Map<String, Map<String, dynamic>> categories = {
    'Salary': {'icon': Icons.money, 'color': Colors.blue},
    'Freelance': {'icon': Icons.laptop_mac, 'color': Colors.green},
    'Investments': {'icon': Icons.show_chart, 'color': Colors.orange},
    'Gifts': {'icon': Icons.card_giftcard, 'color': Colors.purple},
    'Rent': {'icon': Icons.home, 'color': Colors.brown},
    'Other': {'icon': Icons.category, 'color': Colors.grey},
  };
  @override
  void initState() {
    super.initState();
    fetchFinancialData();
  }

  Future<void> fetchFinancialData() async {
    await fetchTotalIncome();
    await fetchTotalExpenses();
    await fetchTransactions();
    setState(() {
      isLoading = false;
    });
  }

  Future<void> fetchTotalIncome() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    String uid = user.uid;
    CollectionReference incomesRef = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('incomes');

    QuerySnapshot snapshot = await incomesRef.get();
    double income = snapshot.docs.fold(0.0,
        (sum, doc) => sum + (doc.data() as Map<String, dynamic>)['amount']);

    setState(() {
      totalIncome = income;
    });
  }

  Future<void> fetchTotalExpenses() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    String uid = user.uid;
    CollectionReference expensesRef = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('expenses');

    QuerySnapshot snapshot = await expensesRef.get();
    double expense = snapshot.docs.fold(0.0,
        (sum, doc) => sum + (doc.data() as Map<String, dynamic>)['amount']);

    setState(() {
      totalExpenses = expense;
    });
  }

  Future<void> fetchTransactions() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    String uid = user.uid;
    CollectionReference incomesRef = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('incomes');

    CollectionReference expensesRef = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('expenses');

    QuerySnapshot incomeSnapshot = await incomesRef.get();
    QuerySnapshot expenseSnapshot = await expensesRef.get();

    List<Map<String, dynamic>> fetchedTransactions = [];

    incomeSnapshot.docs.forEach((doc) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      fetchedTransactions.add({
        'type': 'income',
        'amount': data['amount'],
        'time': data['time'],
        'icon': FontAwesomeIcons.arrowDown,
        'color': Colors.green,
      });
    });

    expenseSnapshot.docs.forEach((doc) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      fetchedTransactions.add({
        'type': 'expense',
        'amount': data['amount'],
        'time': data['time'],
        'icon': FontAwesomeIcons.arrowUp,
        'color': Colors.red,
      });
    });

    // Sort transactions by time
    fetchedTransactions.sort((a, b) => a['time'].compareTo(b['time']));

    setState(() {
      transactions = fetchedTransactions;
    });
  }

  @override
  Widget build(BuildContext context) {
    double accountBalance = totalIncome - totalExpenses;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const CircleAvatar(
              backgroundImage: NetworkImage('https://via.placeholder.com/150'),
            ),
            Text(
              'Home',
              style: TextStyle(color: Colors.black),
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
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Account Balance',
                        style: TextStyle(color: Colors.grey)),
                    Text('\$$accountBalance',
                        style: TextStyle(
                            fontSize: 36, fontWeight: FontWeight.bold)),
                    SizedBox(height: 16.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: _buildSummaryCard('Income', '\$$totalIncome',
                              Colors.green, FontAwesomeIcons.arrowDown),
                        ),
                        SizedBox(width: 16.0),
                        Expanded(
                          child: _buildSummaryCard(
                              'Expenses',
                              '\$$totalExpenses',
                              Colors.red,
                              FontAwesomeIcons.arrowUp),
                        ),
                      ],
                    ),
                    SizedBox(height: 16.0),
                    Text('Spend Frequency',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
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

  Widget _buildTimeFilter() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildTimeFilterChip('Day'),
        _buildTimeFilterChip('Week'),
        _buildTimeFilterChip('Month'),
      ],
    );
  }

  Widget _buildTimeFilterChip(String label) {
    return ChoiceChip(
      label: Text(label),
      selected: selectedTimeFilter == label,
      onSelected: (bool selected) {
        setState(() {
          selectedTimeFilter = label;
        });
        // Handle chip selection
      },
    );
  }

  Widget _buildRecentTransactions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Recent Transactions',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        SizedBox(height: 16.0),
        ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: transactions.length,
          itemBuilder: (context, index) {
            var transaction = transactions[index];
            IconData transactionIcon;
            Color transactionColor;
            String transactionCategory;
            if (transaction['type'] == 'income') {
              transactionCategory = 'Income';
            } else {
              transactionCategory = 'Expense';
            }

            if (categories.containsKey(transaction['category'])) {
              transactionIcon = categories[transaction['category']]?['icon'];
              transactionColor = categories[transaction['category']]?['color'];
            } else {
              // Use a default icon when the category is not found
              transactionIcon = Icons.category; // or any other default icon
              transactionColor = Colors.grey; // or any other default color
            }

            return ListTile(
              leading: FaIcon(
                transactionIcon,
                color: transactionColor,
              ),
              title: Text(transactionCategory),
              subtitle: Text(transaction['time']),
              trailing: Text('\$${transaction['amount']}',
                  style: TextStyle(
                      color: transactionColor, fontWeight: FontWeight.bold)),
            );
          },
        ),
      ],
    );
  }
}
