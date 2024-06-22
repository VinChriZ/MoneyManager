import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
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
        'category': data['category'],
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
        'category': data['category'],
        'icon': FontAwesomeIcons.arrowUp,
        'color': Colors.red,
      });
    });

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
              style: GoogleFonts.inter(
                  color: Colors.black, fontWeight: FontWeight.bold),
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
                  children: [
                    Container(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text('Account Balance',
                              style: GoogleFonts.inter(color: Colors.grey)),
                          Text('\$$accountBalance',
                              style: GoogleFonts.inter(
                                  fontSize: 36, fontWeight: FontWeight.bold)),
                          SizedBox(height: 16.0),
                        ],
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: _buildSummaryCard(
                              'Income',
                              '\$$totalIncome',
                              Colors.green,
                              Colors.white,
                              FontAwesomeIcons.arrowDown),
                        ),
                        SizedBox(width: 16.0),
                        Expanded(
                          child: _buildSummaryCard(
                              'Expenses',
                              '\$$totalExpenses',
                              Colors.red,
                              Colors.white,
                              FontAwesomeIcons.arrowUp),
                        ),
                      ],
                    ),
                    SizedBox(height: 16.0),
                    Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Spend Frequency',
                              style: GoogleFonts.inter(
                                  fontSize: 18, fontWeight: FontWeight.bold)),
                          _buildSpendFrequencyChart(), // Add chart here
                        ],
                      ),
                    ),
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

  Widget _buildSummaryCard(String title, String amount, Color color,
      Color arrowcolor, IconData icon) {
    return Card(
      color: color.withOpacity(1),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            FaIcon(icon, color: arrowcolor),
            SizedBox(height: 8.0),
            Text(amount,
                style: GoogleFonts.inter(
                    fontSize: 18, fontWeight: FontWeight.bold)),
            Text(title, style: GoogleFonts.inter(color: Colors.black)),
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

  Widget _buildSpendFrequencyChart() {
    return Container(
      height: 200,
      padding: const EdgeInsets.only(bottom: 18.0),
      child: LineChart(
        LineChartData(
          minX: 0,
          maxX: 6,
          minY: 0,
          maxY: 10,
          titlesData: FlTitlesData(
              leftTitles: AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              topTitles: AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              rightTitles:
                  AxisTitles(sideTitles: SideTitles(showTitles: false))),
          gridData: FlGridData(show: false),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: [
                FlSpot(0, 1),
                FlSpot(1, 3),
                FlSpot(2, 2),
                FlSpot(3, 8),
                FlSpot(4, 4),
                FlSpot(5, 6),
                FlSpot(6, 7),
              ],
              isCurved: true,
              color: Colors.purple.shade400,
              barWidth: 4,
              belowBarData: BarAreaData(
                show: true,
                color: Colors.purple.withOpacity(0.3),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentTransactions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Recent Transactions',
            style:
                GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold)),
        SizedBox(height: 16.0),
        ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: transactions.length,
          itemBuilder: (context, index) {
            final transaction = transactions[index];
            return ListTile(
              leading: FaIcon(transaction['icon'], color: transaction['color']),
              title: Text('\$${transaction['amount']}'),
              subtitle: Text(transaction['category']),
              trailing: Text(transaction['time'].toString()),
            );
          },
        ),
      ],
    );
  }
}
