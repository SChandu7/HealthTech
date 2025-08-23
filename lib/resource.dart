import 'package:flutter/material.dart';

class resource with ChangeNotifier {
  String PresentWorkingUser = 'defaultUser';
  String PresentWorkingUser2 = 'defaultUser2';

  void setLoginDetails(String user) {
    PresentWorkingUser = user;
    notifyListeners(); // Notify widgets listening to this model
  }

  void setLoginDetails2(String user2) {
    PresentWorkingUser2 = user2;
    notifyListeners(); // Notify widgets listening to this model
  }
}

//Provider.of<resource>(context, listen: false).PresentWorkingUser
