import 'package:capstone_app/main.dart';
import 'package:flutter/material.dart';

class UserProvider extends ChangeNotifier {
  int? _userId;
  String? _userType; // "Renter" or "Landlord"
  Map<String, dynamic>? _selectedProfile;
  List<Map<String, dynamic>> _renterProfiles = [];
  List<Map<String, dynamic>> _landlordProfiles = [];

  int? get userId => _userId;
  String? get userType => _userType;
  Map<String, dynamic>? get selectedProfile => _selectedProfile;
  List<Map<String, dynamic>> get renterProfiles => _renterProfiles;
  List<Map<String, dynamic>> get landlordProfiles => _landlordProfiles;

  void setUserId(int id) {
    _userId = id;
    fetchProfiles();
    notifyListeners();
  }

  void clearUser() {
    _userId = null;
    _userType = null;
    _selectedProfile = null;
    _renterProfiles = [];
    _landlordProfiles = [];
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

      _renterProfiles = List<Map<String, dynamic>>.from(preferenceResponse);
      _landlordProfiles = List<Map<String, dynamic>>.from(listingResponse);

      // ✅ Automatically select the first available profile (prioritizing Renters)
      if (_renterProfiles.isNotEmpty) {
        setSelectedProfile(_renterProfiles.first, "Renter");
      } else if (_landlordProfiles.isNotEmpty) {
        setSelectedProfile(_landlordProfiles.first, "Landlord");
      } else {
        _selectedProfile = null;
        _userType = null;
      }

      notifyListeners();
    } catch (e) {
      print("Error fetching profiles: $e");
      _renterProfiles = [];
      _landlordProfiles = [];
      _selectedProfile = null;
      _userType = null;
      notifyListeners();
    }
  }

  void setSelectedProfile(Map<String, dynamic> profile, String type) {
    _selectedProfile = profile;
    _userType = type;
    notifyListeners();
  }
}
