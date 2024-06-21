import 'package:flutter/material.dart';

// Global Variable
class UserData extends ChangeNotifier {
  static String documentId = '';

  void setDocumentID(String? id) {
    if(id == null){
      print("DocID in notifier empty");
      return;
    }
    documentId = id;
    notifyListeners(); // Notify listeners of state change
    print("Document ID Notifier : $documentId");
  }
}