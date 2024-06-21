import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ExpensePage(),
    );
  }
}

class ExpensePage extends StatefulWidget {
  final String? documentId;

  ExpensePage({Key? key, this.documentId}) : super(key: key);

  @override
  _ExpensePageState createState() => _ExpensePageState();
}

class ExpenseData {
  final int day;
  int amount;

  ExpenseData(this.day, this.amount);
}

class _ExpensePageState extends State<ExpensePage> {
  int _currentMonth = DateTime.now().month;
  final List<String> monthNames = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December'
  ];

  List<Map<String, dynamic>> expenses = [];
  double totalExpense = 0.0;
  List<FlSpot> data = List.generate(31, (index) => FlSpot(index.toDouble(), 0));

  @override
  void initState() {
    super.initState();
    _fetchExpenses();
  }

  void _fetchExpenses() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return;
    }

    String uid = user.uid;
    CollectionReference expensesRef = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('expenses');

    QuerySnapshot snapshot = await expensesRef.get();
    List<Map<String, dynamic>> fetchedExpenses = snapshot.docs.map((doc) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      return {
        'category': data['category'],
        'amount': data['amount'],
        'time': data['time'],
        'icon': IconData(data['icon'], fontFamily: 'MaterialIcons'),
        'color': Color(data['color']),
      };
    }).toList();

    setState(() {
      expenses = fetchedExpenses;
      totalExpense =
          fetchedExpenses.fold(0.0, (sum, item) => sum + item['amount']);
      _updateChartData();
    });
  }

  void _addExpense(String category, double amount, String time, IconData icon,
      Color color) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return;
    }

    String uid = user.uid;
    CollectionReference expensesRef = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('expenses');

    await expensesRef.add({
      'category': category,
      'amount': amount,
      'time': time,
      'icon': icon.codePoint,
      'color': color.value,
    });

    setState(() {
      expenses.add({
        'category': category,
        'amount': amount,
        'time': time,
        'icon': icon,
        'color': color,
      });
      totalExpense += amount;
      _updateChartData();
    });
  }

  void _updateChartData() {
    List<FlSpot> newData =
        List.generate(31, (index) => FlSpot(index.toDouble(), 0));

    for (var expense in expenses) {
      var day = int.tryParse(
          expense['time'].split('-')[0].replaceAll(RegExp(r'\D'), ''));

      if (day != null && day >= 1 && day <= 31) {
        newData[day - 1] =
            FlSpot(day.toDouble(), newData[day - 1].y + expense['amount']);
      }
    }

    setState(() {
      data = newData;
    });
  }

  void _updateChartDataForMonth(int month) {
    List<FlSpot> newData =
        List.generate(31, (index) => FlSpot(index.toDouble(), 0));

    for (var expense in expenses) {
      var day = int.tryParse(
          expense['time'].split('-')[0].replaceAll(RegExp(r'\D'), ''));
      var expenseMonth = int.tryParse(
          expense['time'].split('-')[1].replaceAll(RegExp(r'\D'), ''));

      if (day != null && day >= 1 && day <= 31 && expenseMonth == month) {
        newData[day - 1] =
            FlSpot(day.toDouble(), newData[day - 1].y + expense['amount']);
      }
    }

    setState(() {
      data = newData;
    });
  }

  void _showPreviousMonth() {
    setState(() {
      if (_currentMonth > 1) {
        _currentMonth--;
      } else {
        _currentMonth = 12;
      }
      _updateChartDataForMonth(_currentMonth);
    });
  }

  void _showNextMonth() {
    setState(() {
      if (_currentMonth < 12) {
        _currentMonth++;
      } else {
        _currentMonth = 1;
      }
      _updateChartDataForMonth(_currentMonth);
    });
  }

  void _showAddExpenseDialog() {
    String category = 'Food';
    double amount = 0.0;
    String time =
        "${DateTime.now().day}-${DateTime.now().month}-${DateTime.now().year}";
    String customCategory = '';
    IconData icon = Icons.fastfood;
    Color color = Colors.red;

    final Map<String, Map<String, dynamic>> categories = {
      'Food': {'icon': Icons.fastfood, 'color': Colors.red},
      'Transport': {'icon': Icons.directions_car, 'color': Colors.blue},
      'Shopping': {'icon': Icons.shopping_cart, 'color': Colors.green},
      'Entertainment': {'icon': Icons.movie, 'color': Colors.purple},
      'Bills': {'icon': Icons.receipt, 'color': Colors.orange},
      'Other': {'icon': Icons.category, 'color': Colors.grey},
    };

    Future<void> _selectDate(BuildContext context, StateSetter setState) async {
      final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2000),
        lastDate: DateTime(2101),
      );
      if (picked != null && picked != DateTime.now()) {
        setState(() {
          time = "${picked.day}-${picked.month}-${picked.year}";
        });
      }
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add Expense'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    value: category,
                    items: categories.keys.map((String category) {
                      return DropdownMenuItem<String>(
                        value: category,
                        child: Text(category),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        category = value!;
                        icon = categories[category]!['icon'] as IconData;
                        color = categories[category]!['color'] as Color;
                      });
                    },
                    decoration: InputDecoration(labelText: 'Category'),
                  ),
                  if (category == 'Other')
                    TextField(
                      decoration: InputDecoration(labelText: 'Custom Category'),
                      onChanged: (value) {
                        customCategory = value;
                      },
                    ),
                  TextField(
                    decoration: InputDecoration(
                      labelText: 'Amount',
                      suffixText: '\$',
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      try {
                        amount = double.parse(value);
                      } catch (e) {
                        amount = 0.0;
                      }
                    },
                  ),
                  TextField(
                    decoration: InputDecoration(
                      labelText: 'Date',
                    ),
                    controller: TextEditingController(text: time),
                    readOnly: true,
                    onTap: () => _selectDate(context, setState),
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if ((category != 'Other' ||
                        (category == 'Other' && customCategory.isNotEmpty)) &&
                    time.isNotEmpty &&
                    amount > 0) {
                  _addExpense(category == 'Other' ? customCategory : category,
                      amount, time, icon, color);
                  Navigator.of(context).pop();
                } else {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: Text('Invalid Input'),
                        content: Text('Please fill in all the fields.'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text('OK'),
                          ),
                        ],
                      );
                    },
                  );
                }
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Expenses'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back),
                  onPressed: _showPreviousMonth,
                ),
                Text(
                  '${monthNames[_currentMonth - 1]}',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: Icon(Icons.arrow_forward),
                  onPressed: _showNextMonth,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Total Expense: \$${totalExpense.toStringAsFixed(2)}',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: LineChart(
                LineChartData(
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: data,
                      isCurved: true,
                      color: Color.fromARGB(255, 255, 0, 0),
                      barWidth: 2,
                      belowBarData: BarAreaData(show: false),
                    ),
                  ],
                  titlesData: FlTitlesData(show: false),
                  gridData: FlGridData(show: false),
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: expenses.length,
              itemBuilder: (context, index) {
                var expense = expenses[index];
                return ListTile(
                  leading: FaIcon(
                    expense['icon'],
                    color: expense['color'],
                  ),
                  title: Text(expense['category']),
                  subtitle: Text(expense['time']),
                  trailing: Text('\$${expense['amount']}'),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddExpenseDialog,
        child: Icon(Icons.add),
      ),
    );
  }
}
