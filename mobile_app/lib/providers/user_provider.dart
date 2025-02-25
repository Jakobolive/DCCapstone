import 'package:flutter/material.dart';

class UserProvider extends ChangeNotifier {
  int? _userId; // Nullable int

  int? get userId => _userId; // Getter

  void setUserId(int? id) {
    // Accepts null
    _userId = id;
    notifyListeners();
  }

  void clearUser() {
    _userId = null;
    notifyListeners();
  }
}
