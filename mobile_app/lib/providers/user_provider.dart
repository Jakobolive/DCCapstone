import 'package:capstone_app/main.dart';
import 'package:flutter/material.dart';

class UserProvider extends ChangeNotifier {
  int? _userId;
  String? _userType; // "Renter" or "Landlord"
  Map<String, dynamic>? _selectedProfile;
  List<Map<String, dynamic>> _renterProfiles = [];
  List<Map<String, dynamic>> _landlordProfiles = [];
  List<Map<String, dynamic>> _profiles =
      []; // Store fetched listings or preferences

  int? get userId => _userId;
  String? get userType => _userType;
  Map<String, dynamic>? get selectedProfile => _selectedProfile;
  List<Map<String, dynamic>> get renterProfiles => _renterProfiles;
  List<Map<String, dynamic>> get landlordProfiles => _landlordProfiles;
  List<Map<String, dynamic>> get profiles =>
      _profiles; // Expose listings or preferences

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
    _profiles = []; // Clear listings or preferences
    notifyListeners();
  }

  Future<void> fetchProfiles() async {
    if (_userId == null) return;

    try {
      // Fetch profiles for Renters and Landlords
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

      // Preserve the current profile if possible
      Map<String, dynamic>? existingProfile;
      if (_selectedProfile != null) {
        final profilesToSearch =
            _userType == "Renter" ? _renterProfiles : _landlordProfiles;

        if (_userType == "Renter") {
          existingProfile = profilesToSearch.firstWhere(
            (profile) =>
                profile['preference_id'] == _selectedProfile?['preference_id'],
            orElse: () =>
                <String, dynamic>{}, // Return an empty map if no match is found
          );
        } else if (_userType == "Landlord") {
          existingProfile = profilesToSearch.firstWhere(
            (profile) =>
                profile['listing_id'] == _selectedProfile?['listing_id'],
            orElse: () =>
                <String, dynamic>{}, // Return an empty map if no match is found
          );
        }
      }

      if (existingProfile != null && existingProfile.isNotEmpty) {
        setSelectedProfile(existingProfile, _userType!);
      } else {
        // If no existing profile is found, select the first available one
        if (_renterProfiles.isNotEmpty) {
          setSelectedProfile(_renterProfiles.first, "Renter");
        } else if (_landlordProfiles.isNotEmpty) {
          setSelectedProfile(_landlordProfiles.first, "Landlord");
        } else {
          _selectedProfile = null;
          _userType = null;
        }
      }

      // Fetch listings or preferences based on user type
      fetchListingsOrPreferences();

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

  void fetchListingsOrPreferences() async {
    print("User ID before query: $_userId");

    if (_userId == null) {
      print("User ID is null");
      return; // Handle the null case or exit early
    }

    if (_userType == "Renter") {
      final renterListings = await supabase
          .from('listings_table')
          .select('*')
          .neq('user_id', _userId!);

      _profiles = List<Map<String, dynamic>>.from(renterListings);
    } else if (_userType == "Landlord") {
      final landlordPreferences = await supabase
          .from('preferences_table')
          .select('*')
          .neq('user_id', _userId!);

      _profiles = List<Map<String, dynamic>>.from(landlordPreferences);
    }

    print("Profiles fetched: $_profiles");
    notifyListeners();
  }

  void setSelectedProfile(Map<String, dynamic> profile, String type) {
    _selectedProfile = profile;
    _userType = type;
    fetchListingsOrPreferences(); // Fetch listings or preferences after selecting a profile
    notifyListeners();
  }
}
