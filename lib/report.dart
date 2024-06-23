import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ReportPage(),
    );
  }
}

class ReportPage extends StatefulWidget {
  @override
  _ReportPageState createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  int _currentMonth = DateTime.now().month;
  int _currentYear = DateTime.now().year;
  String _reportType = 'Monthly';
  List<Map<String, dynamic>> transactions = [];
  List<FlSpot> incomeData = [];
  List<FlSpot> expenseData = [];
  bool isLoading = true;
  String filterType = 'All'; // 'All', 'Income', 'Expense'
  String filterCategory = 'All'; // 'All' or any specific category
  String sortOrder = 'Date'; // 'Date' or 'Amount'
  GlobalKey _chartKey = GlobalKey();
  Set<String> allCategories = {'All'};

  @override
  void initState() {
    super.initState();
    fetchFinancialData();
  }

  Future<void> fetchFinancialData() async {
    await fetchTransactions();
    setState(() {
      isLoading = false;
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
    Set<String> categories = {'All'};

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
      categories.add(data['category']);
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
      categories.add(data['category']);
    });

    fetchedTransactions.sort((a, b) => a['time'].compareTo(b['time']));

    setState(() {
      transactions = fetchedTransactions;
      allCategories = categories;
      _buildChartData();
    });
  }

  void _buildChartData() {
    Map<int, double> incomeTransactions = {};
    Map<int, double> expenseTransactions = {};

    if (_reportType == 'Monthly') {
      for (int day = 1; day <= 31; day++) {
        incomeTransactions[day] = 0;
        expenseTransactions[day] = 0;
      }
    } else if (_reportType == 'Yearly') {
      for (int month = 1; month <= 12; month++) {
        incomeTransactions[month] = 0;
        expenseTransactions[month] = 0;
      }
    }

    for (var transaction in transactions) {
      String date = transaction['time'];
      var dateParts = date.split('-');
      int day = int.parse(dateParts[0]);
      int month = int.parse(dateParts[1]);
      int year = int.parse(dateParts[2]);

      if (_reportType == 'Monthly' &&
          month == _currentMonth &&
          year == _currentYear) {
        if (transaction['type'] == 'income') {
          incomeTransactions[day] =
              (incomeTransactions[day] ?? 0) + transaction['amount'];
        } else if (transaction['type'] == 'expense') {
          expenseTransactions[day] =
              (expenseTransactions[day] ?? 0) + transaction['amount'];
        }
      } else if (_reportType == 'Yearly' && year == _currentYear) {
        if (transaction['type'] == 'income') {
          incomeTransactions[month] =
              (incomeTransactions[month] ?? 0) + transaction['amount'];
        } else if (transaction['type'] == 'expense') {
          expenseTransactions[month] =
              (expenseTransactions[month] ?? 0) + transaction['amount'];
        }
      }
    }

    setState(() {
      if (_reportType == 'Monthly') {
        incomeData = incomeTransactions.entries
            .map((entry) => FlSpot(entry.key.toDouble(), entry.value))
            .toList();

        expenseData = expenseTransactions.entries
            .map((entry) => FlSpot(entry.key.toDouble(), entry.value))
            .toList();
      } else if (_reportType == 'Yearly') {
        incomeData = incomeTransactions.entries
            .map((entry) => FlSpot(entry.key.toDouble(), entry.value))
            .toList();

        expenseData = expenseTransactions.entries
            .map((entry) => FlSpot(entry.key.toDouble(), entry.value))
            .toList();
      }
    });
  }

  List<Map<String, dynamic>> _filterTransactions() {
    List<Map<String, dynamic>> filteredTransactions =
        transactions.where((transaction) {
      String date = transaction['time'];
      var dateParts = date.split('-');
      int month = int.parse(dateParts[1]);
      int year = int.parse(dateParts[2]);

      if (_reportType == 'Monthly') {
        return month == _currentMonth && year == _currentYear;
      } else if (_reportType == 'Yearly') {
        return year == _currentYear;
      }
      return true;
    }).toList();

    if (filterType != 'All') {
      filteredTransactions = filteredTransactions
          .where(
              (transaction) => transaction['type'] == filterType.toLowerCase())
          .toList();
    }

    if (filterCategory != 'All') {
      filteredTransactions = filteredTransactions
          .where((transaction) => transaction['category'] == filterCategory)
          .toList();
    }

    if (sortOrder == 'Date') {
      filteredTransactions.sort((a, b) => a['time'].compareTo(b['time']));
    } else if (sortOrder == 'Amount') {
      filteredTransactions.sort((a, b) => b['amount'].compareTo(a['amount']));
    }

    return filteredTransactions;
  }

  Future<void> _generatePdfReport() async {
    final boundary =
        _chartKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
    final image = await boundary.toImage(pixelRatio: 3.0);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    final pngBytes = byteData!.buffer.asUint8List();

    List<Map<String, dynamic>> filteredTransactions = _filterTransactions();

    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              '$_reportType Report',
              style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
            ),
            pw.Text('Year: $_currentYear'),
            if (_reportType == 'Monthly') pw.Text('Month: $_currentMonth'),
            pw.SizedBox(height: 20),
            pw.Image(pw.MemoryImage(pngBytes)),
            pw.SizedBox(height: 20),
            pw.Text(
              'Transactions:',
              style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
            ),
            pw.Table.fromTextArray(
              context: context,
              data: <List<String>>[
                <String>['Date', 'Type', 'Amount', 'Category'],
                ...filteredTransactions.map(
                  (transaction) => [
                    transaction['time'],
                    transaction['type'] == 'income' ? 'Income' : 'Expense',
                    '\$${transaction['amount']}',
                    transaction['category'],
                  ],
                )
              ],
            ),
          ],
        ),
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  void _showPreviousPeriod() {
    setState(() {
      if (_reportType == 'Monthly') {
        if (_currentMonth > 1) {
          _currentMonth--;
        } else {
          _currentMonth = 12;
          _currentYear--;
        }
      } else if (_reportType == 'Yearly') {
        _currentYear--;
      }
      fetchFinancialData();
    });
  }

  void _showNextPeriod() {
    setState(() {
      if (_reportType == 'Monthly') {
        if (_currentMonth < 12) {
          _currentMonth++;
        } else {
          _currentMonth = 1;
          _currentYear++;
        }
      } else if (_reportType == 'Yearly') {
        _currentYear++;
      }
      fetchFinancialData();
    });
  }

  void _showReportTypeDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Select Report Type'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile(
                title: Text('Monthly'),
                value: 'Monthly',
                groupValue: _reportType,
                onChanged: (value) {
                  setState(() {
                    _reportType = value.toString();
                  });
                  Navigator.of(context).pop();
                  fetchFinancialData();
                },
              ),
              RadioListTile(
                title: Text('Yearly'),
                value: 'Yearly',
                groupValue: _reportType,
                onChanged: (value) {
                  setState(() {
                    _reportType = value.toString();
                  });
                  Navigator.of(context).pop();
                  fetchFinancialData();
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> filteredTransactions = _filterTransactions();

    return Scaffold(
      appBar: AppBar(
        title: Text('Reports'),
        actions: [
          IconButton(
            icon: Icon(Icons.picture_as_pdf),
            onPressed: _generatePdfReport,
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: Icon(Icons.arrow_back),
                        onPressed: _showPreviousPeriod,
                      ),
                      Column(
                        children: [
                          Text(
                            '$_reportType Report',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            _reportType == 'Monthly'
                                ? 'Month: $_currentMonth, Year: $_currentYear'
                                : 'Year: $_currentYear',
                          ),
                        ],
                      ),
                      IconButton(
                        icon: Icon(Icons.arrow_forward),
                        onPressed: _showNextPeriod,
                      ),
                      IconButton(
                        icon: Icon(Icons.calendar_today),
                        onPressed: _showReportTypeDialog,
                      ),
                    ],
                  ),
                ),
                RepaintBoundary(
                  key: _chartKey,
                  child: SizedBox(
                    height: 300, // Set the height of the chart to 300
                    width: 420,
                    child: LineChart(
                      LineChartData(
                        minX: _reportType == 'Monthly' ? 1 : 1,
                        maxX: _reportType == 'Monthly' ? 31 : 12,
                        minY: 0,
                        titlesData: FlTitlesData(
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: false,
                              interval: 100,
                              getTitlesWidget: (value, meta) {
                                return Padding(
                                  padding: const EdgeInsets.only(right: 8.0),
                                  child: Text(value.toString(),
                                      style: TextStyle(
                                          color: Colors.black, fontSize: 10)),
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
                                  child: Text(
                                    _reportType == 'Monthly'
                                        ? value.toInt().toString()
                                        : DateFormat.MMM()
                                            .format(DateTime(0, value.toInt())),
                                    style: TextStyle(
                                        color: Colors.black, fontSize: 10),
                                  ),
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
                          horizontalInterval: 100,
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
                          border: Border.all(
                              color: Colors.grey.withOpacity(0.5), width: 1),
                        ),
                        lineBarsData: [
                          LineChartBarData(
                            spots: incomeData,
                            isCurved: true,
                            color: Colors.green,
                            barWidth: 4,
                            belowBarData: BarAreaData(
                              show: true,
                              color: Colors.green.withOpacity(0.3),
                            ),
                          ),
                          LineChartBarData(
                            spots: expenseData,
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
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Sorting Controls
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        child: ToggleButtons(
                          borderColor: Colors.grey[300],
                          fillColor:
                              Theme.of(context).primaryColor.withOpacity(0.1),
                          borderWidth: 1,
                          selectedBorderColor: Colors.grey[400],
                          borderRadius: BorderRadius.circular(20.0),
                          children: <Widget>[
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16.0),
                              child: Text('Date'),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16.0),
                              child: Text('Amount'),
                            ),
                          ],
                          onPressed: (int index) {
                            setState(() {
                              sortOrder = index == 0 ? 'Date' : 'Amount';
                            });
                          },
                          isSelected: [
                            sortOrder == 'Date',
                            sortOrder == 'Amount',
                          ],
                        ),
                      ),

                      // Filter Type Dropdown
                      Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: filterType,
                            onChanged: (String? newValue) {
                              setState(() {
                                filterType = newValue!;
                              });
                            },
                            items: <String>['All', 'Income', 'Expense']
                                .map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                          ),
                        ),
                      ),

                      // Filter Category Dropdown
                      Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: filterCategory,
                            onChanged: (String? newValue) {
                              setState(() {
                                filterCategory = newValue!;
                              });
                            },
                            items: allCategories
                                .map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: filteredTransactions.length,
                    itemBuilder: (context, index) {
                      final transaction = filteredTransactions[index];
                      bool isIncome = transaction['type'] == 'income';
                      return Card(
                        elevation: 2,
                        margin: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        child: ListTile(
                          leading: CircleAvatar(
                            radius: 25,
                            backgroundColor:
                                isIncome ? Colors.green[100] : Colors.red[100],
                            child: FaIcon(transaction['icon'],
                                color: isIncome ? Colors.green : Colors.red),
                          ),
                          title: Text(
                            '${transaction['category']}',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          subtitle: Text(
                            'Rp ${transaction['amount'].toString()}',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: Colors.black54,
                            ),
                          ),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                transaction['time'],
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                              Text(
                                isIncome ? 'Income' : 'Expense',
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  color: isIncome ? Colors.green : Colors.red,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                )
              ],
            ),
    );
  }
}
