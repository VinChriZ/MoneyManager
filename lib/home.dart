import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_moneymanager/report.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
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
  String? selectedCategory;

  final Map<String, Map<String, dynamic>> categoriesIncome = {
    'Salary': {
      'icon': Icons.money,
      'color': Colors.blue.withOpacity(0.7),
    },
    'Freelance': {
      'icon': Icons.laptop_mac,
      'color': Colors.green.withOpacity(0.7)
    },
    'Investments': {
      'icon': Icons.show_chart,
      'color': Colors.orange.withOpacity(0.7)
    },
    'Gifts': {
      'icon': Icons.card_giftcard,
      'color': Colors.purple.withOpacity(0.7)
    },
    'Rent': {'icon': Icons.home, 'color': Colors.brown.withOpacity(0.7)},
    'Other': {'icon': Icons.category, 'color': Colors.grey.withOpacity(0.7)},
  };

  final Map<String, Map<String, dynamic>> categoriesExpense = {
    'Food': {
      'icon': Icons.fastfood,
      'color': Colors.red.withOpacity(0.7),
    },
    'Transport': {
      'icon': Icons.directions_car,
      'color': Colors.blue.withOpacity(0.7)
    },
    'Shopping': {
      'icon': Icons.shopping_cart,
      'color': Colors.green.withOpacity(0.7)
    },
    'Entertainment': {
      'icon': Icons.movie,
      'color': Colors.purple.withOpacity(0.7)
    },
    'Bills': {
      'icon': Icons.receipt,
      'color': Colors.orange.withOpacity(0.7),
    },
    'Other': {
      'icon': Icons.category,
      'color': Colors.grey.withOpacity(0.7),
    },
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
      var category = data['category'];
      var categoryData =
          categoriesIncome[category] ?? categoriesIncome['Other'];
      fetchedTransactions.add({
        'type': 'income',
        'amount': data['amount'],
        'time': data['time'],
        'category': category,
        'icon': categoryData?['icon'],
        'color': categoryData?['color'],
      });
    });

    expenseSnapshot.docs.forEach((doc) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      var category = data['category'];
      var categoryData =
          categoriesExpense[category] ?? categoriesExpense['Other'];
      fetchedTransactions.add({
        'type': 'expense',
        'amount': data['amount'],
        'time': data['time'],
        'category': category,
        'icon': categoryData?['icon'],
        'color': categoryData?['color'],
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
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF38648c), Color(0xFFe9eff4)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: isLoading
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
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                              ),
                              Text(
                                'Welcome back!',
                                style: GoogleFonts.inter(
                                    fontSize: 18,
                                    fontWeight: FontWeight.normal,
                                    color: Colors.white),
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 20.0),
                      Card(
                        color: Color(0xFF38648c),
                        elevation: 4.0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.0),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Stack(
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Total Balance',
                                    style: GoogleFonts.inter(
                                        color: Colors.white, fontSize: 18),
                                  ),
                                  Text(
                                    'Rp. ${accountBalance.toStringAsFixed(1)}',
                                    style: GoogleFonts.inter(
                                        color: const Color(0xFFe9eff4),
                                        fontSize: 32,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  SizedBox(height: 16.0),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              FaIcon(FontAwesomeIcons.arrowDown,
                                                  color:
                                                      const Color(0xFFe9eff4)),
                                              SizedBox(width: 8.0),
                                              Text(
                                                'Income',
                                                style: GoogleFonts.inter(
                                                    color:
                                                        const Color(0xFFe9eff4),
                                                    fontSize: 14,
                                                    fontWeight:
                                                        FontWeight.bold),
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
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              FaIcon(FontAwesomeIcons.arrowUp,
                                                  color:
                                                      const Color(0xFFe9eff4)),
                                              SizedBox(width: 8.0),
                                              Text(
                                                'Expenses',
                                                style: GoogleFonts.inter(
                                                    color:
                                                        const Color(0xFFe9eff4),
                                                    fontSize: 14,
                                                    fontWeight:
                                                        FontWeight.bold),
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
                              Positioned(
                                top: 0,
                                right: 0,
                                child: ElevatedButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => ReportPage()),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Color(0xFFe9eff4),
                                    foregroundColor: Color(0xFF38648c),
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 12.0, vertical: 8.0),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                  ),
                                  child: Text(
                                    'View Report',
                                    style: GoogleFonts.inter(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
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
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white)),
                            _buildCategoryButtons(),
                          ],
                        ),
                      ),
                      SizedBox(height: 16.0),
                      _buildRecentTransactions(),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildCategoryButtons() {
    List<Widget> buttons = [
      _buildCategoryButton(null, Icons.category, Colors.white.withOpacity(0.7)),
    ];

    categoriesExpense.forEach((category, data) {
      buttons.add(_buildCategoryButton(category, data['icon'], data['color']));
    });

    categoriesIncome.forEach((category, data) {
      buttons.add(_buildCategoryButton(category, data['icon'], data['color']));
    });

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: buttons,
      ),
    );
  }

  Widget _buildCategoryButton(
    String? category,
    IconData iconData,
    Color buttonColor,
  ) {
    return ElevatedButton(
      onPressed: () {
        setState(() {
          selectedCategory = category;
        });
      },
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.all(8.0),
        backgroundColor:
            selectedCategory == category ? Color(0xFF71242c) : buttonColor,
        shape: CircleBorder(),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Icon(iconData, color: Colors.white.withOpacity(0.8)),
      ),
    );
  }

  Widget _buildRecentTransactions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Recent Transactions',
            style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white)),
        SizedBox(height: 16.0),
        Container(
          height: MediaQuery.of(context).size.height,
          child: ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: transactions.length,
            itemBuilder: (context, index) {
              final transaction = transactions[index];
              final isIncome = transaction['type'] == 'income';
              final amountText = isIncome
                  ? '+Rp. ${transaction['amount'].toStringAsFixed(0)}'
                  : '-Rp. ${transaction['amount'].toStringAsFixed(0)}';
              if (selectedCategory == null ||
                  selectedCategory == 'All' ||
                  selectedCategory == transaction['category']) {
                return Card(
                  elevation: 2.0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: ListTile(
                    leading:
                        Icon(transaction['icon'], color: transaction['color']),
                    title: Text(transaction['category'],
                        style: GoogleFonts.inter(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    subtitle: Text(transaction['time'].toString(),
                        style: GoogleFonts.inter(fontSize: 14)),
                    trailing: Text(
                      amountText,
                      style: TextStyle(
                          color: isIncome ? Colors.green : Colors.red,
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                );
              } else {
                return Container();
              }
            },
          ),
        ),
      ],
    );
  }
}
