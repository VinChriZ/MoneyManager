import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'main.dart';

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
  int _currentYear = DateTime.now().year;
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

  DateTime parseDate(String dateStr) {
    List<String> parts = dateStr.split('-');
    if (parts.length == 3) {
      int day = int.parse(parts[0]);
      int month = int.parse(parts[1]);
      int year = int.parse(parts[2]);
      return DateTime(year, month, day);
    }
    throw FormatException("Invalid date format");
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
        'documentId': doc.id, // Add the document ID for deletion
        'category': data['category'],
        'amount': data['amount'],
        'time': data['time'],
        'icon': IconData(data['icon'], fontFamily: 'MaterialIcons'),
        'color': Color(data['color']),
      };
    }).toList();

    setState(() {
      expenses = fetchedExpenses.where((expense) {
        DateTime expenseDate = parseDate(expense['time']);
        return expenseDate.month == _currentMonth &&
            expenseDate.year == _currentYear;
      }).toList();
      totalExpense = expenses.fold(0.0, (sum, item) => sum + item['amount']);
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
    Navigator.of(context).pop();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => Main()),
    );
  }

  void _deleteExpense(String documentId) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      // Handle the case where the user is not authenticated
      return;
    }

    String uid = user.uid;
    CollectionReference expensesRef = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('expenses');

    await expensesRef.doc(documentId).delete();

    setState(() {
      expenses.removeWhere((expense) => expense['documentId'] == documentId);
      totalExpense = expenses.fold(0.0, (sum, item) => sum + item['amount']);
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

  void _updateChartDataForMonth(int month, int year) {
    List<FlSpot> newData =
        List.generate(31, (index) => FlSpot(index.toDouble(), 0));

    for (var expense in expenses) {
      DateTime expenseDate = parseDate(expense['time']);
      if (expenseDate.month == month && expenseDate.year == year) {
        int day = expenseDate.day;
        newData[day - 1] =
            FlSpot(day.toDouble(), newData[day - 1].y + expense['amount']);
      }
    }

    setState(() {
      data = newData;
      totalExpense = expenses.fold(0.0, (sum, item) => sum + item['amount']);
    });
  }

  void _showPreviousMonth() {
    setState(() {
      if (_currentMonth > 1) {
        _currentMonth--;
      } else {
        _currentMonth = 12;
        _currentYear--;
      }
      _fetchExpenses();
    });
  }

  void _showNextMonth() {
    setState(() {
      if (_currentMonth < 12) {
        _currentMonth++;
      } else {
        _currentMonth = 1;
        _currentYear++;
      }
      _fetchExpenses();
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

    TextEditingController amountController = TextEditingController();
    TextEditingController timeController = TextEditingController(text: time);

    final Map<String, Map<String, dynamic>> categories = {
      'Food': {'icon': Icons.fastfood, 'color': Colors.red},
      'Transport': {'icon': Icons.directions_car, 'color': Colors.blue},
      'Shopping': {'icon': Icons.shopping_cart, 'color': Colors.green},
      'Entertainment': {'icon': Icons.movie, 'color': Colors.purple},
      'Bills': {'icon': Icons.receipt, 'color': Colors.orange},
      'Rent': {'icon': Icons.home, 'color': Colors.brown},
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
          timeController.text = time; // Update the controller's text
        });
      }
    }

    // showDialog(
    //   context: context,
    //   builder: (context) {
    //     return Dialog(
    //       shape: RoundedRectangleBorder(
    //         borderRadius: BorderRadius.circular(20.0),
    //       ),
    //       child: Container(
    //         padding: EdgeInsets.all(20.0),
    //         decoration: BoxDecoration(
    //           color: Colors.white,
    //           borderRadius: BorderRadius.circular(20.0),
    //         ),
    //         child: StatefulBuilder(
    //           builder: (BuildContext context, StateSetter setState) {
    //             return SingleChildScrollView(
    //               child: Column(
    //                 mainAxisSize: MainAxisSize.min,
    //                 children: [
    //                   Text(
    //                     'Add Expense',
    //                     style: GoogleFonts.inter(
    //                       fontSize: 24.0,
    //                       fontWeight: FontWeight.bold,
    //                       color: Colors.red,
    //                     ),
    //                   ),
    //                   SizedBox(height: 20.0),
    //                   DropdownButtonFormField<String>(
    //                     value: category,
    //                     items: categories.keys.map((String category) {
    //                       return DropdownMenuItem<String>(
    //                         value: category,
    //                         child: Row(
    //                           children: [
    //                             Icon(categories[category]!['icon'] as IconData,
    //                                 color: categories[category]!['color']
    //                                     as Color),
    //                             SizedBox(width: 10.0),
    //                             Text(category),
    //                           ],
    //                         ),
    //                       );
    //                     }).toList(),
    //                     onChanged: (value) {
    //                       setState(() {
    //                         category = value!;
    //                         icon = categories[category]!['icon'] as IconData;
    //                         color = categories[category]!['color'] as Color;
    //                       });
    //                     },
    //                     decoration: InputDecoration(
    //                       labelText: 'Category',
    //                       border: OutlineInputBorder(),
    //                     ),
    //                   ),
    //                   if (category == 'Other')
    //                     Column(
    //                       children: [
    //                         SizedBox(height: 10.0),
    //                         TextField(
    //                           decoration: InputDecoration(
    //                             labelText: 'Custom Category',
    //                             border: OutlineInputBorder(),
    //                           ),
    //                           onChanged: (value) {
    //                             customCategory = value;
    //                           },
    //                         ),
    //                       ],
    //                     ),
    //                   SizedBox(height: 10.0),
    //                   TextField(
    //                     controller: amountController,
    //                     decoration: InputDecoration(
    //                       labelText: 'Amount',
    //                       border: OutlineInputBorder(),
    //                       suffixText: '\$',
    //                     ),
    //                     keyboardType: TextInputType.number,
    //                     onChanged: (value) {
    //                       try {
    //                         amount = double.parse(value);
    //                       } catch (e) {
    //                         amount = 0.0;
    //                       }
    //                     },
    //                   ),
    //                   SizedBox(height: 10.0),
    //                   TextField(
    //                     controller: timeController,
    //                     decoration: InputDecoration(
    //                       labelText: 'Date',
    //                       border: OutlineInputBorder(),
    //                     ),
    //                     readOnly: true,
    //                     onTap: () => _selectDate(context, setState),
    //                   ),
    //                   SizedBox(height: 20.0),
    //                   Row(
    //                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //                     children: [
    //                       TextButton(
    //                         onPressed: () {
    //                           Navigator.of(context).pop();
    //                         },
    //                         child: Text(
    //                           'Cancel',
    //                           style: TextStyle(
    //                             color: Colors.red,
    //                           ),
    //                         ),
    //                       ),
    //                       ElevatedButton(
    //                         onPressed: () {
    //                           if ((category != 'Other' ||
    //                                   (category == 'Other' &&
    //                                       customCategory.isNotEmpty)) &&
    //                               time.isNotEmpty &&
    //                               amount > 0) {
    //                             _addExpense(
    //                                 category == 'Other'
    //                                     ? customCategory
    //                                     : category,
    //                                 amount,
    //                                 time,
    //                                 icon,
    //                                 color);
    //                             Navigator.of(context).pop();
    //                           } else {
    //                             showDialog(
    //                               context: context,
    //                               builder: (context) {
    //                                 return AlertDialog(
    //                                   title: Text('Invalid Input'),
    //                                   content: Text(
    //                                       'Please fill in all the fields.'),
    //                                   actions: [
    //                                     TextButton(
    //                                       onPressed: () {
    //                                         Navigator.of(context).pop();
    //                                       },
    //                                       child: Text('OK'),
    //                                     ),
    //                                   ],
    //                                 );
    //                               },
    //                             );
    //                           }
    //                         },
    //                         child: Text('Add'),
    //                         style: ElevatedButton.styleFrom(
    //                           backgroundColor: Colors.red,
    //                           foregroundColor: Colors.white,
    //                           shape: RoundedRectangleBorder(
    //                             borderRadius: BorderRadius.circular(20.0),
    //                           ),
    //                         ),
    //                       ),
    //                     ],
    //                   ),
    //                 ],
    //               ),
    //             );
    //           },
    //         ),
    //       ),
    //     );
    //   },
    // );
    showModalBottomSheet(
        context: context,
        builder: (context) => Container(
              width: double.infinity,
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    Column(
                      children: [
                        Container(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'How much?',
                                style: GoogleFonts.inter(
                                    fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(
                                height: 8,
                              ),
                              TextField(
                                style: GoogleFonts.inter(
                                    fontSize: 36, fontWeight: FontWeight.bold),
                                controller: amountController,
                                decoration: InputDecoration(
                                  prefixIcon: Text('Rp.',
                                      style: GoogleFonts.inter(
                                          fontSize: 36,
                                          fontWeight: FontWeight.bold)),
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
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 16,
                        ),
                        DropdownButtonFormField<String>(
                          value: category,
                          items: categories.keys.map((String category) {
                            return DropdownMenuItem<String>(
                              value: category,
                              child: Row(
                                children: [
                                  Icon(
                                      categories[category]!['icon'] as IconData,
                                      color: categories[category]!['color']
                                          as Color),
                                  SizedBox(width: 10.0),
                                  Text(category),
                                ],
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              category = value!;
                              icon = categories[category]!['icon'] as IconData;
                              color = categories[category]!['color'] as Color;
                            });
                          },
                          decoration: InputDecoration(
                            labelText: 'Category',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        if (category == 'Other')
                          Column(
                            children: [
                              SizedBox(height: 10.0),
                              TextField(
                                decoration: InputDecoration(
                                  labelText: 'Custom Category',
                                  border: OutlineInputBorder(),
                                ),
                                onChanged: (value) {
                                  customCategory = value;
                                },
                              ),
                            ],
                          ),
                        SizedBox(
                          height: 16,
                        ),
                        TextField(
                          controller: timeController,
                          decoration: InputDecoration(
                            labelText: 'Date',
                            border: OutlineInputBorder(),
                          ),
                          readOnly: true,
                          onTap: () => _selectDate(context, setState),
                        ),
                        SizedBox(height: 16.0),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            MaterialButton(
                              onPressed: () {
                                if ((category != 'Other' ||
                                        (category == 'Other' &&
                                            customCategory.isNotEmpty)) &&
                                    time.isNotEmpty &&
                                    amount > 0) {
                                  _addExpense(
                                      category == 'Other'
                                          ? customCategory
                                          : category,
                                      amount,
                                      time,
                                      icon,
                                      color);
                                  Navigator.of(context).pop();
                                } else {
                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        title: Text('Invalid Input'),
                                        content: Text(
                                            'Please fill in all the fields.'),
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
                              minWidth: double.infinity,
                              color: Colors.red,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
                              height: 50,
                              child: Text("Add",
                                  style: GoogleFonts.inter(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold)),
                            ),
                            SizedBox(
                              height: 16,
                            ),
                            MaterialButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              minWidth: double.infinity,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  side:
                                      BorderSide(color: Colors.red, width: 2)),
                              height: 50,
                              child: Text("Cancel",
                                  style: GoogleFonts.inter(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Expenses'),
        backgroundColor: Colors.red,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.red.shade200, Colors.red.shade600],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: _showPreviousMonth,
                  ),
                  Text(
                    '${monthNames[_currentMonth - 1]} $_currentYear',
                    style: GoogleFonts.inter(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                  IconButton(
                    icon: Icon(Icons.arrow_forward, color: Colors.white),
                    onPressed: _showNextMonth,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Card(
                color: Colors.red.shade700,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.0),
                ),
                elevation: 4.0,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment:
                        MainAxisAlignment.center, // Center the content
                    children: [
                      FaIcon(
                        FontAwesomeIcons.moneyBillTransfer,
                        color: Colors.white,
                      ),
                      SizedBox(width: 8.0), // Add space between icon and text
                      Text(
                        'Total Expense: \Rp. ${totalExpense.toStringAsFixed(2)}',
                        style: GoogleFonts.inter(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 16.0),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                  elevation: 4.0,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: LineChart(
                      LineChartData(
                        gridData: FlGridData(show: false),
                        titlesData: FlTitlesData(show: false),
                        borderData: FlBorderData(show: true),
                        lineBarsData: [
                          LineChartBarData(
                            spots: data,
                            isCurved: false,
                            color: Colors.red,
                            barWidth: 4,
                            dotData: FlDotData(show: true),
                            belowBarData: BarAreaData(
                              show: true,
                              color: Colors.red.withOpacity(0.3),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                  elevation: 4.0,
                  child: ListView.builder(
                    itemCount: expenses.length,
                    itemBuilder: (context, index) {
                      var expense = expenses[index];
                      return ListTile(
                        leading: FaIcon(
                          expense['icon'],
                          color: expense['color'],
                        ),
                        title: Text(expense['category'],
                            style: GoogleFonts.inter(fontSize: 16)),
                        subtitle: Text(expense['time'],
                            style: GoogleFonts.inter(fontSize: 14)),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Rp. ${expense['amount']}',
                              style: GoogleFonts.inter(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            IconButton(
                              icon: Icon(Icons.delete),
                              onPressed: () =>
                                  _deleteExpense(expense['documentId']),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddExpenseDialog,
        child: Icon(Icons.add,color: Colors.white,),
        backgroundColor: Colors.red,
      ),
    );
  }
}
