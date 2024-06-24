import 'package:flutter/material.dart';

class UserData extends ChangeNotifier {
  String documentId = '';
  String _name = '';
  String _email = '';
  String _bio = '';
  double _totalIncome = 0.0; 
  double _totalExpenses = 0.0;
  
  String get documentID => documentId;
  String get name => _name;
  String get email => _email;
  String get bio => _bio;
  double get totalIncome => _totalIncome;
  double get totalExpenses => _totalExpenses;
  
  List<Map<String, dynamic>> _transactions = [];
  List<Map<String, dynamic>> get transactions => _transactions;

  void setDocumentID(String? id) {
    if (id == null) {
      print("Document ID in notifier is empty");
      return;
    }
    documentId = id;
    notifyListeners(); // Notify listeners of state change
    print("Document ID Notifier: $documentId");
  }

  void setName(String name) {
    _name = name;
    notifyListeners();
  }

  void setBio(String bio) {
    _bio = bio;
    notifyListeners();
  }

  void setEmail(String email) {
    _email = email;
    notifyListeners();
  }

  void addIncome(double amount) {
    _totalIncome += amount;
    notifyListeners();
  }

  void addExpense(double amount) {
    _totalIncome -= amount;
    notifyListeners();
  }

  void addTransaction(Map<String, dynamic> transaction) {
    _transactions.add(transaction);
    notifyListeners();
  }

}
