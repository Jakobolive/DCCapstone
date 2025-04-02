import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:capstone_app/providers/user_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';

class BuildProfilePage extends StatefulWidget {
  @override
  _BuildProfilePageState createState() => _BuildProfilePageState();
}

class _BuildProfilePageState extends State<BuildProfilePage> {
  final supabase = Supabase.instance.client;
  List<String> citySuggestions = [];
  Timer? _debounce;
  String? userType =
      "Renter"; // Determines if the user is a renter or landlord, auto set to Renter.
  final ImagePicker _picker = ImagePicker();
  File? pickedFile;
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
  File? profilePicture;
  // Landlord-specific fields.
  final TextEditingController addressController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  bool smokingAllowed = false;
  bool isPrivate = false;
  final TextEditingController availabilityController = TextEditingController();
  File? listingPicture;
  // Image related fields.
  File? listingPictureFile; // For mobile. (Android/iOS)
  Uint8List? listingPictureBytes; // For web.
  File? profilePictureFile; // For mobile. (Android/iOS)
  Uint8List? profilePictureBytes; // For web.
  @override
  void initState() {
    super.initState();
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
            // Extract the results. (city, province/state, country)
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

  // Calling API to determine the city suggestions based on the user's input.
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

  // Function to set listing pictures to be uploaded.
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
  }

  // Function to set profile pictures to be uploaded.
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
  }

  // Function to upload image files to bucket.
  Future<String?> uploadFile(
      Uint8List? fileBytes, String fileName, String storageBucket) async {
    if (fileBytes == null) {
      print("❌ Error: No file bytes provided.");
      return null;
    }
    final storage = supabase.storage.from(storageBucket);
    try {
      print("🚨 Uploading file: $fileName to $storageBucket");
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

  // Function to save user input depending on userType selected.
  Future<void> _saveProfile() async {
    try {
      final int? userId = context.read<UserProvider>().userId;
      String? profileUrl;
      String? listingUrl;
      // Generate timestamp.
      String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      // Converting mobile uploads to bytes.
      if (!kIsWeb && listingPictureFile != null) {
        listingPictureBytes = await listingPictureFile!.readAsBytes();
      }
      if (!kIsWeb && profilePictureFile != null) {
        profilePictureBytes = await profilePictureFile!.readAsBytes();
      }
      // Upload new profile picture.
      if (profilePictureBytes != null) {
        String profileFileName = 'profile_${userId}_$timestamp.jpg';
        profileUrl = await uploadFile(
            profilePictureBytes, profileFileName, 'profile_images');
        print("✅ Profile picture uploaded successfully: $profileUrl");
      } else {
        print('No new profile picture provided.');
      }
      // Upload new listing picture.
      if (listingPictureBytes != null) {
        String listingFileName = 'listing_${userId}_$timestamp.jpg';
        listingUrl = await uploadFile(
            listingPictureBytes, listingFileName, 'listing_images');
        print("✅ Listing picture uploaded successfully: $listingUrl");
      } else {
        print('No new listing picture provided.');
      }
      // Fetch Latitude & Longitude.
      String locationInput = locationController.text;
      Map<String, double>? coordinates = await getLatLong(locationInput);
      double latitude = coordinates?['latitude'] ?? 0.0;
      double longitude = coordinates?['longitude'] ?? 0.0;
      // Determine the table depending on user type and insert data.
      if (userType == "Renter") {
        final response = await supabase.from('preferences_table').insert({
          'user_id': userId,
          'preferred_name':
              nameController.text.isNotEmpty ? nameController.text : "NA",
          'profile_bio':
              bioController.text.isNotEmpty ? bioController.text : "NA",
          'photo_url': profileUrl ?? "", // Fallback to empty string if null.
          'location': locationController.text.isNotEmpty
              ? locationController.text
              : "Unknown",
          'latitude': latitude,
          'longitude': longitude,
          'max_budget': int.tryParse(budgetController.text) ??
              0, // Default to 0 if not parsable.
          'pets_allowed': petsAllowed ?? false, // Use default value if null.
          'smoking_allowed': nonSmoking ?? false, // Use default value if null.
          'bed_count': bedCount ?? 0, // Default to 0 if null.
          'bath_count': bathCount ?? 0, // Default to 0 if null.
          'amenities': amenitiesController.text.isNotEmpty
              ? amenitiesController.text
              : "",
          'is_pref_private': prefPrivate ?? false, // Default to false if null.
        }).select();
        print(response);
      } else if (userType == "Landlord") {
        final response = await supabase.from('listings_table').insert({
          'user_id': userId,
          'photo_url': listingUrl ?? "", // Fallback to empty string if null.
          'street_address': addressController.text.isNotEmpty
              ? addressController.text
              : "Unknown",
          'location': locationController.text.isNotEmpty
              ? locationController.text
              : "Unknown",
          'latitude': latitude,
          'longitude': longitude,
          'asking_price': int.tryParse(priceController.text) ??
              0, // Default to 0 if not parsable.
          'bed_count': bedCount ?? 0, // Default to 0 if null.
          'bath_count': bathCount ?? 0, // Default to 0 if null.
          'amenities': amenitiesController.text.isNotEmpty
              ? amenitiesController.text
              : "",
          'pets_allowed': petsAllowed ?? false, // Default to false if null.
          'smoking_allowed':
              smokingAllowed ?? false, // Default to false if null.
          'availability': availabilityController.text.isNotEmpty
              ? availabilityController.text
              : "NA",
          'listing_bio':
              bioController.text.isNotEmpty ? bioController.text : "NA",
          'is_private': isPrivate ?? false, // Default to false if null.
        }).select();
        print(response);
      }
      // Show success message and navigate.
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Profile saved successfully!")));
      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Account Build Failed: $e")));
      print("❌ Error: $e");
    }
  }

  // Add the userType selector to the UI.
  Widget _buildUserTypeSelector() {
    return Center(
      child: Container(
        width: 250, // Set a specific width to make it smaller
        padding: EdgeInsets.symmetric(vertical: 8), // Added vertical padding
        margin: EdgeInsets.only(bottom: 16), // Add some space at the bottom
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8), // Rounded corners
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 5,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: DropdownButton<String>(
          value: userType,
          hint: Padding(
            padding: const EdgeInsets.only(
                left: 12.0), // Adds some padding for alignment
            child: Text(
              'Select User Type',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ),
          isDense: true, // Reduce the padding inside the dropdown
          isExpanded: true,
          onChanged: (String? newValue) {
            setState(() {
              userType = newValue;
            });
          },
          items: <String>['Renter', 'Landlord']
              .map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Padding(
                padding: const EdgeInsets.only(
                    left: 12.0), // Same padding as hint for consistency
                child: Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            );
          }).toList(),
          underline: SizedBox(), // Hides the default underline
          icon: Padding(
            padding: const EdgeInsets.only(
                right: 12.0), // Match padding for icon alignment
            child: Icon(Icons.arrow_drop_down, color: Colors.teal),
          ),
        ),
      ),
    );
  }

  // Common UI.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Build Profile"),
        backgroundColor: Colors.teal,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back), // Back arrow icon.
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            _buildUserTypeSelector(), // Add user type selection here.
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
              child: Text("Build Profile", style: TextStyle(fontSize: 18)),
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
        SizedBox(height: 20),
        _buildTextField("Preferred Name", nameController, Icons.person),
        _buildTextFieldWithSuggestions("Desired City"),
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
        SizedBox(height: 20),
        _buildTextFieldWithSuggestions("Rental City"),
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
      padding: const EdgeInsets.symmetric(vertical: 8),
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

  // Function to build counters.
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

  // Function to build check boxes.
  Widget _buildCheckbox(String label, bool value, Function(bool) onChanged) {
    return CheckboxListTile(
      title: Text(label),
      value: value,
      onChanged: (bool? newValue) => onChanged(newValue ?? false),
    );
  }
}
