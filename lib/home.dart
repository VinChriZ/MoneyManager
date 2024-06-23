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
        'time': data['time'], // Date in string format "21-6-2024"
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
        'time': data['time'], // Date in string format "21-6-2024"
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
    User? currentUser = FirebaseAuth.instance.currentUser;
    String userName = currentUser?.displayName ?? "User";

    return Scaffold(
      backgroundColor: Color.fromARGB(251, 253, 254, 255),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const CircleAvatar(
                          backgroundImage:
                              NetworkImage('https://via.placeholder.com/150'),
                        ),
                        SizedBox(width: 8.0),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Hi $userName',
                              style: GoogleFonts.inter(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              'Welcome back!',
                              style: GoogleFonts.inter(
                                  fontSize: 18, fontWeight: FontWeight.normal),
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 20.0),
                    Card(
                      color: Color(0xFF38648c),
                      elevation: 4.0,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Total Balance',
                              style: GoogleFonts.inter(
                                  color: Colors.white, fontSize: 18),
                            ),
                            Text(
                              'Rp ${accountBalance.toStringAsFixed(1)}',
                              style: GoogleFonts.inter(
                                  color: const Color(0xFFe9eff4),
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 16.0),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        FaIcon(FontAwesomeIcons.arrowDown,
                                            color: const Color(0xFFe9eff4)),
                                        SizedBox(width: 8.0),
                                        Text(
                                          'Income',
                                          style: GoogleFonts.inter(
                                              color: const Color(0xFFe9eff4),
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 4.0),
                                    Text(
                                      'Rp $totalIncome',
                                      style: GoogleFonts.inter(
                                          fontSize: 14,
                                          color: const Color(0xFFe9eff4)),
                                    ),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        FaIcon(FontAwesomeIcons.arrowUp,
                                            color: const Color(0xFFe9eff4)),
                                        SizedBox(width: 8.0),
                                        Text(
                                          'Expenses',
                                          style: GoogleFonts.inter(
                                              color: const Color(0xFFe9eff4),
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 4.0),
                                    Text(
                                      'Rp $totalExpenses',
                                      style: GoogleFonts.inter(
                                          fontSize: 14,
                                          color: const Color(0xFFe9eff4)),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 16.0),
                    Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Categories',
                              style: GoogleFonts.inter(
                                  fontSize: 18, fontWeight: FontWeight.bold)),
                          // _buildSpendFrequencyChart(),
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
    Map<int, double> incomeTransactions = {};
    Map<int, double> expenseTransactions = {};

    // Initialize the maps with zero values for each day of the month
    for (int day = 1; day <= 30; day++) {
      incomeTransactions[day] = 0;
      expenseTransactions[day] = 0;
    }

    for (var transaction in transactions) {
      String date = transaction['time'];
      int day = int.parse(date.split('-')[0]);
      if (transaction['type'] == 'income') {
        incomeTransactions[day] =
            (incomeTransactions[day] ?? 0) + transaction['amount'];
      } else if (transaction['type'] == 'expense') {
        expenseTransactions[day] =
            (expenseTransactions[day] ?? 0) + transaction['amount'];
      }
    }

    List<FlSpot> incomeSpots = incomeTransactions.entries
        .map((entry) => FlSpot(entry.key.toDouble(), entry.value))
        .toList();

    List<FlSpot> expenseSpots = expenseTransactions.entries
        .map((entry) => FlSpot(entry.key.toDouble(), entry.value))
        .toList();

    return Container(
      height: 300, // Increased height for better y-axis visibility
      padding: const EdgeInsets.only(bottom: 18.0),
      child: LineChart(
        LineChartData(
          minX: 1,
          maxX: 30,
          minY: 0,
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 100, // Adjust interval for y-axis titles
                getTitlesWidget: (value, meta) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: Text(value.toString(),
                        style: TextStyle(color: Colors.black, fontSize: 10)),
                  );
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(value.toInt().toString(),
                        style: TextStyle(color: Colors.black, fontSize: 10)),
                  );
                },
              ),
            ),
            topTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: true,
            horizontalInterval:
                100, // Adjust interval for horizontal grid lines
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: Colors.grey.withOpacity(0.3),
                strokeWidth: 1,
              );
            },
            getDrawingVerticalLine: (value) {
              return FlLine(
                color: Colors.grey.withOpacity(0.3),
                strokeWidth: 1,
              );
            },
          ),
          borderData: FlBorderData(
            show: true,
            border: Border.all(color: Colors.grey.withOpacity(0.5), width: 1),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: incomeSpots,
              isCurved: true,
              color: Colors.green,
              barWidth: 4,
              belowBarData: BarAreaData(
                show: true,
                color: Colors.green.withOpacity(0.3),
              ),
            ),
            LineChartBarData(
              spots: expenseSpots,
              isCurved: true,
              color: Colors.red,
              barWidth: 4,
              belowBarData: BarAreaData(
                show: true,
                color: Colors.red.withOpacity(0.3),
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
