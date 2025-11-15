import 'package:flutter/material.dart';

class LoginProvider with ChangeNotifier {
  Map<String, dynamic>? _user;

  Map<String, dynamic>? get user => _user;

  void setUser(Map<String, dynamic> userData) {
    _user = userData;
    notifyListeners(); // Notify UI to rebuild if needed
  }

  void clearUser() {
    _user = null;
    notifyListeners();
  }
}
