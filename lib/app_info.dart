// app_info.dart
import 'package:flutter/foundation.dart';

class AppInfo extends ChangeNotifier {
  bool _isAvailable = false;
  bool _isWorking = false;

  bool get isAvailable => _isAvailable;
  bool get isWorking => _isWorking;

  void setAvailability(bool value) {
    _isAvailable = value;
    notifyListeners();
  }

  void setWorking(bool value) {
    _isWorking = value;
    notifyListeners();
  }
}
