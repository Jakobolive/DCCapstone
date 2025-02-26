import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Swipe Rentals"),
        centerTitle: true,
        backgroundColor: Colors.teal,
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add), // Icon for profile creation
            onPressed: () {
              Navigator.pushNamed(context,
                  '/build-profile'); // Navigate to profile creation page
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Profile Picture
              CircleAvatar(
                radius: 60,
                backgroundImage: AssetImage(
                    "assets/placeholder.jpg"), // Replace with dynamic image
              ),
              const SizedBox(height: 16),

              // Name
              const Text(
                "John Doe", // Replace with dynamic user name
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),

              // Email
              const Text(
                "johndoe@example.com", // Replace with dynamic user email
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 16),

              // About Section
              const Text(
                "About Me",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "I am a property manager specializing in residential units. Feel free to contact me for inquiries.", // Dynamic content
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 20),

              // Contact Information
              ListTile(
                leading: Icon(Icons.phone, color: Colors.teal),
                title: const Text("Phone"),
                subtitle: const Text("+1 123 456 7890"), // Dynamic content
              ),
              const Divider(),
              ListTile(
                leading: Icon(Icons.location_on, color: Colors.teal),
                title: const Text("Location"),
                subtitle: const Text("Toronto, ON, Canada"), // Dynamic content
              ),
              const Divider(),

              // Edit Profile Button
              ElevatedButton.icon(
                onPressed: () {
                  // Add navigation to edit profile page.
                  Navigator.pushReplacementNamed(context, '/edit-profile');
                },
                icon: const Icon(Icons.edit),
                label: const Text("Edit Profile"),
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  backgroundColor: Colors.teal,
                ),
              ),
              const SizedBox(height: 16),

              // Logout Button
              TextButton(
                onPressed: () {
                  // Add logout logic
                },
                child: const Text(
                  "Log Out",
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
