import 'package:capstone_app/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProfilePage extends StatelessWidget {
  @override
  // Common UI.
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final selectedProfile = userProvider.selectedProfile;
    final userType = userProvider.userType;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.teal,
        title: Padding(
          padding: const EdgeInsets.only(top: 10.0), // Add padding to the top.
          child: Column(
            mainAxisAlignment:
                MainAxisAlignment.start, // Align title to the top.
            children: [
              const Text(
                "Profile",
                style: TextStyle(
                    fontSize: 24), // Adjust title font size if needed.
              ),
              Row(
                mainAxisAlignment:
                    MainAxisAlignment.center, // Center the actions. (buttons)
                children: [
                  if ((userProvider.renterProfiles?.isNotEmpty ?? false) ||
                      (userProvider.landlordProfiles?.isNotEmpty ?? false))
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: DropdownButton<Map<String, dynamic>>(
                        value: (userProvider.selectedProfile != null &&
                                (userProvider.renterProfiles?.contains(
                                            userProvider.selectedProfile!) ==
                                        true ||
                                    userProvider.landlordProfiles?.contains(
                                            userProvider.selectedProfile!) ==
                                        true))
                            ? userProvider.selectedProfile
                            : null, // Ensures the value exists in the list.
                        hint: const Text("Select Profile"),
                        dropdownColor: Colors.white,
                        icon: const Icon(Icons.arrow_drop_down,
                            color: Colors.white),
                        onChanged: (Map<String, dynamic>? newValue) {
                          if (newValue != null) {
                            final profileType = newValue['userType'];
                            userProvider.setSelectedProfile(
                                newValue,
                                profileType == 'Renter'
                                    ? "Renter"
                                    : "Landlord");
                            userProvider.fetchProfiles();
                          }
                        },
                        items: [
                          if (userProvider.renterProfiles != null)
                            ...userProvider.renterProfiles!.map((profile) {
                              return DropdownMenuItem<Map<String, dynamic>>(
                                value: profile,
                                child: Text(profile['preferred_name'] ??
                                    "Renter Profile"),
                              );
                            }),
                          if (userProvider.landlordProfiles != null)
                            ...userProvider.landlordProfiles!.map((profile) {
                              return DropdownMenuItem<Map<String, dynamic>>(
                                value: profile,
                                child: Text(profile['street_address'] ??
                                    "Landlord Profile"),
                              );
                            }),
                        ],
                      ),
                    ),
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: () async {
                      await userProvider.fetchProfiles();
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.person_add),
                    onPressed: () {
                      Navigator.pushNamed(context, '/build-profile');
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
        centerTitle: true, // Center the title horizontally.
        toolbarHeight: 120, // Adjust the AppBar height to ensure enough space.
      ),
      body: selectedProfile == null
          ? const Center(
              child: Text(
                "No profile selected",
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            )
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundImage: selectedProfile['photo_url'] != null
                          ? NetworkImage(selectedProfile['photo_url'])
                          : AssetImage("assets/placeholder.jpg")
                              as ImageProvider,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      userType == "Renter"
                          ? selectedProfile['preferred_name'] ?? "Unknown"
                          : selectedProfile['street_address'] ?? "Unknown",
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text("About Me",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    Text(
                      userType == "Renter"
                          ? selectedProfile['profile_bio'] ??
                              "No bio available."
                          : selectedProfile['listing_bio'] ??
                              "No bio available.",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: Colors.black87),
                    ),
                    const Divider(),
                    if (userType == "Renter")
                      ListTile(
                        leading:
                            Icon(Icons.monetization_on, color: Colors.teal),
                        title: Text("Budget"),
                        subtitle: Text(
                            "${selectedProfile['max_budget'] ?? "Not provided"}"),
                      ),
                    if (userType == "Landlord")
                      ListTile(
                        leading: Icon(Icons.attach_money, color: Colors.teal),
                        title: Text("Asking Price"),
                        subtitle: Text(
                            "${selectedProfile['asking_price'] ?? "Not provided"}"),
                      ),
                    ListTile(
                      leading: Icon(Icons.bed, color: Colors.teal),
                      title: Text("Beds"),
                      subtitle: Text(
                          "${selectedProfile['bed_count'] ?? "Not specified"}"),
                    ),
                    ListTile(
                      leading: Icon(Icons.bathtub, color: Colors.teal),
                      title: Text("Baths"),
                      subtitle: Text(
                          "${selectedProfile['bath_count'] ?? "Not specified"}"),
                    ),
                    CheckboxListTile(
                      title: Text("Pets Allowed"),
                      value: selectedProfile['pets_allowed'] ?? false,
                      onChanged: null,
                    ),
                    CheckboxListTile(
                      title: Text("Non-Smoking"),
                      value: selectedProfile['smoking_allowed'] ?? false,
                      onChanged: null,
                    ),
                    ListTile(
                      leading: Icon(Icons.list, color: Colors.teal),
                      title: Text("Amenities"),
                      subtitle:
                          Text(selectedProfile['amenities'] ?? "Not specified"),
                    ),
                    CheckboxListTile(
                      title: Text("Private Mode"),
                      value: userType == "Renter"
                          ? selectedProfile['is_pref_private'] ?? false
                          : selectedProfile['is_private'] ?? false,
                      onChanged: null,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pushReplacementNamed(
                            context, '/edit-profile');
                      },
                      icon: const Icon(Icons.edit),
                      label: const Text("Edit Profile"),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        backgroundColor: Colors.teal,
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
    );
  }
}
