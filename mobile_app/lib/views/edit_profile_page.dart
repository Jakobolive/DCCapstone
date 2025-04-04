import 'dart:async';
import 'dart:convert';
import 'package:capstone_app/main.dart';
import 'package:capstone_app/providers/user_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';

class EditProfilePage extends StatefulWidget {
  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  // Variables.
  final supabase = Supabase.instance.client;
  List<String> citySuggestions = [];
  Timer? _debounce;
  final ImagePicker _picker = ImagePicker();
  String? profilePictureURL;
  File? profilePicture;
  String? listingPictureURL;
  File? listingPicture;
  String? userType;
  int? profileID;
  // Common fields.
  final TextEditingController locationController = TextEditingController();
  final TextEditingController bioController = TextEditingController();
  // Renter-specific fields.
  final TextEditingController nameController = TextEditingController();
  final TextEditingController budgetController = TextEditingController();
  bool petsAllowed = false;
  bool nonSmoking = false;
  bool prefPrivate = false;
  int bedCount = 1;
  int bathCount = 1;
  final TextEditingController amenitiesController = TextEditingController();
  // Landlord-specific fields.
  final TextEditingController addressController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  bool petsAllowedLandlord = false;
  bool smokingAllowed = false;
  bool isPrivate = false;
  final TextEditingController availabilityController = TextEditingController();
  // Image related fields.
  File? listingPictureFile; // For mobile. (Android/iOS)
  Uint8List? listingPictureBytes; // For web.
  File? profilePictureFile; // For mobile. (Android/iOS)
  Uint8List? profilePictureBytes; // For web.
  // Bool to determine picture deletion.
  bool pictureChanged = false;
  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  // Function to check and request permissions
  Future<void> _checkPermissions() async {
    // Request gallery permission
    var status = await Permission.photos.status;
    if (!status.isGranted) {
      await Permission.photos.request();
    }

    // Request camera permission
    var cameraStatus = await Permission.camera.status;
    if (!cameraStatus.isGranted) {
      await Permission.camera.request();
    }
  }

  // Load fields with existing profile data.
  void _loadProfileData() {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final profileData = userProvider.selectedProfile;
    if (profileData != null) {
      setState(() {
        userType = userProvider.userType; // Directly get the user type.
        // Populate common fields.
        locationController.text = profileData['location'] ?? '';
        amenitiesController.text = profileData['amenities'] ?? '';
        // Renter-specific fields.
        if (userType == 'Renter') {
          profilePictureURL = profileData['photo_url'] ?? '';
          nameController.text = profileData['preferred_name']?.toString() ?? '';
          bioController.text = profileData['profile_bio'] ?? '';
          budgetController.text = profileData['max_budget']?.toString() ?? '';
          petsAllowed = profileData['pets_allowed'] ?? false;
          nonSmoking = profileData['smoking_allowed'] ?? false;
          bedCount = profileData['bed_count'] ?? 1;
          bathCount = profileData['bath_count'] ?? 1;
          prefPrivate = profileData['is_pref_private'] ?? false;
          profileID = profileData['preference_id'];
        }
        // Landlord-specific fields.
        else {
          listingPictureURL = profileData['photo_url'] ?? '';
          addressController.text = profileData['street_address'] ?? '';
          bioController.text = profileData['listing_bio'] ?? '';
          priceController.text = profileData['asking_price']?.toString() ?? '';
          petsAllowedLandlord = profileData['pets_allowed'] ?? false;
          smokingAllowed = profileData['smoking_allowed'] ?? false;
          bedCount = profileData['bed_count'] ?? 1;
          bathCount = profileData['bath_count'] ?? 1;
          isPrivate = profileData['is_private'] ?? false;
          availabilityController.text = profileData['availability'] ?? '';
          profileID = profileData['listing_id'];
        }
      });
    }
  }

  // Function to fetch city suggestions from OpenCage API.
  Future<void> fetchCitySuggestions(String query) async {
    if (_debounce?.isActive ?? false) {
      _debounce!.cancel(); // Cancel the previous debounce timer.
    }
    // Only call API if the user has typed more than 2 characters.
    if (query.length > 2) {
      _debounce = Timer(const Duration(milliseconds: 500), () async {
        try {
          final response = await http.get(
            Uri.parse(
                'https://api.opencagedata.com/geocode/v1/json?q=${Uri.encodeComponent(query)}&key=dd0560808eb443058b761a51b7e6ac26&no_annotations=1'),
          );
          if (response.statusCode == 200) {
            // Parse and handle the successful response here.
            final data = jsonDecode(response.body);
            // Extract the results. (city, province/state, country, postal code)
            List<String> suggestions = [];
            for (var result in data['results']) {
              String? city = result['components']['_normalized_city'];
              String? state = result['components']['state'];
              String? country = result['components']['country'];
              // Construct the suggestion string based on available data.
              String suggestion = '';
              if (city != null) suggestion += '$city, ';
              if (state != null) suggestion += '$state, ';
              if (country != null) suggestion += '$country';
              if (suggestion.isNotEmpty) {
                suggestions.add(suggestion);
              }
            }
            // Update the UI with the suggestions.
            setState(() {
              citySuggestions = suggestions;
            });
          } else {
            // Handle error response from the API.
            print('Failed to load city suggestions: ${response.statusCode}');
          }
        } catch (e) {
          print('Error fetching city suggestions: $e');
        }
      });
    } else {
      // Optionally clear previous suggestions if query length is too short.
      print('Please enter more than 2 characters to get city suggestions');
    }
  }

  // Function to get Lat and Long from city API.
  Future<Map<String, double>?> getLatLong(String location) async {
    final url = Uri.parse(
        'https://api.opencagedata.com/geocode/v1/json?q=${Uri.encodeComponent(location)}&key=dd0560808eb443058b761a51b7e6ac26&no_annotations=1');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['status']['code'] == 200 && data['results'].isNotEmpty) {
        final location = data['results'][0]['geometry'];
        return {'latitude': location['lat'], 'longitude': location['lng']};
      }
    }
    return null;
  }

  // Function to pick the image the user selects.
  Future<void> _pickListingPicture() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    print("🚨 pickedFile: $pickedFile");
    if (pickedFile != null) {
      if (kIsWeb) {
        final bytes = await pickedFile.readAsBytes(); // Convert to Uint8List.
        setState(() {
          listingPictureBytes = bytes; // Use Uint8List for web.
          print("🚨 Listing picture bytes: ${bytes.length}");
          listingPictureFile = null; // Ensure File is null on web.
        });
      } else {
        setState(() {
          listingPictureFile = File(pickedFile.path); // Use File for mobile.
          print("🚨 Listing picture file path: ${pickedFile.path}");
          listingPictureBytes = null; // Ensure Uint8List is null on mobile.
        });
      }
    }
    pictureChanged = true;
  }

  // Function to pick the image the user selects.
  Future<void> _pickProfilePicture() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    print("🚨 pickedFile: $pickedFile");
    if (pickedFile != null) {
      if (kIsWeb) {
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          profilePictureBytes = bytes;
          print("🚨 Profile picture bytes: ${bytes.length}");
          profilePictureFile = null;
        });
      } else {
        setState(() {
          profilePictureFile = File(pickedFile.path);
          print("🚨 Profile picture file path: ${pickedFile.path}");
          profilePictureBytes = null;
        });
      }
    }
    pictureChanged = true;
  }

  // Function to upload new image to bucket.
  Future<String?> uploadFile(Uint8List? fileBytes, String fileName,
      String storageBucket, String? oldFileUrl) async {
    if (fileBytes == null) {
      print("❌ Error: No file bytes provided.");
      return null;
    }
    final storage = supabase.storage.from(storageBucket);
    try {
      if (oldFileUrl != null && oldFileUrl.isNotEmpty && pictureChanged) {
        Uri uri = Uri.parse(oldFileUrl);
        List<String> segments = uri.pathSegments;
        // Ensure the URL has the right structure: /storage/v1/object/public/<bucket-name>/<file-path>.
        if (segments.length > 4) {
          String oldBucket =
              segments[4]; // Bucket name is the 4th segment. (index 4)
          String oldFilePath = segments.sublist(5).join(
              '/'); // The file path starts from the 5th segment. (index 4)
          print(
              "🚨 Deleting old file from bucket: $oldBucket, path: $oldFilePath");
          // Use the extracted bucket name.
          final oldStorage = supabase.storage.from(oldBucket);
          final deleteResponse = await oldStorage.remove([oldFilePath]);
          // Check response value from deletion.
          if (deleteResponse.isNotEmpty) {
            print("✅ Old file deleted successfully.");
          } else {
            print(
                "⚠️ No files were deleted. Check if the path is correct. $deleteResponse");
          }
        } else {
          print("⚠️ Invalid URL structure: $oldFileUrl");
        }
      }
      print("🚨 Uploading file: $fileName to $storageBucket");
      // Upload the file to the bucket.
      final response = await storage.uploadBinary(
        'pictures/$fileName', // Path in Supabase Storage.
        fileBytes,
        fileOptions: const FileOptions(contentType: 'image/jpeg'),
      );
      print("✅ Upload successful: $response");
      return storage.getPublicUrl('pictures/$fileName');
    } catch (e) {
      print("❌ Exception occurred during file upload: $e");
      return null;
    }
  }

  // Function to save user input as needed.
  Future<void> _saveProfile() async {
    try {
      final int? userId = context.read<UserProvider>().userId;
      String? profileUrl;
      String? listingUrl;
      // Generate timestamp.
      String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      // Retrieve existing profile photo URL.
      String? existingProfileUrl;
      String? existingListingUrl;
      if (userType == "Renter") {
        final profileData = await supabase
            .from('preferences_table')
            .select('photo_url')
            .eq('preference_id', profileID as Object)
            .maybeSingle();
        existingProfileUrl = profileData?['photo_url'];
      } else if (userType == "Landlord") {
        final listingData = await supabase
            .from('listings_table')
            .select('photo_url')
            .eq('listing_id', profileID as Object)
            .maybeSingle();
        existingListingUrl = listingData?['photo_url'];
      }
      // Converting mobile upload to bytes.
      if (!kIsWeb && listingPictureFile != null) {
        listingPictureBytes = await listingPictureFile!.readAsBytes();
      }
      if (!kIsWeb && profilePictureFile != null) {
        profilePictureBytes = await profilePictureFile!.readAsBytes();
      }
      // Upload new profile picture.
      if (profilePictureBytes != null) {
        String profileFileName = 'profile_${userId}_$timestamp.jpg';
        profileUrl = await uploadFile(profilePictureBytes, profileFileName,
            'profile_images', existingProfileUrl);
        print("✅ Profile picture uploaded successfully: $profileUrl");
      } else {
        print('No new profile picture provided.');
      }
      // Upload new listing picture.
      if (listingPictureBytes != null) {
        String listingFileName = 'listing_${userId}_$timestamp.jpg';
        listingUrl = await uploadFile(listingPictureBytes, listingFileName,
            'listing_images', existingListingUrl);
        print("✅ Listing picture uploaded successfully: $listingUrl");
      } else {
        print('No new listing picture provided.');
      }
      // Fetch Latitude & Longitude.
      String locationInput = locationController.text;
      Map<String, double>? coordinates = await getLatLong(locationInput);
      double latitude = coordinates?['latitude'] ?? 0.0;
      double longitude = coordinates?['longitude'] ?? 0.0;
      print("✅ Retrieved profileId: $profileID");
      // Determine table and update accordingly.
      if (userType == "Renter") {
        // Ensure the profile exists before updating.
        final existingProfile = await supabase
            .from('preferences_table')
            .select('preference_id')
            .eq('preference_id', profileID as Object)
            .maybeSingle();
        if (existingProfile != null) {
          // Update existing profile.
          final updateData = {
            'preferred_name': nameController.text,
            'profile_bio': bioController.text,
            'location': locationController.text,
            'latitude': latitude,
            'longitude': longitude,
            'max_budget': int.tryParse(budgetController.text) ?? 0,
            'pets_allowed': petsAllowed,
            'smoking_allowed': smokingAllowed,
            'bed_count': bedCount,
            'bath_count': bathCount,
            'amenities': amenitiesController.text,
            'is_pref_private': prefPrivate,
          };
          // Conditionally add 'photo_url' only if pictureChanged is true.
          if (pictureChanged && profileUrl != null) {
            updateData['photo_url'] = profileUrl;
          }
          final response = await supabase
              .from('preferences_table')
              .update(updateData)
              .eq('preference_id', profileID as Object)
              .select();
          print("✅ Updated listing: $response");
        } else {
          print("⚠️ No existing profile found for userId: $profileID");
        }
      } else if (userType == "Landlord") {
        // Ensure the listing exists before updating.
        final existingListing = await supabase
            .from('listings_table')
            .select('listing_id')
            .eq('listing_id', profileID as Object)
            .maybeSingle();
        if (existingListing != null) {
          // Update existing listing.
          final updateData = {
            'street_address': addressController.text,
            'location': locationController.text,
            'latitude': latitude,
            'longitude': longitude,
            'asking_price': int.tryParse(priceController.text) ?? 0,
            'bed_count': bedCount,
            'bath_count': bathCount,
            'amenities': amenitiesController.text,
            'pets_allowed': petsAllowed,
            'smoking_allowed': smokingAllowed,
            'availability': availabilityController.text,
            'listing_bio': bioController.text,
            'is_private': isPrivate,
          };
          // Conditionally add 'photo_url' only if pictureChanged is true.
          if (pictureChanged && listingUrl != null) {
            updateData['photo_url'] = listingUrl;
          }
          final response = await supabase
              .from('listings_table')
              .update(updateData)
              .eq('listing_id', profileID as Object)
              .select();
          print("✅ Updated listing: $response");
        } else {
          print("⚠️ No existing listing found for userId: $profileID");
        }
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Profile updated successfully!")),
      );
      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      print("❌ Error updating profile: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Profile update failed: $e")),
      );
    }
  }

  // Common UI.
  @override
  Widget build(BuildContext context) {
    if (userType == null) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: CircularProgressIndicator()), // Loading state
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(
          userType == "Renter"
              ? "Update Renter Profile"
              : "Update Listing Profile",
        ),
        backgroundColor: Colors.teal,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushNamed(context, '/home');
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            if (userType == "Renter") _buildRenterForm(),
            if (userType == "Landlord") _buildLandlordForm(),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _saveProfile();
              },
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.teal,
              ),
              child: Text("Save Changes", style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }

  // Renter Form UI.
  Widget _buildRenterForm() {
    return Column(
      children: [
        GestureDetector(
          onTap: _pickProfilePicture,
          child: _buildProfileImage(
            profilePictureURL: profilePictureURL,
            profilePictureBytes: profilePictureBytes,
            profilePictureFile: profilePictureFile,
          ),
        ),
        _buildTextField("Preferred Name", nameController, Icons.people),
        _buildTextFieldWithSuggestions('Desired City'),
        _buildTextField("Bio", bioController, Icons.person),
        _buildTextField("Budget (\$)", budgetController, Icons.attach_money),
        _buildCounter(
            "Beds", bedCount, (value) => setState(() => bedCount = value)),
        _buildCounter(
            "Baths", bathCount, (value) => setState(() => bathCount = value)),
        CheckboxListTile(
          title: Text("Pets Allowed"),
          value: petsAllowed,
          onChanged: (bool? value) {
            setState(() {
              petsAllowed = value ?? false;
            });
          },
        ),
        CheckboxListTile(
          title: Text("Non-Smoking"),
          value: nonSmoking,
          onChanged: (bool? value) {
            setState(() {
              nonSmoking = value ?? false;
            });
          },
        ),
        _buildTextField("Amenities", amenitiesController, Icons.list),
        CheckboxListTile(
          title: Text("Private Mode"),
          value: prefPrivate,
          onChanged: (bool? value) {
            setState(() {
              prefPrivate = value ?? false;
            });
          },
        ),
      ],
    );
  }

  // Landlord Form UI.
  Widget _buildLandlordForm() {
    return Column(
      children: [
        GestureDetector(
          onTap: _pickListingPicture,
          child: CircleAvatar(
            radius: 60,
            backgroundImage: listingPicture != null
                ? FileImage(listingPicture!)
                : AssetImage("assets/placeholder.jpg") as ImageProvider,
            child: profilePicture == null
                ? Icon(Icons.camera_alt, size: 40, color: Colors.white)
                : null,
          ),
        ),
        _buildTextFieldWithSuggestions('Rental City'),
        _buildTextField("Bio", bioController, Icons.person),
        _buildTextField("Address", addressController, Icons.home),
        _buildTextField("Asking Price (\$)", priceController, Icons.money),
        _buildCounter(
            "Beds", bedCount, (value) => setState(() => bedCount = value)),
        _buildCounter(
            "Baths", bathCount, (value) => setState(() => bathCount = value)),
        CheckboxListTile(
          title: Text("Pets Allowed"),
          value: petsAllowed,
          onChanged: (bool? value) {
            setState(() {
              petsAllowed = value ?? false;
            });
          },
        ),
        CheckboxListTile(
          title: Text("Non-Smoking"),
          value: smokingAllowed,
          onChanged: (bool? value) {
            setState(() {
              smokingAllowed = value ?? false;
            });
          },
        ),
        _buildTextField(
            "Availability", availabilityController, Icons.calendar_today),
        _buildTextField("Amenities", amenitiesController, Icons.list),
        CheckboxListTile(
          title: Text("Private Mode"),
          value: isPrivate,
          onChanged: (bool? value) {
            setState(() {
              isPrivate = value ?? false;
            });
          },
        ),
      ],
    );
  }

  // Function to build TextField.
  Widget _buildTextField(
      String label, TextEditingController controller, IconData icon) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  // Function to build modified TextField with suggestions.
  Widget _buildTextFieldWithSuggestions(String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: locationController,
            decoration: InputDecoration(
              labelText: label,
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              prefixIcon: const Icon(Icons.location_city),
            ),
            onChanged: (value) {
              if (value.isNotEmpty) {
                fetchCitySuggestions(
                    value); // Fetch suggestions when text changes.
              } else {
                setState(() {
                  citySuggestions = []; // Clear suggestions when text is empty.
                });
              }
            },
          ),
          if (citySuggestions.isNotEmpty)
            Container(
              height: 200,
              margin: const EdgeInsets.only(
                  top: 8), // Replacing SizedBox with margin
              child: ListView.builder(
                itemCount: citySuggestions.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(citySuggestions[index]),
                    onTap: () {
                      locationController.text =
                          citySuggestions[index]; // Set selected city.
                      setState(() {
                        citySuggestions =
                            []; // Hide suggestions after selection.
                      });
                    },
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  // Function to build counter.
  Widget _buildCounter(String label, int value, Function(int) onChanged) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text("$label: $value", style: TextStyle(fontSize: 16)),
        Row(
          children: [
            IconButton(
                icon: Icon(Icons.remove),
                onPressed: () => onChanged(value > 0 ? value - 1 : 0)),
            IconButton(
                icon: Icon(Icons.add), onPressed: () => onChanged(value + 1)),
          ],
        ),
      ],
    );
  }

  // Function to build checkbox.
  Widget _buildCheckbox(String label, bool value, Function(bool) onChanged) {
    return CheckboxListTile(
      title: Text(label),
      value: value,
      onChanged: (bool? newValue) => onChanged(newValue ?? false),
    );
  }
}

// Function to build images, if exists.
Widget _buildProfileImage({
  required String? profilePictureURL,
  required Uint8List? profilePictureBytes,
  required File? profilePictureFile,
}) {
  if (kIsWeb) {
    return CircleAvatar(
      radius: 50,
      backgroundImage: profilePictureBytes != null
          ? MemoryImage(profilePictureBytes) // Show selected image.
          : (profilePictureURL != null && profilePictureURL.isNotEmpty
              ? NetworkImage(profilePictureURL) // Show stored image.
              : AssetImage('assets/placeholder.png') as ImageProvider),
    );
  } else {
    return CircleAvatar(
      radius: 50,
      backgroundImage: profilePictureFile != null
          ? FileImage(profilePictureFile) // Show selected image.
          : (profilePictureURL != null && profilePictureURL.isNotEmpty
              ? NetworkImage(profilePictureURL) // Show stored image.
              : AssetImage('assets/placeholder.png') as ImageProvider),
    );
  }
}

// Extension to retrieve error.
extension on List<FileObject> {
  get error => null;
}
