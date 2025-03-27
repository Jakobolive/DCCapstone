import 'dart:math';
import 'package:capstone_app/main.dart';
import 'package:flutter/material.dart';

class UserProvider extends ChangeNotifier {
  // Variables.
  int? _userId;
  String? _userType; // "Renter" or "Landlord."
  Map<String, dynamic>? _selectedProfile;
  int? _profileId;
  List<Map<String, dynamic>> _renterProfiles = [];
  List<Map<String, dynamic>> _landlordProfiles = [];
  List<Map<String, dynamic>> _profiles =
      []; // Store fetched listings or preferences.
  int? get userId => _userId;
  String? get userType => _userType;
  Map<String, dynamic>? get selectedProfile => _selectedProfile;
  List<Map<String, dynamic>> get renterProfiles => _renterProfiles;
  List<Map<String, dynamic>> get landlordProfiles => _landlordProfiles;
  List<Map<String, dynamic>> get profiles =>
      _profiles; // Expose listings or preferences.
  int _currentProfileIndex = 0; // Index to track the current profile.
  Map<String, List<Map<String, String>>> chatMessages =
      {}; // Stores messages per chat.
  // Set userId and reset profile algorithm.
  void setUserId(int id) {
    _userId = id;
    fetchProfiles();
    notifyListeners();
  }

  // Reset user variables and empty collections.
  void clearUser() {
    _userId = null;
    _userType = null;
    _selectedProfile = null;
    _renterProfiles = [];
    _landlordProfiles = [];
    _profiles = []; // Clear listings or preferences
    notifyListeners();
  }

  // Fetch profiles based on user type.
  Future<void> fetchProfiles() async {
    if (_userId == null) return;
    try {
      // Fetch profiles for Renters and Landlords.
      final preferenceResponse = await supabase
          .from('preferences_table')
          .select('*')
          .eq('user_id', _userId as Object);
      final listingResponse = await supabase
          .from('listings_table')
          .select('*')
          .eq('user_id', _userId as Object);
      // Store fetched profiles.
      _renterProfiles = List<Map<String, dynamic>>.from(preferenceResponse);
      _landlordProfiles = List<Map<String, dynamic>>.from(listingResponse);
      // Preserve the current profile if possible.
      Map<String, dynamic>? existingProfile;
      // Check if the current user/profile exists.
      if (_selectedProfile != null) {
        final profilesToSearch =
            _userType == "Renter" ? _renterProfiles : _landlordProfiles;
        // Check for Renter.
        if (_userType == "Renter") {
          existingProfile = profilesToSearch.firstWhere(
            (profile) =>
                profile['preference_id'] == _selectedProfile?['preference_id'],
            orElse: () => <String,
                dynamic>{}, // Return an empty map if no match is found.
          );
          // Check for Landlord.
        } else if (_userType == "Landlord") {
          existingProfile = profilesToSearch.firstWhere(
            (profile) =>
                profile['listing_id'] == _selectedProfile?['listing_id'],
            orElse: () => <String,
                dynamic>{}, // Return an empty map if no match is found.
          );
        }
      }
      // Set the current profile if it exists.
      if (existingProfile != null && existingProfile.isNotEmpty) {
        setSelectedProfile(existingProfile, _userType!);
      } else {
        // If no existing profile is found, select the first available one, prioritize renters.
        if (_renterProfiles.isNotEmpty) {
          setSelectedProfile(_renterProfiles.first, "Renter");
        } else if (_landlordProfiles.isNotEmpty) {
          setSelectedProfile(_landlordProfiles.first, "Landlord");
        } else {
          _selectedProfile = null;
          _userType = null;
        }
      }
      // Fetch listings or preferences based on user type.
      fetchListingsOrPreferences();
      notifyListeners();
      // Handle errors.
    } catch (e) {
      print("Error fetching profiles: $e");
      _renterProfiles = [];
      _landlordProfiles = [];
      _selectedProfile = null;
      _userType = null;
      notifyListeners();
    }
  }

  // Function to handle/calculate distance.
  double haversineDistance(double lat1, double lon1, double lat2, double lon2) {
    const radius = 6371; // Radius of Earth in kilometers.
    final dLat = _degToRad(lat2 - lat1);
    final dLon = _degToRad(lon2 - lon1);
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_degToRad(lat1)) *
            cos(_degToRad(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return radius * c; // Distance in kilometers.
  }

  // Function to convert degrees to radians.
  double _degToRad(double deg) {
    return deg * (pi / 180);
  }

  // Function to fetch listings or preferences based on user type.
  void fetchListingsOrPreferences() async {
    print("User ID before query: $_userId");
    // Check if the userId exists.
    if (_userId == null) {
      print("User ID is null");
      return; // Handle the null case or exit early.
    }
    // Step 1: Fetch the current user's latitude & longitude from their profile.
    double? userLat = _selectedProfile?['latitude'];
    double? userLng = _selectedProfile?['longitude'];
    // Check if variables are null.
    if (userLat == null || userLng == null) {
      print("User latitude/longitude is not available.");
      return;
    }
    // Step 2: Fetch profiles based on the user type. (Renter or Landlord)
    List<Map<String, dynamic>> allProfiles = [];
    if (_userType == "Renter") {
      final renterListings = await supabase
          .from('listings_table')
          .select('*')
          .neq('user_id', _userId!)
          .eq('is_private', false);
      allProfiles = List<Map<String, dynamic>>.from(renterListings);
    } else if (_userType == "Landlord") {
      final landlordPreferences = await supabase
          .from('preferences_table')
          .select('*')
          .neq('user_id', _userId!)
          .eq('is_pref_private', false);
      allProfiles = List<Map<String, dynamic>>.from(landlordPreferences);
    }
    // Step 3: Compute distances for each profile.
    List<Map<String, dynamic>> profilesWithDistance = [];
    for (var profile in allProfiles) {
      double? profileLat = profile['latitude'];
      double? profileLng = profile['longitude'];

      if (profileLat != null && profileLng != null) {
        double distance =
            haversineDistance(userLat, userLng, profileLat, profileLng);
        profile['distance'] = distance;
        profilesWithDistance.add(profile);
      }
    }
    // Step 4: Sort the profiles by distance. (ascending)
    profilesWithDistance.sort(
        (a, b) => (a['distance'] as double).compareTo(b['distance'] as double));
    // Step 5: Fetch matches related to the selected profile.
    List<Map<String, dynamic>> matchedProfiles = [];
    if (_selectedProfile != null) {
      int? currentProfileId = (_userType == 'Renter')
          ? _selectedProfile!['preference_id'] as int?
          : _selectedProfile!['listing_id'] as int?;
      final matches = await supabase
          .from('match_table')
          .select('preference_id, listing_id, match_status')
          .or('preference_id.eq.$currentProfileId,listing_id.eq.$currentProfileId');
      // Step 6: Separate matched profiles into pending and accepted.
      Set<int> pendingMatchIds = {};
      Set<int> matchedIds = {};
      for (var match in matches) {
        int profileId = (_userType == 'Renter')
            ? match['listing_id'] as int
            : match['preference_id'] as int;
        // Check if the match is pending depending on userType.
        String pendingStatus =
            (_userType == 'Renter') ? 'pendingLandlord' : 'pendingTenant';
        if (match['match_status'] == pendingStatus) {
          pendingMatchIds.add(profileId);
        } else {
          matchedIds.add(profileId);
        }
      }
      // Step 7: Filter profiles into pending, unmatched, and matched categories.
      List<Map<String, dynamic>> pendingProfiles = [];
      List<Map<String, dynamic>> unmatchedProfiles = [];
      // Iterate through profiles.
      for (var profile in profilesWithDistance) {
        int profileId = (_userType == 'Renter')
            ? profile['listing_id'] as int
            : profile['preference_id'] as int;
        if (pendingMatchIds.contains(profileId)) {
          pendingProfiles.add(profile);
        } else if (!matchedIds.contains(profileId)) {
          unmatchedProfiles.add(profile);
        }
      }
      // Prioritize pending profiles.
      matchedProfiles = [...pendingProfiles, ...unmatchedProfiles];
    } else {
      matchedProfiles =
          profilesWithDistance; // No filtering if no selected profile.
    }
    // Step 8: Compute compatibility scores for all profiles before sorting.
    for (var profile in matchedProfiles) {
      double compatibilityScore = 0.0;
      // Check if selected profile exists, then compare profiles.
      if (_selectedProfile != null) {
        if (profile['bed_count'] == _selectedProfile!['bed_count']) {
          compatibilityScore += 1;
        }
        if (_userType == 'Renter' &&
            profile['asking_price'] <= _selectedProfile!['max_budget']) {
          compatibilityScore += 1;
        }
        if (_userType == 'Landlord' &&
            profile['max_budget'] >= _selectedProfile!['asking_price']) {
          compatibilityScore += 1;
        }
        if (profile['bath_count'] == _selectedProfile!['bath_count']) {
          compatibilityScore += 1;
        }
        if (profile['pets_allowed'] == _selectedProfile!['pets_allowed']) {
          compatibilityScore += 1;
        }
        if (profile['smoking_allowed'] ==
            _selectedProfile!['smoking_allowed']) {
          compatibilityScore += 1;
        }
      }
      profile['compatibilityScore'] = compatibilityScore;
    }
// Step 9: Sort profiles based on compatibilityScore (descending) and distance. (ascending)
    matchedProfiles.sort((a, b) {
      int scoreComparison = (b['compatibilityScore'] as double)
          .compareTo(a['compatibilityScore'] as double);
      if (scoreComparison != 0)
        return scoreComparison; // Prioritize higher compatibility score.
      return (a['distance'] as double)
          .compareTo(b['distance'] as double); // Then sort by distance.
    });
    // Step 10: Update the profiles list.
    _profiles = matchedProfiles;
    _currentProfileIndex = 0; // Reset the index if we have profiles to display.
    print("Profiles fetched: $_profiles");
    notifyListeners();
  }

  void setSelectedProfile(Map<String, dynamic> profile, String type) {
    _selectedProfile = profile;
    _userType = type;
    _profileId =
        profile['listing_id'] as int? ?? profile['preference_id'] as int?;
    _currentProfileIndex = 0;
    fetchListingsOrPreferences(); // Fetch listings or preferences after selecting a profile.
    notifyListeners();
  }

  // Method to like a profile.
  Future<void> likeProfile(Map<String, dynamic> likedProfile) async {
    if (selectedProfile == null || likedProfile.isEmpty) return;
    // Use `as int?` and provide a default value to prevent null issues.
    int? currentUserId = (userType == 'Renter')
        ? selectedProfile!['preference_id'] as int?
        : selectedProfile!['listing_id'] as int?;
    int? likedUserId = (userType == 'Renter')
        ? likedProfile['listing_id'] as int?
        : likedProfile['preference_id'] as int?;
    // Try to call Supabase.
    try {
      final response = await supabase
          .from('match_table')
          .select()
          .eq('preference_id', likedUserId as Object)
          .eq('listing_id', currentUserId as Object)
          .maybeSingle();
      if (response != null) {
        // Match exists, update to "Accepted."
        await supabase
            .from('match_table')
            .update({'status': 'accepted'}).match({
          'preference_id': likedUserId as Object,
          'listing_id': currentUserId as Object,
        });
      } else {
        // Creating a match status depending on userType.
        String matchStatus =
            userType == "Renter" ? "pendingTenant" : "pendingLandlord";
        // Insert new "Pending" match
        await supabase.from('match_table').insert({
          'preference_id': currentUserId,
          'listing_id': likedUserId,
          'match_notes': '',
          'match_status': matchStatus,
        });
      }
      notifyListeners();
    } catch (error) {
      print('Error liking profile: $error');
    }
  }

  // Method to dislike a profile.
  Future<void> dislikeProfile(Map<String, dynamic> dislikedProfile) async {
    if (selectedProfile == null || dislikedProfile.isEmpty) return;
    // Get profileId based on profile type.
    int? currentUserId = (userType == 'Renter')
        ? selectedProfile!['preference_id'] as int?
        : selectedProfile!['listing_id'] as int?;
    int? dislikedUserId = (userType == 'Renter')
        ? dislikedProfile['listing_id'] as int?
        : dislikedProfile['preference_id'] as int?;
    // Insert declined match.
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

  // Method to fetch contacts.(matches)
  Future<List<Map<String, String>>> fetchContacts() async {
    if (_userId == null || _userType == null) return [];
    try {
      int? currentProfileId = (_userType == 'Renter')
          ? _selectedProfile!['preference_id'] as int?
          : _selectedProfile!['listing_id'] as int?;
      // Fetching matches based on profileId.
      final matchedProfiles = await supabase
          .from('match_table')
          .select('preference_id, listing_id')
          .or('preference_id.eq.$currentProfileId,listing_id.eq.$currentProfileId')
          .eq('match_status', 'accepted');
      List<Map<String, String>> contacts = [];
      // Iterate through matches.
      for (var match in matchedProfiles) {
        int matchedProfileId = _userType == 'Renter'
            ? match['listing_id'] as int
            : match['preference_id'] as int;
        // Fetching user details based on matched profileId.
        final contactData = await supabase
            .from(
                _userType == 'Renter' ? 'listings_table' : 'preferences_table')
            .select('*')
            .eq(_userType == 'Renter' ? 'listing_id' : 'preference_id',
                matchedProfileId)
            .single();
        // Grab last message between matches, if it exists.
        final lastMessageData = await supabase
            .from('messages_table')
            .select('message')
            .or('sender_renter_id.eq.$_profileId,sender_landlord_id.eq.$_profileId,'
                'receiver_renter_id.eq.$_profileId,receiver_landlord_id.eq.$_profileId')
            .or('sender_renter_id.eq.$matchedProfileId,sender_landlord_id.eq.$matchedProfileId,'
                'receiver_renter_id.eq.$matchedProfileId,receiver_landlord_id.eq.$matchedProfileId')
            .order('created_at', ascending: false)
            .limit(1)
            .maybeSingle();
        String lastMessage = lastMessageData != null
            ? lastMessageData['message'] as String
            : "No messages yet"; // Fallback if no message is found.
        if (lastMessageData == null) {
          print("No message found between $_userId and $matchedProfileId");
        } else {
          print("Last message: ${lastMessageData['message']}");
        }
        // Add contact to the list to display.
        contacts.add({
          'name': _userType == 'Renter'
              ? contactData['street_address']
              : contactData['preferred_name'],
          'picture': contactData['photo_url'],
          'lastMessage': lastMessage,
          'matchedProfileId': matchedProfileId.toString(),
        });
      }
      return contacts;
    } catch (e) {
      print("Error fetching contacts: $e");
      return [];
    }
  }

  // Fetch all messages for a matched contact.
  Future<void> fetchMessages(int matchedProfileId) async {
    if (_profileId == null) return;
    try {
      final messages = await supabase
          .from('messages_table')
          .select('message, sender_renter_id, sender_landlord_id, created_at')
          .or('sender_renter_id.eq.$_profileId,sender_landlord_id.eq.$_profileId,'
              'receiver_renter_id.eq.$_profileId,receiver_landlord_id.eq.$_profileId')
          .or('sender_renter_id.eq.$matchedProfileId,sender_landlord_id.eq.$matchedProfileId,'
              'receiver_renter_id.eq.$matchedProfileId,receiver_landlord_id.eq.$matchedProfileId')
          .order('created_at', ascending: true);
      // Format messages to be displayed.
      List<Map<String, String>> formattedMessages = messages.map((msg) {
        bool isMe = msg['sender_renter_id'] == _profileId ||
            msg['sender_landlord_id'] == _profileId;
        return {
          "from": isMe ? "me" : "them",
          "message": msg['message'] as String,
        };
      }).toList();
      chatMessages[matchedProfileId.toString()] = formattedMessages;
      notifyListeners();
    } catch (e) {
      print("Error fetching messages: $e");
    }
  }

  // Send a message and store it in Supabase.
  Future<void> sendMessage(int matchedProfileId, String message) async {
    if (_profileId == null) return;
    try {
      await supabase.from('messages_table').insert({
        'sender_renter_id': userType == "Renter" ? _profileId : null,
        'sender_landlord_id': userType == "Landlord" ? _profileId : null,
        'receiver_renter_id': userType == "Renter" ? null : matchedProfileId,
        'receiver_landlord_id':
            userType == "Landlord" ? null : matchedProfileId,
        'message': message,
        'created_at': DateTime.now().toIso8601String(),
      });
      chatMessages[matchedProfileId.toString()] ??= [];
      chatMessages[matchedProfileId.toString()]!
          .add({"from": "me", "message": message});
      notifyListeners();
    } catch (e) {
      print("Error sending message: $e");
    }
  }

  // Get stored messages for a contact.
  List<Map<String, String>> getMessages(int matchedProfileId) {
    return chatMessages[matchedProfileId.toString()] ?? [];
  }
}
