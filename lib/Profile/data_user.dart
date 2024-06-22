import 'package:flutter/material.dart';

// Global Variable
class UserData extends ChangeNotifier {
  String documentId = '';
  String _name = '';
  String _email = '';

  String get documentID => documentId;
  String get name => _name;
  String get email => _email;

  void setDocumentID(String? id) {
    if(id == null){
      print("DocID in notifier empty");
      return;
    }
    documentId = id;
    notifyListeners(); // Notify listeners of state change
    print("Document ID Notifier : $documentId");
  }

    void setName(String name) {
    _name = name;
    notifyListeners();
  }

  void setEmail(String email) {
    _email = email;
    notifyListeners();
  }
}
