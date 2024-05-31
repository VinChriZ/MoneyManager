import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:charts_flutter/flutter.dart' as charts;

class IncomePage extends StatefulWidget {
  @override
  _IncomePageState createState() => _IncomePageState();
}

class IncomeData {
  final int day;
  int amount;

  IncomeData(this.day, this.amount);
}

class _IncomePageState extends State<IncomePage> {
  int _currentMonth = DateTime.now().month;

  List<Map<String, dynamic>> incomes = [
    {
      'category': 'Salary',
      'amount': '+\$3000',
      'time': '1-5-2024',
      'icon': Icons.money,
      'color': Colors.blue
    },
    {
      'category': 'Freelance',
      'amount': '+\$1500',
      'time': '15-5-2024',
      'icon': Icons.laptop_mac,
      'color': Colors.green
    },
    {
      'category': 'Investments',
      'amount': '+\$500',
      'time': '20-5-2024',
      'icon': Icons.show_chart,
      'color': Colors.orange
    },
  ];

  double totalIncome = 5000;

  List<charts.Series<int, int>> data = [
    charts.Series<int, int>(
      id: 'Income',
      colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
      domainFn: (int income, _) => income,
      measureFn: (int income, _) => income,
      data: List.generate(31, (index) => 0),
    ),
  ];

  void _addIncome(
      String category, double amount, String time, IconData icon, Color color) {
    setState(() {
      incomes.add({
        'category': category,
        'amount': '+\$$amount',
        'time': time,
        'icon': icon,
        'color': color,
      });
      totalIncome += amount;
      _updateChartData();
    });
  }

  void _updateChartData() {
    // Compute new data for the graph using the updated list of incomes
    List<int> newData = List.generate(31, (index) => 0);

    // Loop through each income entry and update the data accordingly
    for (var income in incomes) {
      // Extract day from the income entry (assuming time is in the format "1st May")
      var day = int.tryParse(
          income['time'].split(' ')[0].replaceAll(RegExp(r'\D'), ''));

      // Increment the data for that day by the amount of income
      if (day != null && day >= 1 && day <= 31) {
        newData[day - 1] += int.parse(income['amount'].substring(2));
      }
    }

    // Update the chart data
    setState(() {
      data = [
        charts.Series<int, int>(
          id: 'Income',
          colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
          domainFn: (int income, _) =>
              income + 1, // Adding 1 to index to match day numbers
          measureFn: (int income, _) => newData[income],
          data: List.generate(
              31, (index) => index), // Generate indices from 0 to 30
        ),
      ];
    });
  }

  void _updateChartDataForMonth(int month) {
    List<int> newData = List.generate(31, (index) => 0);

    for (var income in incomes) {
      var day = int.tryParse(
          income['time'].split(' ')[0].replaceAll(RegExp(r'\D'), ''));
      var incomeMonth = int.tryParse(
          income['time'].split(' ')[1].replaceAll(RegExp(r'\D'), ''));

      if (day != null && day >= 1 && day <= 31 && incomeMonth == month) {
        newData[day - 1] += int.parse(income['amount'].substring(2));
      }
    }

    setState(() {
      data = [
        charts.Series<int, int>(
          id: 'Income',
          colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
          domainFn: (int income, _) => income + 1,
          measureFn: (int income, _) => newData[income],
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

  void _showAddIncomeDialog() {
    String category = 'Salary';
    double amount = 0.0;
    String time =
        "${DateTime.now().day}-${DateTime.now().month}-${DateTime.now().year}"; // Set default date to today
    String customCategory = '';
    IconData icon = Icons.money;
    Color color = Colors.blue;

    final Map<String, Map<String, dynamic>> categories = {
      'Salary': {'icon': Icons.money, 'color': Colors.blue},
      'Freelance': {'icon': Icons.laptop_mac, 'color': Colors.green},
      'Investments': {'icon': Icons.show_chart, 'color': Colors.orange},
      'Gifts': {'icon': Icons.card_giftcard, 'color': Colors.purple},
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
        });
      }
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add Income'),
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
                  _addIncome(category == 'Other' ? customCategory : category,
                      amount, time, icon, color);
                  Navigator.of(context).pop();
                } else {
                  // Show an alert if the form is not complete
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
        title: Text('Income', style: TextStyle(color: Colors.black)),
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Total Income', style: TextStyle(color: Colors.grey)),
              Text('\$$totalIncome',
                  style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold)),
              SizedBox(height: 16.0),
              _buildIncomeSummary(),
              SizedBox(height: 16.0),
              Text('Income Frequency',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 16.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: _showPreviousMonth,
                    child: Text('Previous'),
                  ),
                  SizedBox(width: 16.0),
                  ElevatedButton(
                    onPressed: _showNextMonth,
                    child: Text('Next'),
                  ),
                ],
              ),
              SizedBox(height: 16.0),
              _buildIncomeFrequencyGraph(),
              SizedBox(height: 16.0),
              _buildRecentIncomes(),
              SizedBox(height: 16.0),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddIncomeDialog,
        child: Icon(Icons.add),
        backgroundColor: Colors.green,
      ),
    );
  }

  Widget _buildIncomeSummary() {
    // Group incomes by category
    Map<String, double> categoryAmounts = {};
    incomes.forEach((income) {
      String category = income['category'] as String;
      double amount = double.parse(income['amount']!.substring(2));
      if (categoryAmounts.containsKey(category)) {
        categoryAmounts[category] = categoryAmounts[category]! + amount;
      } else {
        categoryAmounts[category] = amount;
      }
    });

    // Sort categories by amount
    var sortedCategories = categoryAmounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return SizedBox(
      height: 120, // Specify the height of the income summary section
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: sortedCategories.length,
        itemBuilder: (context, index) {
          final category = sortedCategories[index].key;
          final amount = sortedCategories[index].value;
          return SizedBox(
            width: 150, // Specify the width of each income card
            child: _buildSummaryCard(
              category,
              '+\$${amount.toStringAsFixed(0)}', // Format without decimal places
              _getCategoryColor(category),
              _getCategoryIcon(category),
            ),
          );
        },
      ),
    );
  }

  Color _getCategoryColor(String category) {
    // Define colors for each category
    Map<String, Color> categoryColors = {
      'Salary': Colors.blue,
      'Freelance': Colors.green,
      'Investments': Colors.orange,
      'Gifts': Colors.purple,
      'Rent': Colors.brown,
      'Other': Colors.grey,
    };
    // Return color based on category
    return categoryColors[category] ?? Colors.grey;
  }

  IconData _getCategoryIcon(String category) {
    // Define icons for each category
    Map<String, IconData> categoryIcons = {
      'Salary': Icons.money,
      'Freelance': Icons.laptop_mac,
      'Investments': Icons.show_chart,
      'Gifts': Icons.card_giftcard,
      'Rent': Icons.home,
      'Other': Icons.category,
    };
    // Return icon based on category
    return categoryIcons[category] ?? Icons.category;
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

  Widget _buildIncomeFrequencyGraph() {
    List<charts.Series<IncomeData, int>> series = [
      charts.Series<IncomeData, int>(
        id: "Income",
        data: _generateIncomeData(),
        domainFn: (IncomeData income, _) => income.day,
        measureFn: (IncomeData income, _) => income.amount,
        colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
      )
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
        series,
        animate: true,
        defaultRenderer: charts.LineRendererConfig(
          includePoints: true,
        ),
      ),
    );
  }

  List<IncomeData> _generateIncomeData() {
    List<IncomeData> incomeData =
        List.generate(31, (index) => IncomeData(index + 1, 0));

    // Loop through each income entry and update the data accordingly
    for (var income in incomes) {
      // Extract day from the income entry (assuming time is in the format "1st May")
      var day = int.tryParse(
        income['time'].split(' ')[0].replaceAll(RegExp(r'\D'), ''),
      );

      // Increment the data for that day by the amount of income
      if (day != null && day >= 1 && day <= 31) {
        incomeData[day - 1].amount += int.parse(income['amount'].substring(2));
      }
    }

    return incomeData;
  }

  Widget _buildRecentIncomes() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Recent Incomes',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            TextButton(onPressed: () {}, child: Text('See All')),
          ],
        ),
        ...incomes.map((income) {
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: income['color'] as Color,
              child: Icon(income['icon'] as IconData, color: Colors.white),
            ),
            title: Text(income['category'] as String),
            subtitle: Text(income['time'] as String),
            trailing: Text(income['amount'] as String,
                style: TextStyle(color: Colors.green)),
          );
        }).toList(),
      ],
    );
  }
}
