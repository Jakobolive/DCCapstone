import 'package:capstone_app/main.dart';
import 'package:capstone_app/providers/user_provider.dart'; // Ensure you import the provider
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:provider/provider.dart';

class EditProfilePage extends StatefulWidget {
  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final supabase = Supabase.instance.client;
  final ImagePicker _picker = ImagePicker();
  String? profilePictureURL;
  File? profilePicture;
  String? listingPictureURL;
  File? listingPicture;
  String? userType;
  int? profileID;

  // Common fields
  final TextEditingController locationController = TextEditingController();
  final TextEditingController bioController = TextEditingController();

  // Renter-specific fields
  final TextEditingController nameController = TextEditingController();
  final TextEditingController budgetController = TextEditingController();
  bool petsAllowed = false;
  bool nonSmoking = false;
  bool prefPrivate = false;
  int bedCount = 1;
  int bathCount = 1;
  final TextEditingController amenitiesController = TextEditingController();

  // Landlord-specific fields
  final TextEditingController addressController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  bool petsAllowedLandlord = false;
  bool smokingAllowed = false;
  bool isPrivate = false;
  final TextEditingController availabilityController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  void _loadProfileData() {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final profileData = userProvider.selectedProfile;

    if (profileData != null) {
      setState(() {
        userType = userProvider.userType; // Directly get the user type

        // Populate common fields
        locationController.text = profileData['location'] ?? '';
        amenitiesController.text = profileData['amenities'] ?? '';

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
        } else {
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

  // Function to pick Listing picture
  Future<void> _pickListingPicture() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        listingPicture = File(pickedFile.path);
      });
    }
  }

  // Function to pick profile picture
  Future<void> _pickProfilePicture() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        profilePicture = File(pickedFile.path);
      });
    }
  }

  Future<void> _saveProfile() async {
    try {
      print("✅ Retrieved profileId: $profileID");

      // Determine table and update accordingly
      if (userType == "Renter") {
        // Ensure the profile exists before updating
        final existingProfile = await supabase
            .from('preferences_table')
            .select('preference_id')
            .eq('preference_id', profileID as Object)
            .maybeSingle();

        if (existingProfile != null) {
          // Update existing profile
          final response = await supabase
              .from('preferences_table')
              .update({
                'preferred_name': nameController.text,
                'profile_bio': bioController.text,
                'photo_url': profilePicture?.path ?? "",
                'location': locationController.text,
                'max_budget': int.tryParse(budgetController.text) ?? 0,
                'pets_allowed': petsAllowed,
                'smoking_allowed': smokingAllowed,
                'bed_count': bedCount,
                'bath_count': bathCount,
                'amenities': amenitiesController.text,
                'is_pref_private': prefPrivate,
              })
              .eq('preference_id', profileID as Object)
              .select();
          print("✅ Updated profile: $response");
        } else {
          print("⚠️ No existing profile found for userId: $profileID");
        }
      } else if (userType == "Landlord") {
        // Ensure the listing exists before updating
        final existingListing = await supabase
            .from('listings_table')
            .select('listing_id')
            .eq('listing_id', profileID as Object)
            .maybeSingle();

        if (existingListing != null) {
          // Update existing listing
          final response = await supabase
              .from('listings_table')
              .update({
                'photo_url': listingPicture?.path ?? "",
                'street_address': addressController.text,
                'location': locationController.text,
                'asking_price': int.tryParse(priceController.text) ?? 0,
                'bed_count': bedCount,
                'bath_count': bathCount,
                'amenities': amenitiesController.text,
                'pets_allowed': petsAllowed,
                'smoking_allowed': smokingAllowed,
                'availability': availabilityController.text,
                'listing_bio': bioController.text,
                'is_private': isPrivate,
              })
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

  // Renter Form UI
  Widget _buildRenterForm() {
    return Column(
      children: [
        GestureDetector(
          onTap: _pickProfilePicture,
          child: CircleAvatar(
            radius: 60,
            backgroundImage: profilePicture != null
                ? FileImage(profilePicture!)
                : AssetImage("assets/placeholder.jpg") as ImageProvider,
            child: profilePicture == null
                ? Icon(Icons.camera_alt, size: 40, color: Colors.white)
                : null,
          ),
        ),
        _buildTextField("Preferred Name", nameController, Icons.people),
        _buildTextField("Location", locationController, Icons.location_on),
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

  // Landlord Form UI
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
        _buildTextField("Location", locationController, Icons.location_on),
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

  // Helper Widgets
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

  Widget _buildCheckbox(String label, bool value, Function(bool) onChanged) {
    return CheckboxListTile(
      title: Text(label),
      value: value,
      onChanged: (bool? newValue) => onChanged(newValue ?? false),
    );
  }
}
