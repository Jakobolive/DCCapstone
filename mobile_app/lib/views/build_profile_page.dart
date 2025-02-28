import 'package:capstone_app/main.dart';
import 'package:capstone_app/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import '../providers/user_provider.dart';

class BuildProfilePage extends StatefulWidget {
  @override
  _BuildProfilePageState createState() => _BuildProfilePageState();
}

class _BuildProfilePageState extends State<BuildProfilePage> {
  final supabase = Supabase.instance.client;
  String? userType; // Determines if the user is a renter or landlord
  final ImagePicker _picker = ImagePicker();
  final _formKey = GlobalKey<FormState>();

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
  File? profilePicture;

  // Landlord-specific fields
  final TextEditingController addressController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  bool smokingAllowed = false;
  bool isPrivate = false;
  final TextEditingController availabilityController = TextEditingController();
  File? listingPicture;

  @override
  void initState() {
    super.initState();
    _showUserTypeDialog();
  }

  // Show popup to select user type
  void _showUserTypeDialog() {
    Future.delayed(
      Duration.zero,
      () => showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: Text("Select Profile Type"),
          content: Text("Are you a renter or a landlord?"),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  userType = "Renter";
                });
                Navigator.pop(context);
              },
              child: Text("Renter"),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  userType = "Landlord";
                });
                Navigator.pop(context);
              },
              child: Text("Landlord"),
            ),
          ],
        ),
      ),
    );
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
      final int? userId = context.read<UserProvider>().userId;
      print("✅ Retrieved userId: $userId");

      // Determine table depending on user type.
      if (userType == "Renter") {
        final response = await supabase.from('preferences_table').insert({
          'user_id': userId,
          'preferred_name': nameController.text ?? "NA",
          'profile_bio': bioController.text ?? "NA",
          'photo_url': profilePicture?.path ?? "",
          'location': locationController.text ?? "Unknown",
          'max_budget': int.tryParse(budgetController.text) ?? 0,
          'pets_allowed': petsAllowed,
          'smoking_allowed': smokingAllowed,
          'bed_count': bedCount,
          'bath_count': bathCount,
          'amenities': amenitiesController.text,
          'is_pref_private': prefPrivate,
        }).select();
        print(response);
      } else if (userType == "Landlord") {
        final response = await supabase.from('listings_table').insert({
          'user_id': userId,
          'photo_url': listingPicture?.path ?? "",
          'street_address': addressController.text ?? "Unknown",
          'location': locationController.text ?? "Unknown",
          'asking_price': int.tryParse(priceController.text) ?? 0,
          'bed_count': bedCount,
          'bath_count': bathCount,
          'amenities': amenitiesController.text,
          'pets_allowed': petsAllowed,
          'smoking_allowed': smokingAllowed,
          'availability': availabilityController.text,
          'listing_bio': bioController.text,
          'is_private': isPrivate,
        }).select();
        print(response);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Profile saved successfully!")),
      );
      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Account Build Failed: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (userType == null) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: CircularProgressIndicator()), // Loading state
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          userType == "Renter"
              ? "Build Renter Profile"
              : "Build Listing Profile",
        ),
        backgroundColor: Colors.teal,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back), // Back arrow icon
          onPressed: () {
            // Navigator.pushNamed(context, '/home');
            Navigator.pop(context);
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
              child: Text("Build Profile", style: TextStyle(fontSize: 18)),
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
        ElevatedButton(
          onPressed: _showUserTypeDialog,
          child: Text(userType == null ? "Select User Type" : "$userType"),
        ),
        SizedBox(height: 20),
        _buildTextField("Preferred Name", nameController, Icons.person),
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
        ElevatedButton(
          onPressed: _showUserTypeDialog,
          child: Text(userType == null ? "Select User Type" : "$userType"),
        ),
        SizedBox(height: 20),
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
