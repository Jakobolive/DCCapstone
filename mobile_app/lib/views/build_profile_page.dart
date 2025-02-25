import 'package:capstone_app/main.dart';
import 'package:capstone_app/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import '../providers/user_provider.dart';
//import "package:capstone_app/assets/";

class BuildProfilePage extends StatefulWidget {
  @override
  _BuildProfilePageState createState() => _BuildProfilePageState();
}

class _BuildProfilePageState extends State<BuildProfilePage> {
  final supabase = Supabase.instance.client;
  String? userType; // Determines if the user is a renter or landlord
  final ImagePicker _picker = ImagePicker();
  List<File> images = []; // Stores uploaded images
  final _formKey = GlobalKey<FormState>();

  // Common fields
  final TextEditingController locationController = TextEditingController();
  final TextEditingController bioController = TextEditingController();

  // Renter-specific fields
  final TextEditingController budgetController = TextEditingController();
  bool petsAllowed = false;
  bool nonSmoking = false;
  int bedCount = 1;
  int bathCount = 1;
  final TextEditingController amenitiesController = TextEditingController();
  File? profilePicture;

  // Landlord-specific fields
  final TextEditingController addressController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  bool petsAllowedLandlord = false;
  bool smokingAllowed = false;
  final TextEditingController availabilityController = TextEditingController();

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

  // Function to pick images
  Future<void> _pickImages() async {
    final pickedFiles = await _picker.pickMultiImage();
    if (pickedFiles != null) {
      setState(() {
        images.addAll(pickedFiles.map((file) => File(file.path)));
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
          'photo_url': profilePicture?.path ?? "",
          'location': locationController.text ?? "Unknown",
          'max_budget': int.tryParse(budgetController.text) ?? 0,
          'pets_allowed': petsAllowed,
          'smoking_allowed': smokingAllowed,
          'bed_count': bedCount,
          'bath_count': bathCount,
          'amenities': amenitiesController.text,
        }).select();
        print(response);
      } else if (userType == "Landlord") {
        final response = await supabase.from('listings_table').insert({
          'user_id': userId,
          'photo_url': images ?? "",
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
                // Save functionality (implement backend submission)
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
        _buildTextField("Location", locationController, Icons.location_on),
        _buildTextField("Bio", bioController, Icons.person),
        _buildTextField("Budget (\$)", budgetController, Icons.attach_money),
        _buildCounter(
            "Beds", bedCount, (value) => setState(() => bedCount = value)),
        _buildCounter(
            "Baths", bathCount, (value) => setState(() => bathCount = value)),
        _buildCheckbox("Pets Allowed", petsAllowed,
            (value) => setState(() => petsAllowed = value)),
        _buildCheckbox("Non-Smoking", nonSmoking,
            (value) => setState(() => nonSmoking = value)),
        _buildTextField("Amenities", amenitiesController, Icons.list),
      ],
    );
  }

  // Landlord Form UI
  Widget _buildLandlordForm() {
    return Column(
      children: [
        ElevatedButton(
          onPressed: _pickImages,
          child: Text("Upload Listing Photos"),
        ),
        if (images.isNotEmpty)
          Container(
            height: 200,
            child: PageView(
              children: images
                  .map((image) => Image.file(image, fit: BoxFit.cover))
                  .toList(),
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
        _buildCheckbox("Pets Allowed", petsAllowedLandlord,
            (value) => setState(() => petsAllowedLandlord = value)),
        _buildCheckbox("Smoking Allowed", smokingAllowed,
            (value) => setState(() => smokingAllowed = value)),
        _buildTextField(
            "Availability", availabilityController, Icons.calendar_today),
        _buildTextField("Amenities", amenitiesController, Icons.list),
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
