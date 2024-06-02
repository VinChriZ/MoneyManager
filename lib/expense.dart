import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:charts_flutter/flutter.dart' as charts;

class ExpensePage extends StatefulWidget {
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

  List<Map<String, dynamic>> expenses = [
    {
      'category': 'Rent',
      'amount': '-\$1200',
      'time': '1-5-2024',
      'icon': Icons.home,
      'color': Colors.red
    },
    {
      'category': 'Groceries',
      'amount': '-\$300',
      'time': '10-5-2024',
      'icon': Icons.shopping_cart,
      'color': Colors.orange
    },
    {
      'category': 'Utilities',
      'amount': '-\$150',
      'time': '20-5-2024',
      'icon': Icons.lightbulb_outline,
      'color': Colors.yellow
    },
  ];

  double totalExpense = 1650;

  List<charts.Series<int, int>> data = [
    charts.Series<int, int>(
      id: 'Expense',
      colorFn: (_, __) => charts.MaterialPalette.red.shadeDefault,
      domainFn: (int expense, _) => expense,
      measureFn: (int expense, _) => expense,
      data: List.generate(31, (index) => 0),
    ),
  ];

  void _addExpense(
      String category, double amount, String time, IconData icon, Color color) {
    setState(() {
      expenses.add({
        'category': category,
        'amount': '-\$$amount',
        'time': time,
        'icon': icon,
        'color': color,
      });
      totalExpense += amount;
      _updateChartData();
    });
  }

  void _updateChartData() {
    List<int> newData = List.generate(31, (index) => 0);

    for (var expense in expenses) {
      var day = int.tryParse(
          expense['time'].split(' ')[0].replaceAll(RegExp(r'\D'), ''));

      if (day != null && day >= 1 && day <= 31) {
        newData[day - 1] += int.parse(expense['amount'].substring(2));
      }
    }

    setState(() {
      data = [
        charts.Series<int, int>(
          id: 'Expense',
          colorFn: (_, __) => charts.MaterialPalette.red.shadeDefault,
          domainFn: (int expense, _) => expense + 1,
          measureFn: (int expense, _) => newData[expense],
          data: List.generate(31, (index) => index),
        ),
      ];
    });
  }

  void _updateChartDataForMonth(int month) {
    List<int> newData = List.generate(31, (index) => 0);

    for (var expense in expenses) {
      var day = int.tryParse(
          expense['time'].split(' ')[0].replaceAll(RegExp(r'\D'), ''));
      var expenseMonth = int.tryParse(
          expense['time'].split(' ')[1].replaceAll(RegExp(r'\D'), ''));

      if (day != null && day >= 1 && day <= 31 && expenseMonth == month) {
        newData[day - 1] += int.parse(expense['amount'].substring(2));
      }
    }

    setState(() {
      data = [
        charts.Series<int, int>(
          id: 'Expense',
          colorFn: (_, __) => charts.MaterialPalette.red.shadeDefault,
          domainFn: (int expense, _) => expense + 1,
          measureFn: (int expense, _) => newData[expense],
          data: List.generate(31, (index) => index),
        ),
      ];
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
    String category = 'Rent';
    double amount = 0.0;
    String time =
        "${DateTime.now().day}-${DateTime.now().month}-${DateTime.now().year}"; // Set default date to today
    String customCategory = '';
    IconData icon = Icons.home;
    Color color = Colors.red;

    final Map<String, Map<String, dynamic>> categories = {
      'Rent': {'icon': Icons.home, 'color': Colors.red},
      'Groceries': {'icon': Icons.shopping_cart, 'color': Colors.orange},
      'Utilities': {'icon': Icons.lightbulb_outline, 'color': Colors.yellow},
      'Transport': {'icon': Icons.directions_car, 'color': Colors.green},
      'Entertainment': {'icon': Icons.movie, 'color': Colors.purple},
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
                        title: Text('Error'),
                        content:
                            Text('Please fill in all fields with valid data'),
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
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('Expenses', style: TextStyle(color: Colors.black)),
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Card(
                elevation: 4.0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                color: Colors.red,
                child: ListTile(
                  title: Text('Total Expense',
                      style: TextStyle(color: Colors.white)),
                  subtitle: Text(
                    '-\$${totalExpense.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 24.0,
                      color: Colors.white,
                    ),
                  ),
                  leading: Icon(
                    FontAwesomeIcons.moneyBillWave,
                    color: Colors.white,
                    size: 40.0,
                  ),
                ),
              ),
              SizedBox(height: 16.0),
              SizedBox(
                height: 200.0,
                child: charts.LineChart(
                  data,
                  animate: true,
                  defaultRenderer:
                      charts.LineRendererConfig(includePoints: true),
                  primaryMeasureAxis: charts.NumericAxisSpec(
                    tickProviderSpec:
                        charts.BasicNumericTickProviderSpec(zeroBound: false),
                  ),
                  domainAxis: charts.NumericAxisSpec(
                    viewport: charts.NumericExtents(1, 31),
                  ),
                ),
              ),
              SizedBox(height: 16.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back),
                    onPressed: _showPreviousMonth,
                  ),
                  Text(
                    _currentMonth.toString(),
                    style:
                        TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: Icon(Icons.arrow_forward),
                    onPressed: _showNextMonth,
                  ),
                ],
              ),
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: expenses.length,
                itemBuilder: (context, index) {
                  final expense = expenses[index];
                  return Card(
                    elevation: 2.0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: expense['color'],
                        child: Icon(
                          expense['icon'],
                          color: Colors.white,
                        ),
                      ),
                      title: Text(expense['category']),
                      subtitle: Text(expense['time']),
                      trailing: Text(
                        expense['amount'],
                        style: TextStyle(
                          color: expense['color'],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddExpenseDialog,
        child: Icon(Icons.add),
      ),
    );
  }
}
