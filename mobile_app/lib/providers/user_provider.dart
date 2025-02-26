import 'package:capstone_app/main.dart';
import 'package:flutter/material.dart';

class UserProvider extends ChangeNotifier {
  int? _userId;
  String? _selectedProfile;
  List<Map<String, dynamic>> _profiles = []; // Ensure correct type

  int? get userId => _userId;
  String? get selectedProfile => _selectedProfile;
  List<Map<String, dynamic>> get profiles => _profiles;

  void setUserId(int id) {
    _userId = id;
    fetchProfiles(); // Fetch profiles when user logs in
    notifyListeners();
  }

  void setSelectedProfile(String profile) {
    _selectedProfile = profile;
    notifyListeners();
  }

  void clearUser() {
    _userId = null;
    _selectedProfile = null;
    _profiles = [];
    notifyListeners();
  }

  Future<void> fetchProfiles() async {
    if (_userId == null) return;

    try {
      final preferenceResponse = await supabase
          .from('preferences_table')
          .select('*')
          .eq('user_id', _userId as Object);

      final listingResponse = await supabase
          .from('listings_table')
          .select('*')
          .eq('user_id', _userId as Object);

      // Ensure the response is properly extracted
      final List<Map<String, dynamic>> preferences =
          List<Map<String, dynamic>>.from(preferenceResponse);

      final List<Map<String, dynamic>> listings =
          List<Map<String, dynamic>>.from(listingResponse);

      _profiles = [...preferences, ...listings];

      notifyListeners();
    } catch (e) {
      print("Error fetching profiles: $e");
      _profiles = []; // Ensure it doesn't break
      notifyListeners();
    }
  }
}
