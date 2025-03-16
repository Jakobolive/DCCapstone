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
  int _currentProfileIndex = 0; // Index to track the current profile

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

    List<Map<String, dynamic>> allProfiles = [];

    if (_userType == "Renter") {
      final renterListings = await supabase
          .from('listings_table')
          .select('*')
          .neq('user_id', _userId!);

      allProfiles = List<Map<String, dynamic>>.from(renterListings);
    } else if (_userType == "Landlord") {
      final landlordPreferences = await supabase
          .from('preferences_table')
          .select('*')
          .neq('user_id', _userId!);

      allProfiles = List<Map<String, dynamic>>.from(landlordPreferences);
    }

    // Fetch matches related to the selected profile
    if (_selectedProfile != null) {
      int? currentProfileId = (_userType == 'Renter')
          ? _selectedProfile!['preference_id'] as int?
          : _selectedProfile!['listing_id'] as int?;

      final matchedProfiles = await supabase
          .from('match_table')
          .select('preference_id, listing_id')
          .or('preference_id.eq.$currentProfileId,listing_id.eq.$currentProfileId');

      // Create a set of matched profile IDs to filter out
      Set<int> matchedIds = matchedProfiles
          .map<int>((match) => _userType == 'Renter'
              ? match['listing_id'] as int
              : match['preference_id'] as int)
          .toSet();

      // Filter out profiles that are already matched
      _profiles = allProfiles.where((profile) {
        int profileId = (_userType == 'Renter')
            ? profile['listing_id'] as int
            : profile['preference_id'] as int;
        return !matchedIds.contains(profileId);
      }).toList();
    } else {
      _profiles = allProfiles; // No filtering if no selected profile
    }

    // Reset the index if we have profiles to display
    _currentProfileIndex = 0;

    print("Profiles fetched: $_profiles");
    notifyListeners();
  }

  void setSelectedProfile(Map<String, dynamic> profile, String type) {
    _selectedProfile = profile;
    _userType = type;
    _currentProfileIndex = 0;
    fetchListingsOrPreferences(); // Fetch listings or preferences after selecting a profile
    notifyListeners();
  }

  // Method to like a profile
  Future<void> likeProfile(Map<String, dynamic> likedProfile) async {
    if (selectedProfile == null || likedProfile.isEmpty) return;

    // Use `as int?` and provide a default value to prevent null issues
    int? currentUserId = (userType == 'Renter')
        ? selectedProfile!['preference_id'] as int?
        : selectedProfile!['listing_id'] as int?;

    int? likedUserId = (userType == 'Renter')
        ? likedProfile['listing_id'] as int?
        : likedProfile['preference_id'] as int?;

    try {
      final response = await supabase
          .from('match_table')
          .select()
          .eq('preference_id', likedUserId as Object)
          .eq('listing_id', currentUserId as Object)
          .maybeSingle();

      if (response != null) {
        // Match exists, update to "Accepted"
        await supabase
            .from('match_table')
            .update({'status': 'accepted'}).match({
          'preference_id': likedUserId as Object,
          'listing_id': currentUserId as Object,
        });
      } else {
        // Insert new "Pending" match
        await supabase.from('match_table').insert({
          'preference_id': currentUserId,
          'listing_id': likedUserId,
          'match_notes': '',
          'match_status': 'pending',
        });
      }
      notifyListeners();
    } catch (error) {
      print('Error liking profile: $error');
    }
  }

  // Method to dislike a profile
  Future<void> dislikeProfile(Map<String, dynamic> dislikedProfile) async {
    if (selectedProfile == null || dislikedProfile.isEmpty) return;

    int? currentUserId = (userType == 'Renter')
        ? selectedProfile!['preference_id'] as int?
        : selectedProfile!['listing_id'] as int?;

    int? dislikedUserId = (userType == 'Renter')
        ? dislikedProfile['listing_id'] as int?
        : dislikedProfile['preference_id'] as int?;

    try {
      await supabase.from('match_table').insert({
        'preference_id': currentUserId,
        'listing_id': dislikedUserId,
        'match_notes': '',
        'match_status': 'declined',
      });
      notifyListeners();
    } catch (error) {
      print('Error disliking profile: $error');
    }
  }
}
