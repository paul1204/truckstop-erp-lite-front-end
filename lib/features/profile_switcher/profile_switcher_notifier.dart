import 'package:flutter/material.dart';
import 'package:self_improvement_app/ui/core/style_tokens.dart';

class ProfileNotifier extends ChangeNotifier {
  AppProfile _activeProfile = AppProfile.profileB;
  String _userEmail = 'test@truckstop.com';

  AppProfile get activeProfile => _activeProfile;
  String get userEmail => _userEmail;

  void setProfile(AppProfile profile) {
    if (_activeProfile != profile) {
      _activeProfile = profile;
      notifyListeners();
    }
  }

  void setUserEmail(String email) {
    if (_userEmail != email) {
      _userEmail = email;
      notifyListeners();
    }
  }
}
